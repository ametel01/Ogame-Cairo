%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_le
from starkware.cairo.common.uint256 import Uint256
from contracts.utils.constants import FALSE, TRUE
from starkware.cairo.common.math_cmp import is_le
from contracts.token.erc721.interfaces.IERC721 import IERC721
from contracts.ResourcesManager import _receive_resources_erc20, _pay_resources_erc20
from starkware.starknet.common.syscalls import (
    get_block_timestamp, get_contract_address, get_caller_address)
from contracts.utils.Formulas import (
    formulas_metal_mine, formulas_crystal_mine, formulas_deuterium_mine, formulas_metal_building,
    formulas_crystal_building, formulas_deuterium_building, formulas_solar_plant,
    formulas_solar_plant_building, _consumption, _consumption_deuterium, _production_limiter,
    formulas_production_scaler, formulas_buildings_production_time)
from contracts.utils.library import (
    Cost, _planet_to_owner, _number_of_planets, _planets, Planet, MineLevels, MineStorage, Energy,
    Facilities, erc721_token_address, planet_genereted, structure_updated, buildings_timelock,
    _get_planet, reset_timelock)

# Used to create the first planet for a player. It does register the new planet in the contract storage
# and send the NFT to the caller. At the moment planets IDs are incremental +1. TODO: implement a
# random ID generator.
func _generate_planet{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (time_now) = get_block_timestamp()
    let (address) = get_caller_address()
    # One address can only have one planet at this stage.
    let (has_already_planet) = _planet_to_owner.read(address)
    assert has_already_planet = Uint256(0, 0)
    let planet = Planet(
        MineLevels(metal=1, crystal=1, deuterium=1),
        MineStorage(metal=500, crystal=300, deuterium=100),
        Energy(solar_plant=1),
        Facilities(robot_factory=0),
        timer=time_now)
    # Transfer ERC721 to caller
    let (erc721_address) = erc721_token_address.read()
    let (last_id) = _number_of_planets.read()
    let new_id = last_id + 1
    let new_planet_id = Uint256(0, new_id)
    let (erc721_owner) = IERC721.ownerOf(erc721_address, new_planet_id)
    IERC721.transferFrom(erc721_address, erc721_owner, address, new_planet_id)
    _planet_to_owner.write(address, new_planet_id)
    _planets.write(new_planet_id, planet)
    _number_of_planets.write(last_id + 1)
    planet_genereted.emit(new_planet_id)
    # Transfer resources ERC20 tokens to caller.
    _receive_resources_erc20(to=address, metal_amount=500, crystal_amount=300, deuterium_amount=100)
    return ()
end

func _start_metal_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        end_time : felt):
    alloc_locals
    let (address) = get_caller_address()
    let (current_timelock) = buildings_timelock.read(address)
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (contract) = get_contract_address()
    let (local planet) = _get_planet()
    let current_mine_level = planet.mines.metal
    let (metal_required, crystal_required) = formulas_metal_building(
        metal_mine_level=current_mine_level)
    let (building_time) = formulas_buildings_production_time(metal_required, crystal_required, 0)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    with_attr error_message("Not enough resources"):
        assert_le(metal_required, metal_available)
        assert_le(crystal_required, crystal_available)
    end
    _pay_resources_erc20(address, metal_required, crystal_required, deuterium_amount=0)
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    buildings_timelock.write(address, time_unlocked)
    return (time_unlocked)
end

func _end_metal_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let (timelock_end) = buildings_timelock.read(address)
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let current_mine_level = planet.mines.metal
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    let (metal_required, crystal_required) = formulas_metal_building(current_mine_level)
    let new_planet = Planet(
        MineLevels(metal=planet.mines.metal + 1,
        crystal=planet.mines.crystal,
        deuterium=planet.mines.deuterium),
        MineStorage(metal=metal_available - metal_required,
        crystal=crystal_available - crystal_required,
        deuterium=planet.storage.deuterium),
        Energy(solar_plant=planet.energy.solar_plant),
        Facilities(robot_factory=planet.facilities.robot_factory),
        timer=planet.timer)
    _planets.write(planet_id, new_planet)
    reset_timelock(address)
    structure_updated.emit(metal_required, crystal_required, 0)
    return ()
end

func _start_crystal_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (end_time : felt):
    alloc_locals
    let (address) = get_caller_address()
    let (current_timelock) = buildings_timelock.read(address)
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (contract) = get_contract_address()
    let (local planet) = _get_planet()
    let current_mine_level = planet.mines.crystal
    let (metal_required, crystal_required) = formulas_crystal_building(current_mine_level)
    let (building_time) = formulas_buildings_production_time(metal_required, crystal_required, 0)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    with_attr error_message("Not enough resources"):
        assert_le(metal_required, metal_available)
        assert_le(crystal_required, crystal_available)
    end
    _pay_resources_erc20(address, metal_required, crystal_required, deuterium_amount=0)
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    # %{
    #     print("metal ", ids.metal_required)
    #     print("crystal ", ids.crystal_required)
    #     print("time ", ids.building_time)
    # %}
    buildings_timelock.write(address, time_unlocked)
    return (time_unlocked)
