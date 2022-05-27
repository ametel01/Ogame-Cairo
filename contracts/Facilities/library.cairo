%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.pow import pow
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE
from contracts.Ogame.IOgame import IOgame
from contracts.token.erc20.interfaces.IERC20 import IERC20

##############################################################################################
#                                   CONSTANTS                                                #
# ############################################################################################

const ROBOT_FACTORY_ID = 11
const SHIPYARD_ID = 12
const RESEARCH_LAB_ID = 13
const NANITE_FACTORY_ID = 14

##############################################################################################
#                                   STORAGE                                                  #
# ############################################################################################

@storage_var
func _ogame_address() -> (address : felt):
end

@storage_var
func metal_address() -> (address : felt):
end

@storage_var
func crystal_address() -> (address : felt):
end

@storage_var
func deuterium_address() -> (address : felt):
end

func _get_available_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let (ogame_address) = _ogame_address.read()
    let (metal_address) = IOgame.metal_address(ogame_address)
    let (crystal_address) = IOgame.crystal_address(ogame_address)
    let (deuterium_address) = IOgame.deuterium_address(ogame_address)
    let (metal_available) = IERC20.balanceOf(metal_address, caller)
    let (crystal_available) = IERC20.balanceOf(crystal_address, caller)
    let (deuterium_available) = IERC20.balanceOf(deuterium_address, caller)
    return (metal_available.low, crystal_available.low, deuterium_available.low)
end

func shipyard_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 400
    let base_crystal = 200
    let base_deuterium = 100
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func _check_enough_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, metal_required : felt, crystal_required : felt, deuterium_required : felt
):
    alloc_locals
    let (metal_available, crystal_available, deuterium_available) = _get_available_resources(caller)
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    return ()
end
