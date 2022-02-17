%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.keccak import unsafe_keccak
from starkware.cairo.common.math import unsigned_div_rem

const MAXPLANETIDDIGITS = 16
const IDMOD = 10**16

struct Planet:
    member planet_name : felt
    member metal_mine : felt
    member crystal_mine : felt
    member deuterium_mine : felt
end

@storage_var
func PlanetFactory_number_of_planets() -> (n : felt):
end

@storage_var
func PlanetFactory_planets(id : felt) -> (planet : Planet):
end

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

@view
func get_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }(planet_id : felt) -> (planet : Planet):
    let (planet) = PlanetFactory_planets.read(planet_id)
    return(planet)
end

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }():
    return()
end

@external
func generate_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }(planet_name : felt) -> (new_planet : Planet):
    let planet = Planet(planet_name=planet_name, metal_mine=1, crystal_mine=1, deuterium_mine=1)
    let (id) = PlanetFactory_number_of_planets.read()
    PlanetFactory_number_of_planets.write(id+1)
    PlanetFactory_planets.write(id + 1, planet)
    planet_genereted.emit(id=id+1)
    return(new_planet=planet)
end