end

func _end_crystal_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let (timelock_end) = buildings_timelock.read(address)
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let current_mine_level = planet.mines.crystal
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    let (metal_required, crystal_required) = formulas_crystal_building(current_mine_level)
    let new_planet = Planet(
        MineLevels(metal=planet.mines.metal,
        crystal=planet.mines.crystal + 1,
        deuterium=planet.mines.deuterium),
        MineStorage(metal=metal_available - metal_required,
        crystal=crystal_available - crystal_required,
        deuterium=planet.storage.deuterium),
        Energy(solar_plant=planet.energy.solar_plant),
        Facilities(robot_factory=planet.facilities.robot_factory),
        timer=planet.timer)
    _planets.write(planet_id, new_planet)
    reset_timelock(address)
    structure_updated.emit(metal_required, crystal_required, 0)
    return ()
end

func _start_deuterium_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (end_time : felt):
    alloc_locals
    let (address) = get_caller_address()
    let (current_timelock) = buildings_timelock.read(address)
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (contract) = get_contract_address()
    let (local planet) = _get_planet()
    let current_mine_level = planet.mines.deuterium
    let (metal_required, crystal_required) = formulas_deuterium_building(current_mine_level)
    let (building_time) = formulas_buildings_production_time(metal_required, crystal_required, 0)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    with_attr error_message("Not enough resources"):
        assert_le(metal_required, metal_available)
        assert_le(crystal_required, crystal_available)
    end
    _pay_resources_erc20(address, metal_required, crystal_required, deuterium_amount=0)
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    buildings_timelock.write(address, time_unlocked)
    return (time_unlocked)
end

func _end_deuterium_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let (timelock_end) = buildings_timelock.read(address)
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let current_mine_level = planet.mines.deuterium
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    let (metal_required, crystal_required) = formulas_deuterium_building(current_mine_level)
    let new_planet = Planet(
        MineLevels(metal=planet.mines.metal,
        crystal=planet.mines.crystal,
        deuterium=planet.mines.deuterium + 1),
        MineStorage(metal=metal_available - metal_required,
        crystal=crystal_available - crystal_required,
        deuterium=planet.storage.deuterium),
        Energy(solar_plant=planet.energy.solar_plant),
        Facilities(robot_factory=planet.facilities.robot_factory),
        timer=planet.timer)
    _planets.write(planet_id, new_planet)
    reset_timelock(address)
    structure_updated.emit(metal_required, crystal_required, 0)
    return ()
end

func _start_solar_plant_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (end_time : felt):
    alloc_locals
    let (address) = get_caller_address()
    let (current_timelock) = buildings_timelock.read(address)
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (contract) = get_contract_address()
    let (local planet) = _get_planet()
    let current_plant_level = planet.energy.solar_plant
    let (metal_required, crystal_required) = formulas_solar_plant_building(current_plant_level)
    let (building_time) = formulas_buildings_production_time(metal_required, crystal_required, 0)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    with_attr error_message("Not enough resources"):
        assert_le(metal_required, metal_available)
        assert_le(crystal_required, crystal_available)
    end
    _pay_resources_erc20(address, metal_required, crystal_required, deuterium_amount=0)
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    buildings_timelock.write(address, time_unlocked)
    return (time_unlocked)
end

func _end_solar_plant_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let (timelock_end) = buildings_timelock.read(address)
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let current_plant_level = planet.energy.solar_plant
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    let (metal_required, crystal_required) = formulas_solar_plant_building(current_plant_level)
    let new_planet = Planet(
        MineLevels(metal=planet.mines.metal,
        crystal=planet.mines.crystal,
        deuterium=planet.mines.deuterium),
        MineStorage(metal=metal_available - metal_required,
        crystal=crystal_available - crystal_required,
        deuterium=planet.storage.deuterium),
        Energy(solar_plant=planet.energy.solar_plant + 1),
        Facilities(robot_factory=planet.facilities.robot_factory),
        timer=planet.timer)
    _planets.write(planet_id, new_planet)
    reset_timelock(address)
    structure_updated.emit(metal_required, crystal_required, 0)
    return ()
end

func get_upgrades_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt) -> (
        up_metal : Cost, up_crystal : Cost, up_deuturium : Cost, up_solar : Cost):
    alloc_locals
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
    return (
        up_metal=Cost(metal=m_metal, crystal=m_crystal, deuterium=0),
        up_crystal=Cost(metal=c_metal, crystal=c_crystal, deuterium=0),
        up_deuturium=Cost(metal=d_metal, crystal=d_crystal, deuterium=0),
        up_solar=Cost(metal=s_metal, crystal=s_crystal, deuterium=0))
end
