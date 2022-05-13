%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from contracts.Ogame.IOgame import IOgame
from contracts.utils.constants import TRUE

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

# func _check_enough_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     caller : felt, metal_required : felt, crystal_required : felt, deuterium_required : felt
# ):
#     let (metal_available, crystal_available, deuterium_available) = _get_available_resources(caller)
#     with_attr error_message("not enough resources"):
#         let (enough_metal) = is_le(metal_required, metal_available)
#         assert enough_metal = TRUE
#         let (enough_crystal) = is_le(crystal_required, crystal_available)
#         assert enough_crystal = TRUE
#         let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
#         assert enough_deuterium = TRUE
#     end
#     return ()
# end

# func _get_available_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     caller : felt,
# ) -> (metal : felt, crystal : felt, deuterium : felt):
#     let (ogame_address) = _ogame_address.read()
#     let (metal_address) = IOgame.metal_address(ogame_address)
#     let (crystal_address) = IOgame.crystal_address(ogame_address)
#     let (deuterium_address) = IOgame.deuterium_address(ogame_address)
#     let (metal_available) = IERC20.balanceOf(metal_address, caller)
#     let (crystal_available) = IERC20.balanceOf(crystal_address, caller)
#     let (deuterium_available) = IERC20.balanceOf(deuterium_address, caller)
#     return (metal_available.low, crystal_available.low, deuterium_available.low)
# end
