%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IResearchLab:
    func _research_lab_upgrade_start(caller : felt):
    end

    func _research_lab_upgrade_end(caller : felt):
    end
end
