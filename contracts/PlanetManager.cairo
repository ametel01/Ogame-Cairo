%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_block_timestamp,
    get_contract_address,
    )

from contracts.utils.Formulas import (
    formulas_metal_mine, 
    formulas_crystal_mine, 
    formulas_deuterium_mine,
    formulas_metal_building,
    formulas_crystal_building,
    formulas_deuterium_building,
    formulas_solar_plant,
    formulas_solar_plant_building,
    _consumption,
    _consumption_deuterium,
    _production_limiter,
    formulas_production_scaler,
    formulas_buildings_production_time,
    )
########### NEW IMPORTS #################################

from contracts.utils.library import (
    Cost,
    _planet_to_owner,
    _number_of_planets,
    _planets,
    Planet,
    MineLevels,
    MineStorage,
    Energy,
    erc721_token_address,
    planet_genereted,
    structure_updated,
    buildings_timelock,
    )
from contracts.PlanetManager import (
    _update_resources_erc20,
    )

# Used to create the first planet for a player. It does register the new planet in the contract storage
# and send the NFT to the caller. At the moment planets IDs are incremental +1. TODO: implement a 
# random ID generator.
func _generate_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
        }():
    alloc_locals
    let (time_now) = get_block_timestamp()
    let (address) = get_caller_address()
    assert_not_zero(address)
    # One address can only have one planet at this stage.
    let (has_already_planet) = _planet_to_owner.read(address)
    assert has_already_planet = Uint256(0,0)
    let planet = Planet(
        MineLevels(metal=1, crystal=1, deuterium=1),
        MineStorage(metal=500, crystal=300,deuterium=100),
        Energy(solar_plant=1),
        timer=time_now)
    # Transfer ERC721 to caller
    let (erc721_address) = erc721_token_address.read()
    let (last_id) = _number_of_planets.read()
    let new_planet_id = Uint256(last_id+1, 0)
    let (erc721_owner) = IERC721.ownerOf(erc721_address, new_planet_id)
    IERC721.transferFrom(erc721_address, erc721_owner, address, new_planet_id)
    _planet_to_owner.write(address, new_planet_id)
    _planets.write(new_planet_id, planet)
    _number_of_planets.write(last_id+1)
    planet_genereted.emit(new_planet_id)
    # Transfer resources ERC20 tokens to caller.
    _update_resources_erc20(to=address, 
                            metal_amount=500, 
                            crystal_amount=300,
                            deuterium_amount=100)
    return()
end

