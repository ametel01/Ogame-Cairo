%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_le
from starkware.cairo.common.math import unsigned_div_rem
from starkware.starknet.common.syscalls import get_caller_address
from starkware.starknet.common.syscalls import get_block_timestamp
from contracts.utils.constants import TRUE, FALSE
from contracts.utils.Formulas import formulas_metal_building, formulas_crystal_building, formulas_deuterium_building

from contracts.PlanetFactory_base import (
    Planet, 

    PlanetFactory_number_of_planets, 
    PlanetFactory_planets,
    PlanetFactory_planet_to_owner,
    PlanetFactory_collect_resources,

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
func metal_stored{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (metal : felt):
    let (address) = get_caller_address()
    let (id) = PlanetFactory_planet_to_owner.read(address)
    let (planet) = PlanetFactory_planets.read(id)
    let stored = planet.metal_storage
    return(metal=stored)
end

@view
func crystal_stored{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (crystal : felt):
    let (address) = get_caller_address()
    let (id) = PlanetFactory_planet_to_owner.read(address)
    let (planet) = PlanetFactory_planets.read(id)
    let stored = planet.crystal_storage
    return(crystal=stored)
end

@view
func deuterium_stored{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (deuterium : felt):
    let (address) = get_caller_address()
    let (id) = PlanetFactory_planet_to_owner.read(address)
    let (planet) = PlanetFactory_planets.read(id)
    let stored = planet.deuterium_storage
    return(deuterium=stored)
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
        crystal_mine=1,
        deuterium_mine=1,
        metal_storage=0,
        crystal_storage=0,
        deuterium_storage=0,
        timer=time_now,)
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
        }() -> (metal : felt, crystal : felt):
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = PlanetFactory_planet_to_owner.read(address)
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let current_mine_level = planet.metal_mine
    let (metal_required, crystal_required) = formulas_metal_building(current_mine_level)
    let metal_available = planet.metal_storage
    let crystal_available = planet.crystal_storage
    assert_le(metal_required, metal_available)
    assert_le(crystal_required, crystal_available)
    let new_planet = Planet(
                        metal_mine=current_mine_level + 1,
                        crystal_mine=planet.crystal_mine,
                        deuterium_mine=planet.deuterium_mine,
                        metal_storage=metal_available - metal_required,
                        crystal_storage=crystal_available - crystal_required,
                        deuterium_storage = planet.deuterium_storage,
                        timer = planet.timer,
                    )             
    PlanetFactory_planets.write(planet_id, new_planet)
    return(metal_required, crystal_required)
end

@external
func upgrade_crystal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }() -> (metal : felt, crystal : felt):
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = PlanetFactory_planet_to_owner.read(address)
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let current_mine_level = planet.crystal_mine
    let (metal_required, crystal_required) = formulas_crystal_building(current_mine_level)
    let metal_available = planet.metal_storage
    let crystal_available = planet.crystal_storage
    assert_le(metal_required, metal_available)
    assert_le(crystal_required, crystal_available)
    let new_planet = Planet(
                        metal_mine=planet.metal_mine,
                        crystal_mine=planet.crystal_mine + 1,
                        deuterium_mine=planet.deuterium_mine,
                        metal_storage=metal_available - metal_required,
                        crystal_storage=crystal_available - crystal_required,
                        deuterium_storage = planet.deuterium_storage,
                        timer = planet.timer,
                    )             
    PlanetFactory_planets.write(planet_id, new_planet)
    return(metal_required, crystal_required)
end

@external
func upgrade_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }() -> (metal : felt, crystal : felt):
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = PlanetFactory_planet_to_owner.read(address)
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let current_mine_level = planet.deuterium_mine
    let (metal_required, crystal_required) = formulas_deuterium_building(current_mine_level)
    let metal_available = planet.metal_storage
    let crystal_available = planet.crystal_storage
    assert_le(metal_required, metal_available)
    assert_le(crystal_required, crystal_available)
    let new_planet = Planet(
                        metal_mine=planet.metal_mine,
                        crystal_mine=planet.crystal_mine,
                        deuterium_mine=planet.deuterium_mine + 1,
                        metal_storage=metal_available - metal_required,
                        crystal_storage=crystal_available - crystal_required,
                        deuterium_storage = planet.deuterium_storage,
                        timer = planet.timer,
                    )             
    PlanetFactory_planets.write(planet_id, new_planet)
    return(metal_required, crystal_required)
end