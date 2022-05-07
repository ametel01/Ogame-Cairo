%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_le
from starkware.cairo.common.pow import pow
from contracts.utils.constants import TRUE, FALSE
from contracts.Ogame.IOgame import IOgame
from contracts.token.erc20.interfaces.IERC20 import IERC20
from contracts.Ogame.structs import TechLevels

#########################################################################################
#                                           CONSTANTS                                   #
#########################################################################################
const ENERGY_TECH_ID = 11
const COMPUTER_TECH_ID = 12
const LASER_TECH_ID = 13
const ARMOUR_TECH_ID = 14
const ESPIONAGE_TECH_ID = 15
const ION_TECH_ID = 16
const PLASMA_TECH_ID = 17

#########################################################################################
#                                           STRUCTS                                     #
#########################################################################################

struct ResearchQue:
    member tech_id : felt
    member lock_end : felt
end

#########################################################################################
#                                           STORAGES                                    #
#########################################################################################

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

# @dev Stores the timestamp of the end of the timelock for buildings upgrades.
# @params The address of the player.
@storage_var
func research_timelock(address : felt) -> (cued_details : ResearchQue):
end

# @dev Stores the que status for a specific tech. IDs:
# 1-metal mine, 2-crystal-mine, 3-deuterium mine, 4-solar plant, 5-robot factory
@storage_var
func research_qued(address : felt, id : felt) -> (is_qued : felt):
end

# ###################################################################################################
#                                GENERAL TECH COST FUNCS                                            #
#####################################################################################################
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

