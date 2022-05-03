%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IResearchLab:
    func _research_lab_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
    ):
    end

    func _research_lab_upgrade_complete(caller : felt):
    end

    func _energy_tech_upgrade_start(caller : felt, current_tech_level : felt):
    end

    func _energy_tech_upgrade_complet(caller : felt, current_tech_level : felt):
    end
end
