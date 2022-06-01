%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from contracts.ResearchLab.library import (
    _ogame_address,
    research_lab_upgrade_cost,
    _energy_tech_upgrade_cost,
    _energy_tech_requirements_check,
    _computer_tech_upgrade_cost,
    _computer_tech_requirements_check,
    _laser_tech_requirements_check,
    _laser_tech_upgrade_cost,
    _armour_tech_requirements_check,
    _armour_tech_upgrade_cost,
    _ion_tech_requirements_check,
    _ion_tech_upgrade_cost,
    _espionage_tech_requirements_check,
    _espionage_tech_upgrade_cost,
    _plasma_tech_requirements_check,
    _plasma_tech_upgrade_cost,
    _weapons_tech_requirements_check,
    _weapons_tech_upgrade_cost,
    _shielding_tech_requirements_check,
    _shieldieng_tech_upgrade_cost,
    _hyperspace_tech_requirements_check,
    _hyperspace_tech_upgrade_cost,
    _astrophysics_requirements_check,
    _astrophysics_upgrade_cost,
    _combustion_drive_requirements_check,
    _combustion_drive_upgrade_cost,
    _hyperspace_drive_requirements_check,
    _hyperspace_drive_upgrade_cost,
    _impulse_drive_requirements_check,
    _impulse_drive_upgrade_cost,
    _get_available_resources,
    ResearchQue,
    research_timelock,
    research_qued,
    ENERGY_TECH_ID,
    COMPUTER_TECH_ID,
    LASER_TECH_ID,
    ARMOUR_TECH_ID,
    ION_TECH_ID,
    ESPIONAGE_TECH_ID,
    PLASMA_TECH_ID,
    WEAPONS_TECH_ID,
    SHIELDING_TECH_ID,
    HYPERSPACE_TECH_ID,
    ASTROPHYSICS_TECH_ID,
    COMBUSTION_DRIVE_ID,
    HYPERSPACE_DRIVE_ID,
    IMPULSE_DRIVE_ID,
    _reset_research_que,
    _reset_research_timelock,
    _check_lab_que_not_busy,
    _check_enough_resources,
    _set_research_timelock_and_que,
    _check_trying_to_complete_the_right_tech,
    _check_waited_enough,
)
from contracts.ResourcesManager import _pay_resources_erc20
from contracts.Ogame.IOgame import IOgame
from contracts.Ogame.library import _check_que_not_busy
from contracts.utils.Formulas import formulas_buildings_production_time
from contracts.utils.constants import RESEARCH_LAB_BUILDING_ID, UINT256_DECIMALS, TRUE

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
) -> (metal : felt, crystal : felt, deuterium : felt, time_unlocked : felt):
    alloc_locals
    assert_not_zero(caller)
    let (ogame_address) = _ogame_address.read()
    _check_que_not_busy(ogame_address, caller)
    let (planet_id) = IOgame.owner_of(ogame_address, caller)
    let (tech_levels) = IOgame.get_tech_levels(ogame_address, caller)
    let (_, _, _, _, robot_factory_level, _, _) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    let current_lab_level = tech_levels.research_lab
    let (metal_required, crystal_required, deuterium_required) = research_lab_upgrade_cost(
        current_lab_level
    )
    let (building_time) = formulas_buildings_production_time(
        metal_required, crystal_required, robot_factory_level
    )
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time

    return (metal_required, crystal_required, deuterium_required, time_unlocked)
end

@external
func _research_lab_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    let (ogame_address) = _ogame_address.read()
    let (is_qued) = IOgame.is_building_qued(ogame_address, caller, RESEARCH_LAB_BUILDING_ID)
    with_attr error_message("Tried to complete the wrong structure"):
        assert is_qued = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (planet_id) = IOgame.owner_of(ogame_address, caller)
    let (cue_details) = IOgame.get_buildings_timelock_status(ogame_address, caller)
    let timelock_end = cue_details.lock_end
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    return (TRUE)
end

@external
func _energy_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _energy_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _energy_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, ENERGY_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _energy_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, ENERGY_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, ENERGY_TECH_ID)
    return (TRUE)
end

@external
func _computer_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _computer_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _computer_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, COMPUTER_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _computer_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, COMPUTER_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, COMPUTER_TECH_ID)
    return (TRUE)
end

@external
func _laser_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _laser_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _laser_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, LASER_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _laser_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, LASER_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, LASER_TECH_ID)
    return (TRUE)
end

@external
func _armour_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _armour_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _armour_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, ARMOUR_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _armour_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, ARMOUR_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, ARMOUR_TECH_ID)
    return (TRUE)
end

@external
func _ion_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _ion_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _ion_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, ION_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _ion_tech_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, ION_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, ION_TECH_ID)
    return (TRUE)
end

@external
func _espionage_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _espionage_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _espionage_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, ESPIONAGE_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _espionage_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, ESPIONAGE_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, ESPIONAGE_TECH_ID)
    return (TRUE)
end

@external
func _plasma_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _plasma_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _plasma_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, PLASMA_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _plasma_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, PLASMA_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, PLASMA_TECH_ID)
    return (TRUE)
end

@external
func _weapons_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _weapons_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _weapons_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, WEAPONS_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _weapons_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, WEAPONS_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, WEAPONS_TECH_ID)
    return (TRUE)
end

@external
func _shielding_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _shieldieng_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _shielding_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, SHIELDING_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _shielding_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, SHIELDING_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, SHIELDING_TECH_ID)
    return (TRUE)
end

@external
func _hyperspace_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _hyperspace_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _hyperspace_tech_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, HYPERSPACE_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _hyperspace_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, HYPERSPACE_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, HYPERSPACE_TECH_ID)
    return (TRUE)
end

@external
func _astrophysics_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _astrophysics_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _astrophysics_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, ASTROPHYSICS_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _astrophysics_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, ASTROPHYSICS_TECH_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, ASTROPHYSICS_TECH_ID)
    return (TRUE)
end

@external
func _combustion_drive_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _combustion_drive_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _combustion_drive_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, COMBUSTION_DRIVE_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _combustion_drive_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, COMBUSTION_DRIVE_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, COMBUSTION_DRIVE_ID)
    return (TRUE)
end

@external
func _hyperspace_drive_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _hyperspace_drive_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _hyperspace_drive_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, HYPERSPACE_DRIVE_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _hyperspace_drive_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, HYPERSPACE_DRIVE_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, HYPERSPACE_DRIVE_ID)
    return (TRUE)
end

@external
func _impulse_drive_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _impulse_drive_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    _check_lab_que_not_busy(caller)
    _impulse_drive_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_research_timelock_and_que(
        caller, IMPULSE_DRIVE_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _impulse_drive_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_tech(caller, IMPULSE_DRIVE_ID)
    _check_waited_enough(caller)
    _reset_research_timelock(caller)
    _reset_research_que(caller, IMPULSE_DRIVE_ID)
    return (TRUE)
end
