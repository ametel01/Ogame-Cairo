%lang starknet

@contract_interface
namespace IFacilities:
    func robot_factory_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func robot_factory_upgrade_complete(success : felt):
    end

    func shipyard_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func shipyard_upgrade_complete(caller : felt) -> (success : felt):
    end

    func research_lab_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func research_lab_upgrade_complete(caller : felt) -> (success : felt):
    end

    func nanite_factory_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func nanite_factory_upgrade_complete(caller : felt) -> (success : felt):
    end
end
