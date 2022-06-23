%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from starkware.cairo.common.pow import pow
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_le
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.Ogame.IOgame import IOgame
from contracts.Tokens.erc20.interfaces.IERC20 import IERC20
from contracts.utils.Formulas import formulas_buildings_production_time
from contracts.ResearchLab.library import _get_tech_levels

##############################################################################################
#                                   CONSTANTS                                                #
# ############################################################################################

const ROBOT_FACTORY_ID = 21
const SHIPYARD_ID = 22
const RESEARCH_LAB_ID = 23
const NANITE_FACTORY_ID = 24

##############################################################################################
#                                   STRUCTS                                                  #
# ############################################################################################

struct FacilitiesQue:
    member facility_id : felt
    member lock_end : felt
end

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

@storage_var
func facilities_timelock(address : felt) -> (cued_details : FacilitiesQue):
end

# @dev Stores the que status for a specific ship.
@storage_var
func facility_qued(address : felt, id : felt) -> (is_qued : felt):
end

# ###################################################################################################
#                                FACILITIES REQUIREMENTS CHECHS                                     #
#####################################################################################################

func _shipyard_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, robot_factory_level, _, _, _) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    with_attr error_message("FACILITIES::ROBOT FACTORY MUST BE AT LEVEL 2"):
        assert_le(2, robot_factory_level)
    end
    return (TRUE)
end

func _nanite_factory_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, robot_factory_level, _, _, _) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    let (tech_levels) = _get_tech_levels(caller)
    with_attr error_message("FACILITIES::ROBOT FACTORY MUST BE AT LEVEL 10"):
        assert_le(10, robot_factory_level)
    end
    with_attr error_message("FACILITIES::COMPUTER TECH MUST BE AT LEVEL 10"):
        assert_le(10, tech_levels.computer_tech)
    end
    return (TRUE)
end

# ###################################################################################################
#                                FACILITIES COST CALCULATION                                        #
#####################################################################################################

func robot_factory_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 400
    let base_crystal = 120
    let base_deuterium = 200
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
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

func research_lab_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 200
    let base_crystal = 400
    let base_deuterium = 200
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func nanite_factory_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 1000000
    let base_crystal = 500000
    let base_deuterium = 100000
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

##############################################################################################
#                                   TO BE MOVED TO A GENERALISED LIB                         #
# ############################################################################################

func _get_available_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let (ogame_address) = _ogame_address.read()
    let (metal_address) = IOgame.get_metal_address(ogame_address)
    let (crystal_address) = IOgame.get_crystal_address(ogame_address)
    let (deuterium_address) = IOgame.get_deuterium_address(ogame_address)
    let (metal_available) = IERC20.balanceOf(metal_address, caller)
    let (crystal_available) = IERC20.balanceOf(crystal_address, caller)
    let (deuterium_available) = IERC20.balanceOf(deuterium_address, caller)
    return (metal_available.low, crystal_available.low, deuterium_available.low)
end

func _check_enough_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, metal_required : felt, crystal_required : felt, deuterium_required : felt
):
    alloc_locals
    let (metal_available, crystal_available, deuterium_available) = _get_available_resources(caller)
    with_attr error_message("FACILITIES::NOT ENOUGH RESOURCES!!!"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    return ()
end

func _reset_facilities_timelock{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
):
    facilities_timelock.write(address, FacilitiesQue(0, 0))
    return ()
end

func _reset_facilities_que{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, building_id : felt
):
    facility_qued.write(address, building_id, FALSE)
    return ()
end

func _check_building_que_not_busy{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt):
    let (que_status) = facilities_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("FACILITIES::QUE IS BUSY!!!"):
        assert current_timelock = 0
    end
    return ()
end

func _check_trying_to_complete_the_right_facility{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, BUILDING_ID : felt):
    let (is_qued) = facility_qued.read(caller, BUILDING_ID)
    with_attr error_message("FACILITIES::TRIED TO COMPLETE THE WRONG FACILITY!!!"):
        assert is_qued = TRUE
    end
    return ()
end

func _check_waited_enough{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (que_details) = facilities_timelock.read(caller)
    let timelock_end = que_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("FACILITIES::TIMELOCK NOT YET EXPIRED!!!"):
        assert waited_enough = TRUE
    end
    return ()
end

func _set_facilities_timelock_and_que{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(
    caller : felt,
    BUILDING_ID : felt,
    metal_required : felt,
    crystal_required : felt,
    deuterium_required : felt,
) -> (time_unlocked : felt):
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, robot_factory_level, _, _, _) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    let (build_time) = formulas_buildings_production_time(
        metal_required, crystal_required, robot_factory_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + build_time
    let que_details = FacilitiesQue(BUILDING_ID, time_end)
    facility_qued.write(caller, BUILDING_ID, TRUE)
    facilities_timelock.write(caller, que_details)
    return (time_end)
end
