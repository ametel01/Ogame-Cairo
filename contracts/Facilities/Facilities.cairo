%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE
from contracts.utils.Formulas import formulas_buildings_production_time
from contracts.Facilities.library import (
    _ogame_address,
    FacilitiesQue,
    facilities_timelock,
    facility_qued,
    _get_available_resources,
    shipyard_upgrade_cost,
    SHIPYARD_ID,
    _check_enough_resources,
    _check_building_que_not_busy,
    _set_facilities_timelock_and_que,
    _check_trying_to_complete_the_right_facility,
    _check_waited_enough,
)
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
    _check_building_que_not_busy(caller)
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, robot_factory_level, _, shipyard_level) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    let (metal_required, crystal_required, deuterium_required) = shipyard_upgrade_cost(
        shipyard_level
    )
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    let (time_unlocked) = _set_facilities_timelock_and_que(
        caller, SHIPYARD_ID, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required, time_unlocked)
end

@external
func _shipyard_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_facility(caller, SHIPYARD_ID)
    _check_waited_enough(caller)
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
