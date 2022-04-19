%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.pow import pow
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_caller_address
from contracts.utils.constants import TRUE
from contracts.token.erc20.interfaces.IERC20 import IERC20
from contracts.interfaces.IOgame import IOgame
from contracts.ResourcesManager import _pay_resources_erc20

@storage_var
func ogame_address() -> (address : felt):
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
func research_lab(planet_id : Uint256) -> (level : felt):
end

@storage_var
func energy_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func computer_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func laser_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func armour_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func ion_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func espionage_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func plasma_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func weapon_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func shielding_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func hyperspace_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func astrophysics(planet_id : Uint256) -> (level : felt):
end

@storage_var
func combustion_drive(planet_id : Uint256) -> (level : felt):
end

@storage_var
func hyperspace_drive(planet_id : Uint256) -> (level : felt):
end

@storage_var
func impulse_drive(planet_id : Uint256) -> (level : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    _ogame_address : felt, _metal_address : felt, _crystal_address : felt, _deuterium_address : felt
):
    ogame_address.write(_ogame_address)
    metal_address.write(_metal_address)
    crystal_address.write(_crystal_address)
    deuterium_address.write(_deuterium_address)
    return ()
end

# ##################### GENERAL TECH ##########################
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

# ############################### TECH UPGRADE REQUIREMENTS CHECK ########################################
func energy_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    with_attr error_message("research lab must be at level 1"):
        assert research_lab_level = 1
    end
    return (TRUE)
end

func laser_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    let (energy_tech_level) = energy_tech.read(planet_id)
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
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    with_attr error_message("research lab must be at level 2"):
        assert research_lab_level = 2
    end
    return (TRUE)
end

func astrophysics_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    let (impulse_drive_level) = impulse_drive.read(planet_id)
    let (espionage_tech_level) = espionage_tech.read(planet_id)
    with_attr error_message("research lab must be at level 3"):
        assert research_lab_level = 3
    end
    with_attr error_message("impulse drive must be at level 3"):
        assert impulse_drive_level = 3
    end
    with_attr error_message("espinage tech must be at level 4"):
        assert espionage_tech_level = 4
    end
    return (TRUE)
end

func espionage_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    with_attr error_message("research lab must be at level 3"):
        assert research_lab_level = 3
    end
    return (TRUE)
end

func ion_tech_requirements_check{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    planet_id : Uint256
) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    let (laser_tech_level) = laser_tech.read(planet_id)
    let (energy_tech_level) = energy_tech.read(planet_id)
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
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    let (laser_tech_level) = laser_tech.read(planet_id)
    let (energy_tech_level) = energy_tech.read(planet_id)
    let (ion_tech_level) = ion_tech.read(planet_id)
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
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    with_attr error_message("research lab must be at level 4"):
        assert research_lab_level = 4
    end
    return (TRUE)
end

func shielding_tech_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    let (energy_tech_level) = energy_tech.read(planet_id)
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
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    let (energy_tech_level) = energy_tech.read(planet_id)
    let (shielding_tech_level) = shielding_tech.read(planet_id)
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
# ############################### ENGINES UPGRADE REQUIREMENTS CHECK #######################################
func combustion_drive_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    let (energy_tech_level) = energy_tech.read(planet_id)

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
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    let (energy_tech_level) = energy_tech.read(planet_id)
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
}(planet_id : Uint256) -> (response : felt):
    let (research_lab_level) = research_lab.read(planet_id)
    let (energy_tech_level) = energy_tech.read(planet_id)
    let (shielding_tech_level) = shielding_tech.read(planet_id)
    let (hyperspace_tech_level) = hyperspace_tech.read(planet_id)
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

# ######### UPGRADES FUNCS ############################
@external
func upgrade_research_lab{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (caller) = get_caller_address()
    let (_ogame_address) = ogame_address.read()
    let (planet_id) = IOgame.owner_of(_ogame_address, caller)
    let (current_level) = research_lab.read(planet_id)
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = research_lab_upgrade_cost(
        current_level
    )
    with_attr error_message("not enough resources"):
        is_le(metal_required, metal_available)
        is_le(crystal_required, crystal_available)
        is_le(deuterium_required, deuterium_available)
    end
    _pay_resources_erc20(caller, metal_required, crystal_required, deuterium_required)
    research_lab.write(planet_id, current_level + 1)
    return ()
end

# ############################ INTERNAL FUNCS ######################################
func get_available_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let (_metal_address) = metal_address.read()
    let (_crystal_address) = crystal_address.read()
    let (_deuterium_address) = deuterium_address.read()
    let (metal_available) = IERC20.balanceOf(_metal_address, caller)
    let (crystal_available) = IERC20.balanceOf(_crystal_address, caller)
    let (deuterium_available) = IERC20.balanceOf(_deuterium_address, caller)
    return (metal_available.low, crystal_available.low, deuterium_available.low)
end
