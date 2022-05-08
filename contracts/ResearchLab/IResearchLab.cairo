%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IResearchLab:
    func _research_lab_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _research_lab_upgrade_complete(caller : felt) -> (success : felt):
    end

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
end
