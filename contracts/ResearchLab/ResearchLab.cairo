%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from contracts.ResearchLab.library import _ogame_address, ResearchLab
from contracts.ResourcesManager import _pay_resources_erc20
from contracts.Ogame.IOgame import IOgame
from contracts.Ogame.library import _check_que_not_busy
from contracts.utils.formulas import Formulas

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ogame_address : felt
):
    _ogame_address.write(ogame_address)
    return ()
end

# ######### UPGRADES FUNCS ############################

@external
func _energy_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.energy_tech_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.energy_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.ENERGY_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _energy_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.ENERGY_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.ENERGY_TECH_ID)
    return (TRUE)
end

@external
func _computer_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.computer_tech_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.computer_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.COMPUTER_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _computer_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.COMPUTER_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.COMPUTER_TECH_ID)
    return (TRUE)
end

@external
func _laser_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.laser_tech_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.laser_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.LASER_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _laser_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.LASER_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.LASER_TECH_ID)
    return (TRUE)
end

@external
func _armour_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.armour_tech_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.armour_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.ARMOUR_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _armour_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.ARMOUR_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.ARMOUR_TECH_ID)
    return (TRUE)
end

@external
func _ion_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = ResearchLab.ion_tech_upgrade_cost(
        current_tech_level
    )
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.ion_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.ION_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _ion_tech_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.ION_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.ION_TECH_ID)
    return (TRUE)
end

@external
func _espionage_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.espionage_tech_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.espionage_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.ESPIONAGE_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _espionage_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.ESPIONAGE_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.ESPIONAGE_TECH_ID)
    return (TRUE)
end

@external
func _plasma_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.plasma_tech_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.plasma_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.PLASMA_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _plasma_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.PLASMA_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.PLASMA_TECH_ID)
    return (TRUE)
end

@external
func _weapons_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.weapons_tech_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.weapons_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.WEAPONS_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _weapons_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.WEAPONS_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.WEAPONS_TECH_ID)
    return (TRUE)
end

@external
func _shielding_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.shieldieng_tech_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.shielding_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.SHIELDING_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _shielding_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.SHIELDING_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.SHIELDING_TECH_ID)
    return (TRUE)
end

@external
func _hyperspace_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.hyperspace_tech_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.hyperspace_tech_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.HYPERSPACE_TECH_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _hyperspace_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.HYPERSPACE_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.HYPERSPACE_TECH_ID)
    return (TRUE)
end

@external
func _astrophysics_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.astrophysics_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.astrophysics_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller,
        ResearchLab.ASTROPHYSICS_TECH_ID,
        metal_required,
        crystal_required,
        deuterium_required,
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _astrophysics_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.ASTROPHYSICS_TECH_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.ASTROPHYSICS_TECH_ID)
    return (TRUE)
end

@external
func _combustion_drive_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.combustion_drive_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.combustion_drive_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller,
        ResearchLab.COMBUSTION_DRIVE_ID,
        metal_required,
        crystal_required,
        deuterium_required,
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _combustion_drive_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.COMBUSTION_DRIVE_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.COMBUSTION_DRIVE_ID)
    return (TRUE)
end

@external
func _hyperspace_drive_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.hyperspace_drive_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.hyperspace_drive_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller,
        ResearchLab.HYPERSPACE_DRIVE_ID,
        metal_required,
        crystal_required,
        deuterium_required,
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _hyperspace_drive_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.HYPERSPACE_DRIVE_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.HYPERSPACE_DRIVE_ID)
    return (TRUE)
end

@external
func _impulse_drive_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (
        metal_required, crystal_required, deuterium_required
    ) = ResearchLab.impulse_drive_upgrade_cost(current_tech_level)
    assert_not_zero(caller)
    ResearchLab.check_que_not_busy(caller)
    ResearchLab.impulse_drive_requirements_check(caller)
    ResearchLab.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    ResearchLab.set_timelock_and_que(
        caller, ResearchLab.IMPULSE_DRIVE_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _impulse_drive_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    ResearchLab.check_trying_complete_right_tech(caller, ResearchLab.IMPULSE_DRIVE_ID)
    ResearchLab.check_waited_enough(caller)
    ResearchLab.reset_timelock(caller)
    ResearchLab.reset_que(caller, ResearchLab.IMPULSE_DRIVE_ID)
    return (TRUE)
end
