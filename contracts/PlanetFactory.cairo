%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.math import unsigned_div_rem
from starkware.starknet.common.syscalls import get_caller_address
from starkware.starknet.common.syscalls import get_block_timestamp
from contracts.utils.constants import TRUE, FALSE

from contracts.PlanetFactory_base import (
    Planet, 

    PlanetFactory_number_of_planets, 
    PlanetFactory_planets,
    PlanetFactory_planet_to_owner,
    PlanetFactory_calculate_metal,
    PlanetFactory_calculate_crystal,
    PlanetFactory_calculate_deuterium,

    planet_genereted
)

###########
# Getters #
###########

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
func query_metal_production{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }() -> (production : felt):
    alloc_locals
    let (address) = get_caller_address()
    let (local planet_id) = PlanetFactory_planet_to_owner.read(address)
    PlanetFactory_calculate_metal(planet_id)
    let (planet) = PlanetFactory_planets.read(planet_id)
    let metal = planet.metal_storage
    return(production=metal)
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
        }() -> (new_planet : Planet):
    let (time_now) = get_block_timestamp()
    let planet = Planet(
        metal_mine=1, 
        metal_storage=0,
        metal_timer=time_now, 
        crystal_mine=1, 
        crystal_storage=0,
        crystal_timer=time_now,
        deuterium_mine=1,
        deuterium_storage=0,
        deuterium_timer=time_now,)
    let (last_id) = PlanetFactory_number_of_planets.read() 
    let new_planet_id = last_id + 1
    let (address) = get_caller_address()
    assert_not_zero(address)
    let (has_already_planet) = PlanetFactory_planet_to_owner.read(address)
    assert has_already_planet = 0
    PlanetFactory_planet_to_owner.write(address, new_planet_id)
    PlanetFactory_number_of_planets.write(new_planet_id)
    PlanetFactory_planets.write(new_planet_id, planet)
    planet_genereted.emit(id=new_planet_id)
    return(new_planet=planet)
end