func _collect_resources{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(caller : felt):
    alloc_locals
    let (planet_id) = _planet_to_owner.read(caller)
    let (planet) = _planets.read(planet_id)
    let time_start = planet.timer
    let metal_level = planet.mines.metal
    let crystal_level = planet.mines.crystal
    let deuterium_level = planet.mines.deuterium
    # Calculate energy requirerments.
    let (energy_required_metal) = _consumption(metal_level)
    let (energy_required_crystal) = _consumption(crystal_level)
    let (energy_required_deuterium) = _consumption_deuterium(deuterium_level)
    let total_energy_required = energy_required_metal + energy_required_crystal + energy_required_deuterium
    let solar_plant_level = planet.energy.solar_plant
    let (energy_available) = formulas_solar_plant(solar_plant_level)
    
    let (enough_energy) = is_le(total_energy_required,energy_available)
    # Calculate amount of resources produced.
    let (metal_produced) = formulas_metal_mine(last_timestamp=time_start, mine_level=metal_level)
    let (crystal_produced) = formulas_crystal_mine(last_timestamp=time_start, mine_level=crystal_level)
    let (deuterium_produced) = formulas_deuterium_mine(last_timestamp=time_start, mine_level=deuterium_level)
    # If energy available < than energy required scale down amount produced.
    if enough_energy == FALSE:
        let (actual_metal, 
            actual_crystal, 
            actual_deuterium) = formulas_production_scaler(net_metal=metal_produced,
                                                        net_crystal=crystal_produced,
                                                        net_deuterium=deuterium_produced,
                                                        energy_required=total_energy_required,
                                                        energy_available=energy_available)
        let (time_now) = get_block_timestamp()
        let updated_planet = Planet(
                                MineLevels(metal=1,crystal=1,deuterium=1),
                                MineStorage(metal=planet.storage.metal + actual_metal,
                                        crystal=planet.storage.crystal + actual_crystal,
                                        deuterium=planet.storage.deuterium + actual_deuterium),
                                Energy(solar_plant=1),
                                timer=time_now)
        _planets.write(planet_id, updated_planet)
        # Update ERC20 contract for resources
        _update_resources_erc20(to=caller, 
                                metal_amount=actual_metal, 
                                crystal_amount=actual_crystal,
                                deuterium_amount=actual_deuterium)
    else:
        let (time_now) = get_block_timestamp()
        let updated_planet = Planet(
                                MineLevels(metal=1,crystal=1,deuterium=1),
                                MineStorage(metal=planet.storage.metal + metal_produced,
                                        crystal=planet.storage.crystal + crystal_produced,
                                        deuterium=planet.storage.deuterium + deuterium_produced),
                                Energy(solar_plant=planet.energy.solar_plant),
                                timer=time_now)
        _planets.write(planet_id, updated_planet)
        # Update ERC20 contract for resources
        _update_resources_erc20(to=caller, 
                                metal_amount=metal_produced, 
                                crystal_amount=crystal_produced,
                                deuterium_amount=deuterium_produced)
    end                                
    return()
end

func _start_metal_upgrade{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let current_mine_level = planet.mines.metal
    let (metal_required, crystal_required) = formulas_metal_building(metal_mine_level=current_mine_level)
    let (time_unlocked) = formulas_buildings_production_time(metal_required, crystal_required, 0)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    with_attr error_message("Not enough resources"):
        assert_le(metal_required, metal_available)
        assert_le(crystal_required, crystal_available)
    end
    _update_resources_erc20(
        to=
    buildings_timelock.write(address, time_unlocked)
    return()
end

func _end_metal_upgrade{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let new_planet = Planet(
                        MineLevels(metal=current_mine_level + 1,
                                    crystal=planet.mines.crystal,
                                    deuterium=planet.mines.deuterium),
                        MineStorage(metal=metal_available - metal_required,
                                    crystal=crystal_available - crystal_required,
                                    deuterium = planet.storage.deuterium),
                        Energy(solar_plant=planet.energy.solar_plant),
                        timer=planet.timer)             
    _planets.write(planet_id, new_planet)
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end

func _upgrade_crystal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (local planet) = _planets.read(planet_id)
    let current_mine_level = planet.mines.crystal
    let (metal_required, crystal_required) = formulas_crystal_building(crystal_mine_level=current_mine_level)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    assert_le(metal_required, metal_available)
    assert_le(crystal_required, crystal_available)
    let new_planet = Planet(
                        MineLevels(metal=planet.mines.metal,
                                    crystal=planet.mines.crystal + 1,
                                    deuterium=planet.mines.deuterium),
                        MineStorage(metal=metal_available - metal_required,
                                    crystal=crystal_available - crystal_required,
                                    deuterium=planet.storage.deuterium),
                        Energy(solar_plant=planet.energy.solar_plant),
                        timer = planet.timer)             
    _planets.write(planet_id, new_planet)
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end

func _upgrade_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (local planet) = _planets.read(planet_id)
    let current_mine_level = planet.mines.deuterium
    let (metal_required, crystal_required) = formulas_deuterium_building(deuterium_mine_level=current_mine_level)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    assert_le(metal_required, metal_available)
    assert_le(crystal_required, crystal_available)
    let new_planet = Planet(
                        MineLevels(metal=planet.mines.metal,
                                    crystal=planet.mines.crystal,
                                    deuterium=planet.mines.deuterium + 1),
                        MineStorage(metal=metal_available - metal_required,
                                    crystal=crystal_available - crystal_required,
                                    deuterium = planet.storage.deuterium),
                        Energy(solar_plant=planet.energy.solar_plant),
                        timer = planet.timer)             
    _planets.write(planet_id, new_planet)
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end

func _upgrade_solar_plant{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (local planet) = _planets.read(planet_id)
    let current_plant_level = planet.energy.solar_plant
    let (metal_required, crystal_required) = formulas_metal_building(metal_mine_level=current_plant_level)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    assert_le(metal_required, metal_available)
    assert_le(crystal_required, crystal_available)
    let new_planet = Planet(
                        MineLevels(metal=planet.mines.metal,
                                    crystal=planet.mines.crystal,
                                    deuterium=planet.mines.deuterium),
                        MineStorage(metal=metal_available - metal_required,
                                    crystal=crystal_available - crystal_required,
                                    deuterium = planet.storage.deuterium),
                        Energy(solar_plant=planet.energy.solar_plant+1),
                        timer=planet.timer)             
    _planets.write(planet_id, new_planet)
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end

func get_upgrades_cost{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (up_metal : Cost, 
                up_crystal : Cost, 
                up_deuturium : Cost, 
                up_solar : Cost):
    alloc_locals 
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let metal_level = planet.mines.metal
    let crystal_level = planet.mines.crystal
    let deuterium_level = planet.mines.deuterium
    let solar_plant_level = planet.energy.solar_plant
    let (m_metal, m_crystal) = formulas_metal_building(metal_level)
    let (c_metal, c_crystal) = formulas_crystal_building(crystal_level)
    let (d_metal, d_crystal) = formulas_deuterium_building(deuterium_level)
    let (s_metal, s_crystal) = formulas_solar_plant_building(solar_plant_level)
    return(up_metal=Cost(metal=m_metal,crystal=m_crystal,deuterium=0),
        up_crystal=Cost(metal=c_metal,crystal=c_crystal,deuterium=0),
        up_deuturium=Cost(metal=d_metal,crystal=d_crystal,deuterium=0),
        up_solar=Cost(metal=s_metal,crystal=s_crystal,deuterium=0))
end
    
    

    
