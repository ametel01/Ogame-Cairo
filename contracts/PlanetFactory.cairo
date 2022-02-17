%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.keccak import unsafe_keccak
from starkware.cairo.common.math import unsigned_div_rem
from starkware.starknet.common.syscalls import get_caller_address

const MAXPLANETIDDIGITS = 16
const IDMOD = 10**16

struct Planet:
    member planet_name : felt
    member metal_mine : felt
    member crystal_mine : felt
    member deuterium_mine : felt
end

###########
# Storage #
###########

@storage_var
func PlanetFactory_number_of_planets() -> (n : felt):
end

@storage_var
func PlanetFactory_planets(id : felt) -> (planet : Planet):
end

@storage_var
func PlanetFactory_planet_to_owner(address : felt) -> (planet_id : felt):
end


##########
# Events #
##########

@event
func planet_genereted(id : felt):
end

@view
func number_of_planets{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (n_planets : felt):
    let (n) = PlanetFactory_number_of_planets.read()
    return(n_planets=n)
end

###########
# Getters #
###########

@view
func get_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }(planet_id : felt) -> (planet : Planet):
    let (planet) = PlanetFactory_planets.read(planet_id)
    return(planet)
end

###############
# Constructor #
###############

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }():
    return()
end

#############
# Externals #
#############

@external
func generate_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }(planet_name : felt) -> (new_planet : Planet):
    let planet = Planet(planet_name=planet_name, metal_mine=1, crystal_mine=1, deuterium_mine=1)
    let (last_id) = PlanetFactory_number_of_planets.read() 
    let new_planet_id = last_id + 1
    let (address) = get_caller_address()
    PlanetFactory_planet_to_owner.write(address, new_planet_id)
    PlanetFactory_number_of_planets.write(new_planet_id)
    PlanetFactory_planets.write(new_planet_id, planet)
    planet_genereted.emit(id=new_planet_id)
    return(new_planet=planet)
end
