%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from contracts.Resources.library import Resources, _ogame_address
from contracts.Ogame.IOgame import IOgame
from contracts.utils.formulas import Formulas

@external
func _metal_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt, time_unlocked : felt):
    alloc_locals
    assert_not_zero(caller)
    Resources.check_que_not_busy(caller)
    let (ogame_address) = _ogame_address.read()
    let (
        metal_level, _, _, _, robot_factory_level, _, _, nanite_level
    ) = IOgame.get_structures_levels(ogame_address, caller)
    let (metal_required, crystal_required, deuterium_required) = Formulas.metal_building_cost(
        metal_level
    )
    Resources.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    let (time_unlocked) = Resources.set_timelock_and_que(
        caller, Resources.METAL_MINE_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required, time_unlocked)
end

@external
func _metal_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (success : felt):
    alloc_locals
    Resources.check_trying_to_complete_the_right_resource(caller, Facilities.SHIPYARD_ID)
    Resources.check_waited_enough(caller)
    Resources.reset_que(caller, Resources.METAL_MINE_ID)
    Resources.reset_timelock(caller)
    return (TRUE)
end
