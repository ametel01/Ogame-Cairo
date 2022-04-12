%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_block_timestamp, get_contract_address, get_caller_address)
from starkware.cairo.common.uint256 import Uint256, uint256_le
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_not_zero, assert_le
from contracts.token.erc20.interfaces.IERC20 import IERC20
from contracts.ResourcesManager import _pay_resources_erc20
from contracts.utils.constants import ROBOT_FACTORY_BUILDING_ID
from contracts.utils.library import (
    Cost, _planet_to_owner, _number_of_planets, _planets, Planet, MineLevels, MineStorage, Energy,
    Facilities, BuildingQue, erc721_token_address, planet_genereted, structure_updated,
    buildings_timelock, building_qued, _get_planet, reset_timelock, reset_building_que,
    erc20_metal_address, erc20_crystal_address, erc20_deuterium_address, TRUE)
from contracts.utils.Formulas import (
    formulas_robot_factory_building, formulas_buildings_production_time)

func _start_robot_factory_upgrade{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (end_time : felt):
    alloc_locals
    let (address) = get_caller_address()
    let (que_details) = buildings_timelock.read(address)
    let current_timelock = que_details.lock_end
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (contract) = get_contract_address()
    let (local planet) = _get_planet()
    let current_factory_level = planet.facilities.robot_factory
    let (metal_required, crystal_required, deuterium_required) = formulas_robot_factory_building(
        current_factory_level)
    let (building_time) = formulas_buildings_production_time(
        metal_required, crystal_required, deuterium_required)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    let deuterium_available = planet.storage.deuterium
    with_attr error_message("Not enough resources"):
        assert_le(metal_required, metal_available)
        assert_le(crystal_required, crystal_available)
        assert_le(deuterium_required, deuterium_available)
    end
    _pay_resources_erc20(address, metal_required, crystal_required, deuterium_required)
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    buildings_timelock.write(address, BuildingQue(ROBOT_FACTORY_BUILDING_ID, time_unlocked))
    building_qued.write(address, 5, TRUE)
    return (time_unlocked)
end

func _end_robot_factory_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
    alloc_locals
    let (address) = get_caller_address()
    let (is_qued) = building_qued.read(address, 5)
    assert is_qued = TRUE
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let (que_details) = buildings_timelock.read(address)
    let timelock_end = que_details.lock_end
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let current_factory_level = planet.facilities.robot_factory
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    let (metal_required, crystal_required, deuterium_required) = formulas_robot_factory_building(
        current_factory_level)
    let new_planet = Planet(
        MineLevels(metal=planet.mines.metal,
        crystal=planet.mines.crystal,
        deuterium=planet.mines.deuterium),
        MineStorage(metal=metal_available - metal_required,
        crystal=crystal_available - crystal_required,
        deuterium=planet.storage.deuterium),
        Energy(solar_plant=planet.energy.solar_plant),
        Facilities(robot_factory=planet.facilities.robot_factory + 1),
        timer=planet.timer)
    _planets.write(planet_id, new_planet)
    reset_timelock(address)
    reset_building_que(address, 5)
    structure_updated.emit(metal_required, crystal_required, deuterium_required)
    return ()
end
