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
    PlanetFactory_collect_resources,
    PlanetFactory_generate_planet,
    PlanetFactory_upgrade_metal_mine,
    PlanetFactory_upgrade_crystal_mine,
    PlanetFactory_upgrade_deuterium_mine,
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
func get_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }(planet_id : felt) -> (planet : Planet):
    let (planet) = PlanetFactory_planets.read(planet_id)
    return(planet)
end

@view
func get_my_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (planet_id : felt):
    let (address) = get_caller_address()
    let (id) = PlanetFactory_planet_to_owner.read(address)
    return(planet_id=id)
end

@view
func get_structures_levels{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (metal_mine : felt, crystal_mine : felt, deuterium_mine : felt):
    let (address) = get_caller_address()
    let (id) = PlanetFactory_planet_to_owner.read(address)
    let (planet) = PlanetFactory_planets.read(id)
    let metal = planet.metal_mine 
    let crystal = planet.crystal_mine 
    let deuterium = planet.deuterium_mine
    return(metal_mine=metal, crystal_mine=crystal, deuterium_mine=deuterium)
end

@view
func resources_available{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (metal : felt, crystal : felt, deuterium : felt):
    let (address) = get_caller_address()
    let (id) = PlanetFactory_planet_to_owner.read(address)
    let (planet) = PlanetFactory_planets.read(id)
    let metal_available = planet.metal_storage
    let crystal_available = planet.crystal_storage
    let deuterium_available = planet.deuterium_storage
    return(metal=metal_available, crystal=crystal_available, deuterium=deuterium_available)
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
        }():
    PlanetFactory_generate_planet()
    return()
end

@external
func collect_resources{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }():
    let (address) = get_caller_address()
    assert_not_zero(address)
    let (id) = PlanetFactory_planet_to_owner.read(address)
    PlanetFactory_collect_resources(planet_id=id)
    return()
end

@external
func upgrade_metal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    PlanetFactory_upgrade_metal_mine()
    return()
end

@external
func upgrade_crystal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    PlanetFactory_upgrade_crystal_mine()
    return()
end

@external
func upgrade_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    PlanetFactory_upgrade_deuterium_mine()
    return()
end