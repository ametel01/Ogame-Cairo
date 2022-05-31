%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from contracts.Ogame.IOgame import IOgame
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.Ogame.storage import buildings_timelock, building_qued
from contracts.Ogame.structs import BuildingQue

func _check_que_not_busy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ogame_address : felt, caller : felt
):
    let (cue_status) = IOgame.get_buildings_timelock_status(ogame_address, caller)
    let current_timelock = cue_status.lock_end
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    return ()
end

func reset_timelock{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
):
    buildings_timelock.write(address, BuildingQue(0, 0))
    return ()
end

func reset_building_que{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, id : felt
):
    building_qued.write(address, id, FALSE)
    return ()
end
