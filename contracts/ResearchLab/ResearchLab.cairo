%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from contracts.ResearchLab.library import (
    _ogame_address,
    research_lab_upgrade_cost,
    energy_tech_upgrade_cost,
    get_available_resources,
    ResearchQue,
    research_timelock,
    research_qued,
)
from contracts.utils.constants import TRUE
from contracts.token.erc20.interfaces.IERC20 import IERC20
from contracts.ResourcesManager import _pay_resources_erc20
from contracts.Ogame.IOgame import IOgame
from contracts.utils.Formulas import formulas_buildings_production_time
from contracts.utils.constants import RESEARCH_LAB_BUILDING_ID, UINT256_DECIMALS

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ogame_address : felt
):
    _ogame_address.write(ogame_address)
    return ()
end

# ######### UPGRADES FUNCS ############################
@external
func _research_lab_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (cue_status) = buildings_timelock.read(caller)
    let current_timelock = cue_status.lock_end
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (ogame_address) = _ogame_address.read()
    let (planet_id) = IOgame.owner_of(ogame_address, caller)
    let (current_level) = _research_lab_level.read(planet_id)
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = research_lab_upgrade_cost(
        current_level
    )
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (building_time) = formulas_buildings_production_time(
        metal_required, crystal_required, deuterium_required
    )
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time
    let cue_details = BuildingQue(RESEARCH_LAB_BUILDING_ID, time_unlocked)
    buildings_timelock.write(caller, cue_details)
    building_qued.write(caller, RESEARCH_LAB_BUILDING_ID, TRUE)

    return (metal_required, crystal_required, deuterium_required)
end

@external
func _research_lab_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    let (is_qued) = building_qued.read(caller, RESEARCH_LAB_BUILDING_ID)
    with_attr error_message("Tryed to complete the wrong structure"):
        assert is_qued = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (planet_id) = IOgame.owner_of(ogame_address, caller)
    let (cue_details) = buildings_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    let (current_lab_level) = _research_lab_level.read(planet_id)
    _research_lab_level.write(planet_id, current_lab_level + 1)
    return (TRUE)
end

func _energy_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (success : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = energy_tech_upgrade_cost(
        current_tech_level
    )
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(caller)
    let (requirements_met) = energy_tech_requirements_check(research_lab_level)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    return (TRUE)
end

func _energy_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level) -> (success : felt):
    return (TRUE)
end
