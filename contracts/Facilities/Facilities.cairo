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
)
from contracts.Ogame.IOgame import IOgame

@external
func _shipyard_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt, time_unlocked : felt):
    alloc_locals
    assert_not_zero(caller)
    let (ogame_address) = _ogame_address.read()
    let (cue_status) = IOgame.get_buildings_timelock_status(ogame_address, caller)
    let current_timelock = cue_status.lock_end
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (planet_id) = IOgame.owner_of(ogame_address, caller)
    let (_, _, _, _, robot_factory_level, _, shipyard_level) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    let (metal_available, crystal_available, deuterium_available) = _get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = shipyard_upgrade_cost(
        shipyard_level
    )
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    let (building_time) = formulas_buildings_production_time(
        metal_required, crystal_required, robot_factory_level
    )
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time

    return (metal_required, crystal_required, deuterium_required, time_unlocked)
end

@external
func _shipyard_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (success : felt):
    alloc_locals
    let (ogame_address) = _ogame_address.read()
    let (is_qued) = IOgame.is_building_qued(ogame_address, caller, SHIPYARD_ID)
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
