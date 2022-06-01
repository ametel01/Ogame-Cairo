%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IResearchLab:
    func _energy_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _energy_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _computer_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _computer_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _laser_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _laser_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _armour_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _armour_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _ion_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _ion_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _espionage_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _espionage_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _plasma_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _plasma_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _weapons_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _weapons_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _shielding_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _shielding_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _hyperspace_tech_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _hyperspace_tech_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _astrophysics_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _astrophysics_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _combustion_drive_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _combustion_drive_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _hyperspace_drive_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _hyperspace_drive_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _impulse_drive_upgrade_start(caller : felt, current_tech_level : felt) -> (
        metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
    end

    func _impulse_drive_upgrade_complete(caller : felt) -> (success : felt):
    end
end
