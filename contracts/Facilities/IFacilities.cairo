%lang starknet

@contract_interface
namespace IFacilities:
    func _robot_factory_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _robot_factory_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _shipyard_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _shipyard_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _research_lab_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _research_lab_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _nanite_factory_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _nanite_factory_upgrade_complete(caller : felt) -> (success : felt):
    end
end
