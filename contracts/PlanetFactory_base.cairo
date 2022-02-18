%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from contracts.utils.Formulas import formulas_metal_mine, formulas_crystal_mine, formulas_deuterium_mine

###########
# Structs #
###########

struct Planet:
    member metal_mine : felt
    member metal_storage : felt
    member metal_timer : felt
    member crystal_mine : felt
    member crystal_storage : felt
    member crystal_timer : felt
    member deuterium_mine : felt
    member deuterium_storage : felt
    member deuterium_timer : felt
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

######################
# Internal functions #
######################

func PlanetFactory_calculate_metal{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(planet_id : felt) -> ():
    alloc_locals
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let time_start = planet.metal_timer
    let mine_level = planet.metal_mine
    let (production) = formulas_metal_mine(time_start, mine_level)
    planet.metal_storage = production
    return()
end

func PlanetFactory_calculate_crystal{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(planet_id : felt) -> ():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = PlanetFactory_planet_to_owner.read(address)
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let time_start = planet.metal_timer
    let mine_level = planet.metal_mine
    let (production) = formulas_crystal_mine(time_start, mine_level)
    planet.crystal_storage = production
    return()
end

func PlanetFactory_calculate_deuterium{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(planet_id : felt) -> ():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = PlanetFactory_planet_to_owner.read(address)
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let time_start = planet.metal_timer
    let mine_level = planet.metal_mine
    let (production) = formulas_crystal_mine(time_start, mine_level)
    planet.crystal_storage = production
    return()
end
    
