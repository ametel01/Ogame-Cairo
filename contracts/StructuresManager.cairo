%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_le
from starkware.cairo.common.uint256 import Uint256, uint256_le
from contracts.utils.constants import (
    FALSE,
    TRUE,
    METAL_BUILDING_ID,
    CRYSTAL_BUILDING_ID,
    DEUTERIUM_BUILDING_ID,
    SOLAR_PLANT_BUILDING_ID,
)
from starkware.cairo.common.math_cmp import is_le
from contracts.Tokens.erc721.interfaces.IERC721 import IERC721
from contracts.Tokens.erc20.interfaces.IERC20 import IERC20
from contracts.ResourcesManager import _receive_resources_erc20, _pay_resources_erc20
from starkware.starknet.common.syscalls import (
    get_block_timestamp,
    get_contract_address,
    get_caller_address,
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
    formulas_robot_factory_building,
    _consumption,
    _consumption_deuterium,
    _production_limiter,
    formulas_production_scaler,
    formulas_buildings_production_time,
)
from contracts.utils.library import (
    _planet_to_owner,
    _number_of_planets,
    _planets,
    erc721_token_address,
    planet_genereted,
    structure_updated,
    buildings_timelock,
    _get_planet,
    reset_timelock,
    building_qued,
    reset_building_que,
    _players_spent_resources,
    erc20_metal_address,
    erc20_crystal_address,
)
from contracts.Ogame.structs import MineLevels, Cost, Planet, Energy, Facilities, BuildingQue
from contracts.Ogame.storage import _resources_timer
from contracts.Ogame.library import _check_que_not_busy

# Used to create the first planet for a player. It does register the new planet in the contract storage
# and send the NFT to the caller. At the moment planets IDs are incremental +1. TODO: implement a
# random ID generator.
func _generate_planet{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
):
    alloc_locals
    let (time_now) = get_block_timestamp()
    # One address can only have one planet at this stage.
    let (has_already_planet) = _planet_to_owner.read(caller)
    assert has_already_planet = Uint256(0, 0)
    let planet = Planet(
        MineLevels(metal=0, crystal=0, deuterium=0),
        Energy(solar_plant=0),
        Facilities(robot_factory=0),
    )
    # Transfer ERC721 to caller
    let (erc721_address) = erc721_token_address.read()
    let (last_id) = _number_of_planets.read()
    let new_id = last_id + 1
    let new_planet_id = Uint256(new_id, 0)
    _resources_timer.write(new_planet_id, 0)
    let (erc721_owner) = IERC721.ownerOf(erc721_address, new_planet_id)
    IERC721.transferFrom(erc721_address, erc721_owner, caller, new_planet_id)
    _planet_to_owner.write(caller, new_planet_id)
    _planets.write(new_planet_id, planet)
    _number_of_planets.write(new_id)
    planet_genereted.emit(new_planet_id)
    # Transfer resources ERC20 tokens to caller.
    _receive_resources_erc20(to=caller, metal_amount=500, crystal_amount=300, deuterium_amount=100)
    return ()
end

func _start_metal_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    ):
    alloc_locals
    let (address) = get_caller_address()
    let (cue_status) = buildings_timelock.read(address)
    let current_timelock = cue_status.lock_end
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (contract) = get_contract_address()
    let (local planet) = _get_planet()
    let current_mine_level = planet.mines.metal
    let (metal_required, crystal_required) = formulas_metal_building(
        metal_mine_level=current_mine_level
    )
    let (building_time) = formulas_buildings_production_time(metal_required, crystal_required, 0)
    let (metal_address) = erc20_metal_address.read()
    let (metal_available) = IERC20.balanceOf(metal_address, address)
    let (crystal_address) = erc20_crystal_address.read()
    let (crystal_available) = IERC20.balanceOf(crystal_address, address)
    let (enough_metal) = uint256_le(Uint256(metal_required, 0), metal_available)
    let (enough_crystal) = uint256_le(Uint256(crystal_required, 0), crystal_available)
    with_attr error_message("Not enough resources"):
        assert enough_metal = TRUE
        assert enough_crystal = TRUE
    end
    let (spent_so_far) = _players_spent_resources.read(address)
    let new_total_spent = spent_so_far + metal_required + crystal_required
    _players_spent_resources.write(address, new_total_spent)
    _pay_resources_erc20(address, metal_required, crystal_required, deuterium_amount=0)
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    let cue_details = BuildingQue(METAL_BUILDING_ID, time_unlocked)
    buildings_timelock.write(address, cue_details)
    building_qued.write(address, METAL_BUILDING_ID, TRUE)
    return ()
end