func energy_tech_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 0
    let base_crystal = 800
    let base_deuterium = 400
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func computer_tech_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 0
    let base_crystal = 400
    let base_deuterium = 600
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func laser_tech_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 200
    let base_crystal = 100
    let base_deuterium = 0
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func armour_tech_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 1000
    let base_crystal = 0
    let base_deuterium = 0
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func espionage_tech_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 200
    let base_crystal = 1000
    let base_deuterium = 200
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func ion_tech_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 1000
    let base_crystal = 300
    let base_deuterium = 1000
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func plasma_tech_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 2000
    let base_crystal = 4000
    let base_deuterium = 1000
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func astrophysics_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 4000
    let base_crystal = 8000
    let base_deuterium = 4000
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func weaponst_tech_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 800
    let base_crystal = 200
    let base_deuterium = 0
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func shieldieng_tech_upgrade_cost{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(current_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 200
    let base_crystal = 600
    let base_deuterium = 0
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func hyperspace_tech_upgrade_cost{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(current_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 0
    let base_crystal = 4000
    let base_deuterium = 2000
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

# ################################## ENGINES #########################################
func combustion_drive_upgrade_cost{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(current_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 400
    let base_crystal = 0
    let base_deuterium = 600
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func impulse_drive_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 2000
    let base_crystal = 4000
    let base_deuterium = 600
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func hyperspace_drive_upgrade_cost{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(current_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 10000
    let base_crystal = 20000
    let base_deuterium = 6000
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

# ##################################################################################
#                                TECH UPGRADE REQUIREMENTS CHECK                   #
####################################################################################

func energy_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (ogame_address) = _ogame_address.read()
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    with_attr error_message("research lab must be at level 1"):
        assert_le(1, research_lab_level)
    end
    return (TRUE)
end

func computer_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (ogame_address) = _ogame_address.read()
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    with_attr error_message("research lab must be at level 1"):
        assert_le(1, research_lab_level)
    end
    return (TRUE)
end

func laser_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    let energy_tech_level = tech_levels.energy_tech
    with_attr error_message("research lab must be at level 1"):
        assert research_lab_level = 1
    end
    with_attr error_message("energy tech must be at level 2"):
        assert energy_tech_level = 2
    end
    return (TRUE)
end

func armour_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    with_attr error_message("research lab must be at level 2"):
        assert research_lab_level = 2
    end
    return (TRUE)
end

func astrophysics_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    let impulse_drive_level = tech_levels.impulse_drive
    let espionage_tech_level = tech_levels.espionage_tech
    with_attr error_message("research lab must be at level 3"):
        assert research_lab_level = 3
    end
    with_attr error_message("impulse drive must be at level 3"):
        assert impulse_drive_level = 3
    end
    with_attr error_message("espionage tech must be at level 4"):
        assert espionage_tech_level = 4
    end
    return (TRUE)
end

func espionage_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    with_attr error_message("research lab must be at level 3"):
        assert research_lab_level = 3
    end
    return (TRUE)
end

func ion_tech_requirements_check{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    let laser_tech_level = tech_levels.laser_tech
    let energy_tech_level = tech_levels.energy_tech
    with_attr error_message("research lab must be at level 4"):
        assert research_lab_level = 4
    end
    with_attr error_message("laser tech must be at level 5"):
        assert laser_tech_level = 5
        assert energy_tech_level = 4
    end
    return (TRUE)
end

func plasma_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    let laser_tech_level = tech_levels.laser_tech
    let energy_tech_level = tech_levels.energy_tech
    let ion_tech_level = tech_levels.ion_tech
    with_attr error_message("research lab must be at level 4"):
        assert research_lab_level = 4
    end
    with_attr error_message("energy tech must be at level 8"):
        assert energy_tech_level = 8
    end
    with_attr error_message("laser tech must be at level 10"):
        assert laser_tech_level = 10
    end
    with_attr error_message("ion tech must be at level 5"):
        assert ion_tech_level = 5
    end
    return (TRUE)
end

func weapons_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    with_attr error_message("research lab must be at level 4"):
        assert research_lab_level = 4
    end
    return (TRUE)
end

func shielding_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    let energy_tech_level = tech_levels.energy_tech
    with_attr error_message("research lab must be at level 6"):
        assert research_lab_level = 6
    end
    with_attr error_message("energy tech must be at level 3"):
        assert energy_tech_level = 3
    end
    return (TRUE)
end

func hyperspace_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    let energy_tech_level = tech_levels.energy_tech
    let shielding_tech_level = tech_levels.shielding_tech
    with_attr error_message("research lab must be at level 7"):
        assert research_lab_level = 7
    end
    with_attr error_message("energy tech must be at level 5"):
        assert energy_tech_level = 5
    end
    with_attr error_message("shielding tech must be at level 5"):
        assert shielding_tech_level = 5
    end
    return (TRUE)
end
# ###################### ENGINES SPECIFIC UPGRADE REQUIREMENTS CHECK #########################

func combustion_drive_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    let energy_tech_level = tech_levels.energy_tech

    with_attr error_message("research lab must be at level 1"):
        assert research_lab_level = 1
    end
    with_attr error_message("energy tech must be at level 1"):
        assert energy_tech_level = 1
    end

    return (TRUE)
end

func impulse_drive_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    let energy_tech_level = tech_levels.energy_tech
    with_attr error_message("research lab must be at level 2"):
        assert research_lab_level = 2
    end
    with_attr error_message("energy tech must be at level 1"):
        assert energy_tech_level = 1
    end
    return (TRUE)
end

func hyperspace_drive_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (tech_levels) = _get_tech_levels(caller)
    let research_lab_level = tech_levels.research_lab
    let energy_tech_level = tech_levels.energy_tech
    let shielding_tech_level = tech_levels.shielding_tech
    let hyperspace_tech_level = tech_levels.hyperspace_tech
    with_attr error_message("research lab must be at level 7"):
        assert research_lab_level = 7
    end
    with_attr error_message("energy tech must be at level 5"):
        assert energy_tech_level = 5
    end
    with_attr error_message("shielding tech must be at level 5"):
        assert shielding_tech_level = 5
    end
    with_attr error_message("hyperspace tech must be at level 3"):
        assert hyperspace_tech_level = 3
    end
    return (TRUE)
end

# ############################ INTERNAL FUNCS ######################################
func get_available_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
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

func _get_tech_levels{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (result : TechLevels):
    let (ogame_address) = _ogame_address.read()
    let (planet_id) = IOgame.owner_of(ogame_address, caller)
    let (tech_levels) = IOgame.get_tech_levels(ogame_address, planet_id)
    return (tech_levels)
end

func reset_research_timelock{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
):
    research_timelock.write(address, ResearchQue(0, 0))
    return ()
end

func reset_research_que{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, id : felt
):
    research_qued.write(address, id, FALSE)
    return ()
end
