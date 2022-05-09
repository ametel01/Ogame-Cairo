%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IShipyard:
    func _build_cargo_ship_start(caller : felt, quantity : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _build_cargo_ship_complete(caller : felt) -> (success : felt):
    end

    func _build_recycler_ship_start(caller : felt, quantity : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _build_recycler_ship_complete(caller : felt) -> (success : felt):
    end

    func _build_espionage_probe_start(caller : felt, quantity : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _build_espionage_probe_complete(caller : felt) -> (success : felt):
    end

    func _build_solar_satellite_start(caller : felt, quantity : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _build_solar_satellite_complete(caller : felt) -> (success : felt):
    end

    func _build_light_fighter_ship_start(caller : felt, quantity : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _build_light_fighter_ship_complete(caller : felt) -> (success : felt):
    end

    func _build_cruiser_ship_start(caller : felt, quantity : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _build_cruiser_ship_complete(caller : felt) -> (success : felt):
    end

    func _build_battleship_start(caller : felt, quantity : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _build_battleship_complete(caller : felt) -> (success : felt):
    end

    func _build_deathstar_ship_start(caller : felt, quantity : felt) -> (
        metal_spent : felt, crystal_spent : felt, deuterium_spent : felt, time_unlocked : felt
    ):
    end

    func _build_deathstar_ship_complete(caller : felt) -> (success : felt):
    end
end