func _end_metal_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (is_qued) = building_qued.read(address, 1)
    with_attr error_message("Tryed to complete the wrong structure"):
        assert is_qued = TRUE
    end
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let (cue_details) = buildings_timelock.read(address)
    let timelock_end = cue_details.lock_end
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let current_mine_level = planet.mines.metal
    let (metal_required, crystal_required) = formulas_metal_building(current_mine_level)
    let new_planet = Planet(
        MineLevels(metal=planet.mines.metal + 1,
        crystal=planet.mines.crystal,
        deuterium=planet.mines.deuterium),
        Energy(solar_plant=planet.energy.solar_plant),
        Facilities(robot_factory=planet.facilities.robot_factory),
    )
    _planets.write(planet_id, new_planet)
    reset_timelock(address)
    reset_building_que(address, 1)
    structure_updated.emit(metal_required, crystal_required, 0)
    return ()
end

func _start_crystal_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (cue_status) = buildings_timelock.read(address)
    let current_timelock = cue_status.lock_end
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (contract) = get_contract_address()
    let (local planet) = _get_planet()
    let current_mine_level = planet.mines.crystal
    let (metal_required, crystal_required) = formulas_crystal_building(current_mine_level)
    let (building_time) = formulas_buildings_production_time(metal_required, crystal_required, 0)
    let (metal_address) = erc20_metal_address.read()
    let (metal_available) = IERC20.balanceOf(metal_address, address)
    let (crystal_address) = erc20_crystal_address.read()
    let (crystal_available) = IERC20.balanceOf(crystal_address, address)
    let (enough_metal) = uint256_le(Uint256(metal_required, 0), metal_available)
    let (enough_crystal) = uint256_le(Uint256(crystal_required, 0), crystal_available)
    with_attr error_message("Not enough resources"):
        assert enough_metal = TRUE
        assert enough_crystal = TRUE
    end
    let (spent_so_far) = _players_spent_resources.read(address)
    let new_total_spent = spent_so_far + metal_required + crystal_required
    _players_spent_resources.write(address, new_total_spent)
    _pay_resources_erc20(address, metal_required, crystal_required, deuterium_amount=0)
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    let cue_details = BuildingQue(CRYSTAL_BUILDING_ID, time_unlocked)
    buildings_timelock.write(address, cue_details)
    building_qued.write(address, 2, TRUE)
    return ()
end

func _end_crystal_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (is_qued) = building_qued.read(address, 2)
    with_attr error_message("Tryed to complete the wrong structure"):
        assert is_qued = TRUE
    end
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let (cue_details) = buildings_timelock.read(address)
    let timelock_end = cue_details.lock_end
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let current_mine_level = planet.mines.crystal
    let (metal_required, crystal_required) = formulas_crystal_building(current_mine_level)
    let new_planet = Planet(
        MineLevels(metal=planet.mines.metal,
        crystal=planet.mines.crystal + 1,
        deuterium=planet.mines.deuterium),
        Energy(solar_plant=planet.energy.solar_plant),
        Facilities(robot_factory=planet.facilities.robot_factory),
    )
    _planets.write(planet_id, new_planet)
    reset_timelock(address)
    reset_building_que(address, 2)
    structure_updated.emit(metal_required, crystal_required, 0)
    return ()
end

func _start_deuterium_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (cue_status) = buildings_timelock.read(address)
    let current_timelock = cue_status.lock_end
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (contract) = get_contract_address()
    let (local planet) = _get_planet()
    let current_mine_level = planet.mines.deuterium
    let (metal_required, crystal_required) = formulas_deuterium_building(current_mine_level)
    let (building_time) = formulas_buildings_production_time(metal_required, crystal_required, 0)
    let (metal_address) = erc20_metal_address.read()
    let (metal_available) = IERC20.balanceOf(metal_address, address)
    let (crystal_address) = erc20_crystal_address.read()
    let (crystal_available) = IERC20.balanceOf(crystal_address, address)
    let (enough_metal) = uint256_le(Uint256(metal_required, 0), metal_available)
    let (enough_crystal) = uint256_le(Uint256(crystal_required, 0), crystal_available)
    with_attr error_message("Not enough resources"):
        assert enough_metal = TRUE
        assert enough_crystal = TRUE
    end
    let (spent_so_far) = _players_spent_resources.read(address)
    let new_total_spent = spent_so_far + metal_required + crystal_required
    _players_spent_resources.write(address, new_total_spent)
    _pay_resources_erc20(address, metal_required, crystal_required, deuterium_amount=0)
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    let cue_details = BuildingQue(DEUTERIUM_BUILDING_ID, time_unlocked)
    buildings_timelock.write(address, cue_details)
    building_qued.write(address, 3, TRUE)
    return ()
