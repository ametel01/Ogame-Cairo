%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_not_zero, assert_le, unsigned_div_rem
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from contracts.utils.constants import TRUE, FALSE
from contracts.utils.Formulas import (
                                formulas_metal_mine, 
                                formulas_crystal_mine, 
                                formulas_deuterium_mine,
                                formulas_metal_building,
                                formulas_crystal_building,
                                formulas_deuterium_building)
from contracts.utils.Math64x61 import Math64x61_mul


###########
# Structs #
###########
const ID_MOD = 65536

struct Planet:
    # Mines level
    member metal_mine : felt
    member crystal_mine : felt
    member deuterium_mine : felt
    # Mines storage
    member metal_storage : felt
    member crystal_storage : felt
    member deuterium_storage : felt
    # Mines timer
    member timer : felt
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

@event
func structure_updated(metal_used : felt, crystal_used : felt, deuterium_used : felt):
end

######################
# Internal functions #
######################

func PlanetFactory_collect_resources{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(planet_id : felt) -> ():
    alloc_locals
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let time_start = planet.timer
    let metal_level = planet.metal_mine
    let crystal_level = planet.crystal_mine
    let deuterium_level = planet.deuterium_mine
    let (metal_produced) = formulas_metal_mine(time_start, metal_level)
    let (crystal_produced) = formulas_crystal_mine(time_start, crystal_level)
    let (deuterium_produced) = formulas_deuterium_mine(time_start, deuterium_level)
    let (time_now) = get_block_timestamp()
    let updated_planet = Planet(
                                metal_mine = 1,
                                crystal_mine = 1,
                                deuterium_mine = 1,
                                metal_storage = planet.metal_storage + metal_produced,
                                crystal_storage = planet.crystal_storage + crystal_produced,
                                deuterium_storage = planet.deuterium_storage + deuterium_produced,
                                timer = time_now,
                            )
    PlanetFactory_planets.write(planet_id, updated_planet)
    return()
end

func PlanetFactory_generate_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
        }() -> (new_planet : Planet):
    alloc_locals
    let (local time_now) = get_block_timestamp()
    let (address) = get_caller_address()
    assert_not_zero(address)
    let planet = Planet(
        metal_mine=1, 
        crystal_mine=1,
        deuterium_mine=1,
        metal_storage=500,
        crystal_storage=300,
        deuterium_storage=100,
        timer=time_now,)
    #let (last_id) = PlanetFactory_number_of_planets.read() 
    let (_,new_planet_id) = unsigned_div_rem(time_now, ID_MOD) 
    let (has_already_planet) = PlanetFactory_planet_to_owner.read(address)
    assert has_already_planet = FALSE
    let (id_already_exist) = PlanetFactory_planets.read(new_planet_id)
    assert id_already_exist.metal_mine = FALSE
    PlanetFactory_planet_to_owner.write(address, new_planet_id)
    let (current_number_of_planets) = PlanetFactory_number_of_planets.read()
    PlanetFactory_number_of_planets.write(current_number_of_planets+1)
    PlanetFactory_planets.write(new_planet_id, planet)
    planet_genereted.emit(id=new_planet_id)
    return(new_planet=planet)
end

func PlanetFactory_upgrade_metal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
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
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end

func PlanetFactory_upgrade_crystal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
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
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end

func PlanetFactory_upgrade_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
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
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end


    
