%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le
from contracts.utils.constants import TRUE, FALSE
from contracts.Ogame.IOgame import IOgame
from contracts.token.erc20.interfaces.IERC20 import IERC20
from starkware.cairo.common.pow import pow
from contracts.ResearchLab.library import _get_tech_levels
from contracts.Ogame.structs import TechLevels

#########################################################################################
#                                           CONSTANTS                                   #
#########################################################################################

const CARGO_SHIP_ID = 31
const RECYCLER_SHIP_ID = 32
const ESPIONAGE_PROBE_ID = 33
const SOLAR_SATELLITE_ID = 34
const LIGHT_FIGHTER_ID = 35
const CRUISER_ID = 36
const BATTLESHIP_ID = 37
const DEATHSTAR_ID = 38

#########################################################################################
#                                           STRUCTS                                     #
#########################################################################################
struct ShipsCost:
    member metal : felt
    member crystal : felt
    member deuterium : felt
end

struct Performance:
    member structural_intergrity : felt
    member shield_power : felt
    member weapon_power : felt
    member cargo_capacity : felt
    member base_speed : felt
    member fuel_consumption : felt
end

struct Ships:
    member cost : ShipsCost
    member performance : Performance
end

struct ShipyardQue:
    member ship_id : felt
    member units : felt
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
func shipyard_timelock(address : felt) -> (cued_details : ShipyardQue):
end

# @dev Stores the que status for a specific ship.
@storage_var
func ships_qued(address : felt, id : felt) -> (is_qued : felt):
end

# ###################################################################################################
#                                SHIPS REQUIREMENTS CHECHS                                          #
#####################################################################################################

func _cargo_ship_requirements_check{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (response : felt):
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, _, shipyard_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (tech_levels) = _get_tech_levels(caller)
    with_attr error_message("shipyard must be at level 2"):
        assert_le(2, shipyard_level)
    end
    with_attr error_message("combustion drive must be at level 2"):
        assert_le(2, tech_levels.combustion_drive)
    end
    return (TRUE)
end

# ###################################################################################################
#                                SHIPS COST CALCULATION FUNCTIONS                                   #
#####################################################################################################

func _cargo_ship_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    number_of_units : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let metal_required = 2000
    let crystal_required = 2000
    let deuterium_required = 0
    return (
        metal_required * number_of_units,
        crystal_required * number_of_units,
        deuterium_required * number_of_units,
    )
end

# ###################################################################################################
#                                INTERNAL FUNCTIONS                                                 #
#####################################################################################################

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

func shipyard_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    current_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    let base_metal = 400
    let base_crystal = 200
    let base_deuterium = 100
    if current_level == 0:
        tempvar syscall_ptr = syscall_ptr
        return (base_metal, base_crystal, base_deuterium)
    else:
        let (multiplier) = pow(2, current_level)
        return (base_metal * multiplier, base_crystal * multiplier, base_deuterium * multiplier)
    end
end

func reset_shipyard_timelock{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
):
    shipyard_timelock.write(address, ShipyardQue(0, 0, 0))
    return ()
end

func reset_shipyard_que{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, id : felt
):
    ships_qued.write(address, id, FALSE)
    return ()
end
