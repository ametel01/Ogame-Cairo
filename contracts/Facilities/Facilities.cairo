%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE
from contracts.utils.formulas import Formulas
from contracts.Facilities.library import Facilities, _ogame_address
from contracts.Ogame.IOgame import IOgame

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ogame_address : felt
):
    _ogame_address.write(ogame_address)
    return ()
end

@external
func _shipyard_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt, time_unlocked : felt):
    alloc_locals
    assert_not_zero(caller)
    Facilities.check_building_que_not_busy(caller)
    Facilities.shipyard_requirements_check(caller)
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, robot_factory_level, _, shipyard_level, _) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    let (metal_required, crystal_required, deuterium_required) = Facilities.shipyard_upgrade_cost(
        shipyard_level
    )
    Facilities.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    let (time_unlocked) = Facilities.set_timelock_and_que(
        caller, Facilities.SHIPYARD_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required, time_unlocked)
end

@external
func _shipyard_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (success : felt):
    alloc_locals
    Facilities.check_trying_to_complete_the_right_facility(caller, Facilities.SHIPYARD_ID)
    Facilities.check_waited_enough(caller)
    Facilities.reset_que(caller, Facilities.SHIPYARD_ID)
    Facilities.reset_timelock(caller)
    return (TRUE)
end

@external
func _robot_factory_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (metal : felt, crystal : felt, deuterium : felt, time_unlocked : felt):
    alloc_locals
    assert_not_zero(caller)
    Facilities.check_building_que_not_busy(caller)
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, robot_factory_level, _, _, _) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    let (
        metal_required, crystal_required, deuterium_required
    ) = Facilities.robot_factory_upgrade_cost(robot_factory_level)
    Facilities.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    let (time_unlocked) = Facilities.set_timelock_and_que(
        caller, Facilities.ROBOT_FACTORY_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required, time_unlocked)
end

@external
func _robot_factory_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    Facilities.check_trying_to_complete_the_right_facility(caller, Facilities.ROBOT_FACTORY_ID)
    Facilities.check_waited_enough(caller)
    Facilities.reset_que(caller, Facilities.ROBOT_FACTORY_ID)
    Facilities.reset_timelock(caller)
    return (TRUE)
end

@external
func _research_lab_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt, time_unlocked : felt):
    alloc_locals
    assert_not_zero(caller)
    Facilities.check_building_que_not_busy(caller)
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, robot_factory_level, research_lab_level, _, _) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    let (
        metal_required, crystal_required, deuterium_required
    ) = Facilities.research_lab_upgrade_cost(research_lab_level)
    Facilities.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    let (time_unlocked) = Facilities.set_timelock_and_que(
        caller, Facilities.RESEARCH_LAB_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required, time_unlocked)
end

@external
func _research_lab_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    Facilities.check_trying_to_complete_the_right_facility(caller, Facilities.RESEARCH_LAB_ID)
    Facilities.check_waited_enough(caller)
    Facilities.reset_que(caller, Facilities.RESEARCH_LAB_ID)
    Facilities.reset_timelock(caller)
    return (TRUE)
end

@external
func _nanite_factory_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (metal : felt, crystal : felt, deuterium : felt, time_unlocked : felt):
    alloc_locals
    assert_not_zero(caller)
    Facilities.check_building_que_not_busy(caller)
    Facilities.nanite_factory_requirements_check(caller)
    let (ogame_address) = _ogame_address.read()
    let (
        _, _, _, _, robot_factory_level, _, _, nanite_factory_level
    ) = IOgame.get_structures_levels(ogame_address, caller)
    let (
        metal_required, crystal_required, deuterium_required
    ) = Facilities.nanite_factory_upgrade_cost(nanite_factory_level)
    Facilities.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    let (time_unlocked) = Facilities.set_timelock_and_que(
        caller, Facilities.NANITE_FACTORY_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required, time_unlocked)
end

@external
func _nanite_factory_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    Facilities.check_trying_to_complete_the_right_facility(caller, Facilities.NANITE_FACTORY_ID)
    Facilities.check_waited_enough(caller)
    Facilities.reset_que(caller, Facilities.NANITE_FACTORY_ID)
    Facilities.reset_timelock(caller)
    return (TRUE)
end