end

func _end_deuterium_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (is_qued) = building_qued.read(address, 3)
    with_attr error_message("Tryed to complete the wrong structure"):
        assert is_qued = TRUE
    end
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let (cue_details) = buildings_timelock.read(address)
    let timelock_end = cue_details.lock_end
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let current_mine_level = planet.mines.deuterium
    let (metal_required, crystal_required) = formulas_deuterium_building(current_mine_level)
    let new_planet = Planet(
        MineLevels(metal=planet.mines.metal,
        crystal=planet.mines.crystal,
        deuterium=planet.mines.deuterium + 1),
        Energy(solar_plant=planet.energy.solar_plant),
        Facilities(robot_factory=planet.facilities.robot_factory),
    )
    _planets.write(planet_id, new_planet)
    reset_timelock(address)
    reset_building_que(address, 3)
    structure_updated.emit(metal_required, crystal_required, 0)
    return ()
end

func _start_solar_plant_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    alloc_locals
    let (address) = get_caller_address()
    let (cue_status) = buildings_timelock.read(address)
    let current_timelock = cue_status.lock_end
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (contract) = get_contract_address()
    let (local planet) = _get_planet()
    let current_plant_level = planet.energy.solar_plant
    let (metal_required, crystal_required) = formulas_solar_plant_building(current_plant_level)
    let (building_time) = formulas_buildings_production_time(metal_required, crystal_required, 0)
    let (metal_address) = erc20_metal_address.read()
    let (metal_available) = IERC20.balanceOf(metal_address, address)
    let (crystal_address) = erc20_crystal_address.read()
    let (crystal_available) = IERC20.balanceOf(crystal_address, address)
    let (enough_metal) = uint256_le(Uint256(metal_required, 0), metal_available)
    let (enough_crystal) = uint256_le(Uint256(crystal_required, 0), crystal_available)
    with_attr error_message("Not enough resources"):
        assert enough_metal = TRUE
        assert enough_crystal = TRUE
    end
    let (spent_so_far) = _players_spent_resources.read(address)
    let new_total_spent = spent_so_far + metal_required + crystal_required
    _players_spent_resources.write(address, new_total_spent)
    _pay_resources_erc20(address, metal_required, crystal_required, deuterium_amount=0)
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    let cue_details = BuildingQue(SOLAR_PLANT_BUILDING_ID, time_unlocked)
    buildings_timelock.write(address, cue_details)
    building_qued.write(address, 4, TRUE)
    return ()
end

func _end_solar_plant_upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (address) = get_caller_address()
    let (is_qued) = building_qued.read(address, 4)
    with_attr error_message("Tryed to complete the wrong structure"):
        assert is_qued = TRUE
    end
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let (cue_details) = buildings_timelock.read(address)
    let timelock_end = cue_details.lock_end
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let current_plant_level = planet.energy.solar_plant
    let (metal_required, crystal_required) = formulas_solar_plant_building(current_plant_level)
    let new_planet = Planet(
        MineLevels(metal=planet.mines.metal,
        crystal=planet.mines.crystal,
        deuterium=planet.mines.deuterium),
        Energy(solar_plant=planet.energy.solar_plant + 1),
        Facilities(robot_factory=planet.facilities.robot_factory),
    )
    _planets.write(planet_id, new_planet)
    reset_timelock(address)
    reset_building_que(address, 4)
    structure_updated.emit(metal_required, crystal_required, 0)
    return ()
end

func get_upgrades_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (
    up_metal : Cost,
    up_crystal : Cost,
    up_deuturium : Cost,
    up_solar : Cost,
    up_robot_factory : Cost,
):
    alloc_locals
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    let metal_level = planet.mines.metal
    let crystal_level = planet.mines.crystal
    let deuterium_level = planet.mines.deuterium
    let solar_plant_level = planet.energy.solar_plant
    let robot_factory_level = planet.facilities.robot_factory
    let (m_metal, m_crystal) = formulas_metal_building(metal_level)
    let (c_metal, c_crystal) = formulas_crystal_building(crystal_level)
    let (d_metal, d_crystal) = formulas_deuterium_building(deuterium_level)
    let (s_metal, s_crystal) = formulas_solar_plant_building(solar_plant_level)
    let (r_metal, r_crystal, r_deuterium) = formulas_robot_factory_building(robot_factory_level)
    return (
        Cost(m_metal, m_crystal, 0),
        Cost(c_metal, c_crystal, 0),
        Cost(d_metal, d_crystal, 0),
        Cost(s_metal, s_crystal, 0),
        Cost(r_metal, r_crystal, r_deuterium),
    )
end
