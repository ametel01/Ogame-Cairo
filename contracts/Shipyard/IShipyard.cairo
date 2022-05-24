%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IShipyard:
    func _shipyard_upgrade_start(caller : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _shipyard_upgrade_complete(caller : felt) -> (success : felt):
    end

    func _cargo_ship_build_start(caller : felt, number_of_units : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
    ):
    end

    func _cargo_ship_build_complete(caller : felt) -> (units_produced : felt, success : felt):
    end

    func _build_recycler_ship_start(caller : felt, number_of_units : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
    ):
    end

    func _build_recycler_ship_complete(caller : felt) -> (units_produced : felt, success : felt):
    end

    func _build_espionage_probe_start(caller : felt, number_of_units : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
    ):
    end

    func _build_espionage_probe_complete(caller : felt) -> (units_produced : felt, success : felt):
    end

    func _build_solar_satellite_start(caller : felt, number_of_units : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
    ):
    end

    func _build_solar_satellite_complete(caller : felt) -> (units_produced : felt, success : felt):
    end

    func _build_light_fighter_start(caller : felt, number_of_units : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
    ):
    end

    func _build_light_fighter_complete(caller : felt) -> (units_produced : felt, success : felt):
    end

    func _build_cruiser_start(caller : felt, number_of_units : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
    ):
    end

    func _build_cruiser_complete(caller : felt) -> (units_produced : felt, success : felt):
    end

    func _build_battleship_start(caller : felt, number_of_units : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
    ):
    end

    func _build_battleship_complete(caller : felt) -> (units_produced : felt, success : felt):
    end

    func _build_deathstar_ship_start(caller : felt, number_of_units : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
    ):
    end

    func _build_deathstar_ship_complete(caller : felt) -> (units_produced : felt, success : felt):
    end
end
