%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from contracts.utils.constants import TRUE, FALSE
from contracts.Ogame.IOgame import IOgame
from contracts.Tokens.erc20.interfaces.IERC20 import IERC20
from starkware.cairo.common.pow import pow
from contracts.ResearchLab.library import ResearchLab
from contracts.Ogame.structs import TechLevels
from starkware.starknet.common.syscalls import get_block_timestamp

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

# @dev Stores the timestamp of the end of the timelock for buildings upgrades.
# @params The address of the player.
@storage_var
func shipyard_timelock(address : felt) -> (cued_details : ShipyardQue):
end

# @dev Stores the que status for a specific ship.
@storage_var
func ships_qued(address : felt, id : felt) -> (is_qued : felt):
end

namespace Shipyard:
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

    # ###################################################################################################
    #                                SHIPS REQUIREMENTS CHECHS                                          #
    #####################################################################################################

    func cargo_ship_requirements_check{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt) -> (response : felt):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, _, _, shipyard_level, _) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (tech_levels) = ResearchLab.get_tech_levels(caller)
        with_attr error_message("SHIPYARD::SHIPYARD MUST BE AT LEVEL 2"):
            assert_le(2, shipyard_level)
        end
        with_attr error_message("SHIPYARD::COMBUSTION DRIVE MUST BE AT LEVEL 2"):
            assert_le(2, tech_levels.combustion_drive)
        end
        return (TRUE)
    end

    func recycler_ship_requirements_check{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt) -> (response : felt):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, _, _, shipyard_level, _) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (tech_levels) = ResearchLab.get_tech_levels(caller)
        with_attr error_message("SHIPYARD::SHIPYARD MUST BE AT LEVEL 4"):
            assert_le(4, shipyard_level)
        end
        with_attr error_message("SHIPYARD::COMBUSTION DRIVE MUST BE AT LEVEL 2 6"):
            assert_le(6, tech_levels.combustion_drive)
        end
        with_attr error_message("SHIPYARD::SHIELDING TECHNOLOGY MUST BE AT LEVEL 2"):
            assert_le(2, tech_levels.shielding_tech)
        end
        return (TRUE)
    end

    func espionage_probe_requirements_check{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt) -> (response : felt):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, _, _, shipyard_level, _) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (tech_levels) = ResearchLab.get_tech_levels(caller)
        with_attr error_message("SHIPYARD::SHIPYARD MUST BE AT LEVEL 3"):
            assert_le(3, shipyard_level)
        end
        with_attr error_message("SHIPYARD::COMBUSTION DRIVE MUST BE AT LEVEL 3"):
            assert_le(3, tech_levels.combustion_drive)
        end
        with_attr error_message("SHIPYARD::ESPIONAGE TECHNOLOGY MUST BE AT LEVEL 2"):
            assert_le(2, tech_levels.espionage_tech)
        end
        return (TRUE)
    end

    func solar_satellite_requirements_check{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt) -> (response : felt):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, _, _, shipyard_level, _) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (tech_levels) = ResearchLab.get_tech_levels(caller)
        with_attr error_message("SHIPYARD::SHIPYARD MUST BE AT LEVEL 1"):
            assert_le(1, shipyard_level)
        end
        return (TRUE)
    end

    func light_fighter_requirements_check{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt) -> (response : felt):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, _, _, shipyard_level, _) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (tech_levels) = ResearchLab.get_tech_levels(caller)
        with_attr error_message("SHIPYARD::SHIPYARD MUST BE AT LEVEL 1"):
            assert_le(1, shipyard_level)
        end
        with_attr error_message("SHIPYARD::COMBUSTION DRIVE MUST BE AT LEVEL 1"):
            assert_le(1, tech_levels.combustion_drive)
        end
        return (TRUE)
    end

    func cruiser_requirements_check{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt) -> (response : felt):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, _, _, shipyard_level, _) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (tech_levels) = ResearchLab.get_tech_levels(caller)
        with_attr error_message("SHIPYARD::SHIPYARD MUST BE AT LEVEL 5"):
            assert_le(5, shipyard_level)
        end
        with_attr error_message("SHIPYARD::ION TECH MUST BE AT LEVEL 2"):
            assert_le(2, tech_levels.ion_tech)
        end
        with_attr error_message("SHIPYARD::IMPULSE DRIVE MUST BE AT LEVEL 4"):
            assert_le(4, tech_levels.impulse_drive)
        end
        return (TRUE)
    end

    func battleship_requirements_check{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt) -> (response : felt):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, _, _, shipyard_level, _) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (tech_levels) = ResearchLab.get_tech_levels(caller)
        with_attr error_message("SHIPYARD::SHIPYARD MUST BE AT LEVEL 7"):
            assert_le(7, shipyard_level)
        end
        with_attr error_message("SHIPYARD::HYPERSPACE DRIVE MUST BE AT LEVEL 4"):
            assert_le(4, tech_levels.hyperspace_drive)
        end
        return (TRUE)
    end

    func deathstar_requirements_check{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt) -> (response : felt):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, _, _, shipyard_level, _) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (tech_levels) = ResearchLab.get_tech_levels(caller)
        with_attr error_message("SHIPYARD::SHIPYARD MUST BE AT LEVEL 12"):
            assert_le(12, shipyard_level)
        end
        with_attr error_message("SHIPYARD::HYPERSPACE TECH MUST BE AT LEVEL 6"):
            assert_le(6, tech_levels.hyperspace_tech)
        end
        with_attr error_message("SHIPYARD::HYPERSPACE DRIVE MUST BE AT LEVEL 7"):
            assert_le(7, tech_levels.hyperspace_drive)
        end
        # TODO: add graviton tech here
        with_attr error_message("SHIPYARD::HYPERSPACE DRIVE MUST BE AT LEVEL 7"):
            assert_le(7, tech_levels.espionage_tech)
        end
        return (TRUE)
    end

    # ###################################################################################################
    #                                SHIPS COST CALCULATION FUNCTIONS                                   #
    #####################################################################################################

    func cargo_ship_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
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

    func recycler_ship_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        number_of_units : felt
    ) -> (metal : felt, crystal : felt, deuterium : felt):
        let metal_required = 10000
        let crystal_required = 6000
        let deuterium_required = 2000
        return (
            metal_required * number_of_units,
            crystal_required * number_of_units,
            deuterium_required * number_of_units,
        )
    end

    func espionage_probe_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        number_of_units : felt
    ) -> (metal : felt, crystal : felt, deuterium : felt):
        let metal_required = 0
        let crystal_required = 1000
        let deuterium_required = 0
        return (
            metal_required * number_of_units,
            crystal_required * number_of_units,
            deuterium_required * number_of_units,
        )
    end

    func solar_satellite_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        number_of_units : felt
    ) -> (metal : felt, crystal : felt, deuterium : felt):
        let metal_required = 0
        let crystal_required = 2000
        let deuterium_required = 500
        return (
            metal_required * number_of_units,
            crystal_required * number_of_units,
            deuterium_required * number_of_units,
        )
    end

    func light_fighter_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        number_of_units : felt
    ) -> (metal : felt, crystal : felt, deuterium : felt):
        let metal_required = 3000
        let crystal_required = 1000
        let deuterium_required = 0
        return (
            metal_required * number_of_units,
            crystal_required * number_of_units,
            deuterium_required * number_of_units,
        )
    end

    func cruiser_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        number_of_units : felt
    ) -> (metal : felt, crystal : felt, deuterium : felt):
        let metal_required = 20000
        let crystal_required = 7000
        let deuterium_required = 2000
        return (
            metal_required * number_of_units,
            crystal_required * number_of_units,
            deuterium_required * number_of_units,
        )
    end

    func battleship_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        number_of_units : felt
    ) -> (metal : felt, crystal : felt, deuterium : felt):
        let metal_required = 45000
        let crystal_required = 15000
        let deuterium_required = 0
        return (
            metal_required * number_of_units,
            crystal_required * number_of_units,
            deuterium_required * number_of_units,
        )
    end

    func deathstar_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        number_of_units : felt
    ) -> (metal : felt, crystal : felt, deuterium : felt):
        let metal_required = 5000000
        let crystal_required = 4000000
        let deuterium_required = 1000000
        return (
            metal_required * number_of_units,
            crystal_required * number_of_units,
            deuterium_required * number_of_units,
        )
    end

    #######################################################################################################
    #                                           INTERNAL FUNC                                             #
    #######################################################################################################

    func production_time{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        metal_required : felt, crystal_required : felt, shipyard_level : felt
    ) -> (production_time : felt):
        let fact1 = metal_required + crystal_required
        let fact2 = 1 + shipyard_level
        let fact3 = fact2 * 250
        let (res, _) = unsigned_div_rem(fact1, fact3)
        return (res)
    end

    func get_available_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt
    ) -> (metal : felt, crystal : felt, deuterium : felt):
        let (ogame_address) = _ogame_address.read()
        let (metal_address) = IOgame.get_metal_address(ogame_address)
        let (crystal_address) = IOgame.get_crystal_address(ogame_address)
        let (deuterium_address) = IOgame.get_deuterium_address(ogame_address)
        let (metal_available) = IERC20.balanceOf(metal_address, caller)
        let (crystal_available) = IERC20.balanceOf(crystal_address, caller)
        let (deuterium_available) = IERC20.balanceOf(deuterium_address, caller)
        return (metal_available.low, crystal_available.low, deuterium_available.low)
    end

    func check_enough_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt, metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
        alloc_locals
        let (metal_available, crystal_available, deuterium_available) = get_available_resources(
            caller
        )
        with_attr error_message("not enough resources"):
            let (enough_metal) = is_le(metal_required, metal_available)
            assert enough_metal = TRUE
            let (enough_crystal) = is_le(crystal_required, crystal_available)
            assert enough_crystal = TRUE
            let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
            assert enough_deuterium = TRUE
        end
        return ()
    end

    func reset_timelock{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt
    ):
        shipyard_timelock.write(address, ShipyardQue(0, 0, 0))
        return ()
    end

    func reset_que{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, id : felt
    ):
        ships_qued.write(address, id, FALSE)
        return ()
    end

    func check_que_not_busy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt
    ):
        let (que_status) = shipyard_timelock.read(caller)
        let current_timelock = que_status.lock_end
        with_attr error_message("SHIPYARD::Que is busy"):
            assert current_timelock = 0
        end
        return ()
    end

    func check_trying_to_complete_the_right_ship{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt, SHIP_ID : felt):
        let (is_qued) = ships_qued.read(caller, SHIP_ID)
        with_attr error_message("Tried to complete the wrong ship"):
            assert is_qued = TRUE
        end
        return ()
    end

    func check_waited_enough{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt
    ) -> (units_produced : felt):
        alloc_locals
        tempvar syscall_ptr = syscall_ptr
        let (time_now) = get_block_timestamp()
        let (que_details) = shipyard_timelock.read(caller)
        let timelock_end = que_details.lock_end
        let (waited_enough) = is_le(timelock_end, time_now)
        with_attr error_message("Timelock not yet expired"):
            assert waited_enough = TRUE
        end
        let units_produced = que_details.units
        return (units_produced)
    end

    func set_timelock_and_que{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt,
        SHIP_ID : felt,
        number_of_units : felt,
        metal_required : felt,
        crystal_required : felt,
        deuterium_required : felt,
    ):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, _, _, shipyard_level, _) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (build_time) = production_time(metal_required, crystal_required, shipyard_level)
        let (time_now) = get_block_timestamp()
        let time_end = time_now + build_time
        let que_details = ShipyardQue(SHIP_ID, number_of_units, time_end)
        ships_qued.write(caller, SHIP_ID, TRUE)
        shipyard_timelock.write(caller, que_details)
        return ()
    end
end
