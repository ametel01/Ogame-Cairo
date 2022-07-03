%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.utils.constants import UINT256_DECIMALS
from contracts.Ogame.IOgame import IOgame
from contracts.Tokens.erc20.interfaces.IERC20 import IERC20
from contracts.Tokens.erc721.interfaces.IERC721 import IERC721
from contracts.utils.formulas import Formulas
from contracts.Facilities.library import Facilities
from contracts.Ogame.storage import (
    erc721_token_address,
    _planets,
    _resources_timer,
    erc20_metal_address,
    erc20_crystal_address,
    erc20_deuterium_address,
)
#########################################################################################
#                                           CONSTANTS                                   #
#########################################################################################

const METAL_MINE_ID = 41
const CRYSTAL_MINE_ID = 42
const DEUTERIUM_MINE_ID = 43
const SOLAR_PLANT_ID = 44

#########################################################################################
#                                           STRUCTS                                     #
#########################################################################################

struct ResourcesQue:
    member building_id : felt
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

@storage_var
func resources_timelock(address : felt) -> (cued_details : ResourcesQue):
end

# @dev Stores the que status for a specific ship.
@storage_var
func resources_qued(address : felt, id : felt) -> (is_qued : felt):
end

namespace Resources:
    #########################################################################################
    #                                           CONSTANTS                                   #
    #########################################################################################

    const METAL_MINE_ID = 41
    const CRYSTAL_MINE_ID = 42
    const DEUTERIUM_MINE_ID = 43
    const SOLAR_PLANT_ID = 44
    #########################################################################################
    #                                           INTERNALS                                  #
    #########################################################################################

    func _calculate_production{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt
    ) -> (metal : felt, crystal : felt, deuterium : felt):
        alloc_locals
        let (erc721_address) = erc721_token_address.read()
        let (planet_id) = IERC721.ownerToPlanet(erc721_address, caller)
        let (planet) = _planets.read(planet_id)
        let (time_start) = _resources_timer.read(planet_id)
        let metal_level = planet.mines.metal
        let crystal_level = planet.mines.crystal
        let deuterium_level = planet.mines.deuterium
        let (energy_required_metal) = Formulas.consumption_energy(metal_level)
        let (energy_required_crystal) = Formulas.consumption_energy(crystal_level)
        let (energy_required_deuterium) = Formulas.consumption_energy_deuterium(deuterium_level)
        let total_energy_required = energy_required_metal + energy_required_crystal + energy_required_deuterium
        let solar_plant_level = planet.energy.solar_plant
        let (energy_available) = Formulas.solar_plant_production(solar_plant_level)
        let (enough_energy) = is_le(total_energy_required, energy_available)
        # Calculate amount of resources produced.
        let (metal_produced) = Formulas.metal_mine_production(
            last_timestamp=time_start, mine_level=metal_level
        )
        let (crystal_produced) = Formulas.crystal_mine_production(
            last_timestamp=time_start, mine_level=crystal_level
        )
        let (deuterium_produced) = Formulas.deuterium_mine_production(
            last_timestamp=time_start, mine_level=deuterium_level
        )
        # If energy available < than energy required scale down amount produced.
        if enough_energy == FALSE:
            let (
                actual_metal, actual_crystal, actual_deuterium
            ) = Formulas.energy_production_scaler(
                net_metal=metal_produced,
                net_crystal=crystal_produced,
                net_deuterium=deuterium_produced,
                energy_required=total_energy_required,
                energy_available=energy_available,
            )
            let metal = actual_metal
            let crystal = actual_crystal
            let deuterium = actual_deuterium
            return (metal, crystal, deuterium)
        else:
            let metal = metal_produced
            let crystal = crystal_produced
            let deuterium = deuterium_produced
            return (metal, crystal, deuterium)
        end
    end

    func _collect_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt
    ):
        let (metal_produced, crystal_produced, deuterium_produced) = _calculate_production(caller)
        _receive_resources_erc20(
            to=caller,
            metal_amount=metal_produced,
            crystal_amount=crystal_produced,
            deuterium_amount=deuterium_produced,
        )
        let (erc721_address) = erc721_token_address.read()
        let (planet_id) = IERC721.ownerToPlanet(erc721_address, caller)
        let (time_now) = get_block_timestamp()
        _resources_timer.write(planet_id, time_now)
        return ()
    end

    func _receive_resources_erc20{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(to : felt, metal_amount : felt, crystal_amount : felt, deuterium_amount : felt):
        let (metal_address) = erc20_metal_address.read()
        let (crystal_address) = erc20_crystal_address.read()
        let (deuterium_address) = erc20_deuterium_address.read()
        let metal = Uint256(metal_amount * UINT256_DECIMALS, 0)
        let crystal = Uint256(crystal_amount * UINT256_DECIMALS, 0)
        let deuterium = Uint256(deuterium_amount * UINT256_DECIMALS, 0)
        IERC20.mint(metal_address, to, metal)
        IERC20.mint(crystal_address, to, crystal)
        IERC20.mint(deuterium_address, to, deuterium)
        return ()
    end

    func _pay_resources_erc20{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, metal_amount : felt, crystal_amount : felt, deuterium_amount : felt
    ):
        assert_not_zero(address)
        let (metal_address) = erc20_metal_address.read()
        let (crystal_address) = erc20_crystal_address.read()
        let (deuterium_address) = erc20_deuterium_address.read()
        let metal = Uint256(metal_amount * UINT256_DECIMALS, 0)
        let crystal = Uint256(crystal_amount * UINT256_DECIMALS, 0)
        let deuterium = Uint256(deuterium_amount * UINT256_DECIMALS, 0)
        IERC20.burn(metal_address, address, metal)
        IERC20.burn(crystal_address, address, crystal)
        IERC20.burn(deuterium_address, address, deuterium)
        return ()
    end

    func _get_net_energy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        metal_level : felt, crystal_level : felt, deuterium_level : felt, solar_plant_level : felt
    ) -> (net_energy : felt):
        alloc_locals
        let (metal_consumption) = Formulas.consumption_energy(metal_level)
        let (crystal_consumption) = Formulas.consumption_energy(crystal_level)
        let (deuterium_consumption) = Formulas.consumption_energy_deuterium(deuterium_level)
        let total_energy_required = metal_consumption + crystal_consumption + deuterium_consumption
        let (energy_available) = Formulas.solar_production(solar_plant_level)
        let (not_negative_energy) = is_le(total_energy_required, energy_available)
        if not_negative_energy == FALSE:
            return (0)
        else:
            let res = energy_available - total_energy_required
        end
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

    func check_que_not_busy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt
    ):
        let (que_status) = resources_timelock.read(caller)
        let current_timelock = que_status.lock_end
        with_attr error_message("RESOURCES::QUE IS BUSY!!!"):
            assert current_timelock = 0
        end
        return ()
    end

    func check_enough_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt, metal_required : felt, crystal_required : felt, deuterium_required : felt
    ):
        alloc_locals
        let (metal_available, crystal_available, deuterium_available) = get_available_resources(
            caller
        )
        with_attr error_message("RESOURCES::NOT ENOUGH RESOURCES!!!"):
            let (enough_metal) = is_le(metal_required, metal_available)
            assert enough_metal = TRUE
            let (enough_crystal) = is_le(crystal_required, crystal_available)
            assert enough_crystal = TRUE
            let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
            assert enough_deuterium = TRUE
        end
        return ()
    end

    func set_timelock_and_que{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt,
        BUILDING_ID : felt,
        metal_required : felt,
        crystal_required : felt,
        deuterium_required : felt,
    ) -> (time_unlocked : felt):
        let (ogame_address) = _ogame_address.read()
        let (_, _, _, _, robot_factory_level, _, _, nanite_level) = IOgame.get_structures_levels(
            ogame_address, caller
        )
        let (build_time) = Formulas.buildings_production_time(
            metal_required, crystal_required, robot_factory_level, nanite_level
        )
        let (time_now) = get_block_timestamp()
        let time_end = time_now + build_time
        let que_details = ResourcesQue(BUILDING_ID, time_end)
        resources_qued.write(caller, BUILDING_ID, TRUE)
        resources_timelock.write(caller, que_details)
        return (time_end)
    end

    func check_trying_to_complete_the_right_resource{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(caller : felt, BUILDING_ID : felt):
        let (is_qued) = resources_qued.read(caller, BUILDING_ID)
        with_attr error_message("RESOURCES::TRIED TO COMPLETE THE WRONG FACILITY!!!"):
            assert is_qued = TRUE
        end
        return ()
    end

    func check_waited_enough{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt
    ):
        alloc_locals
        tempvar syscall_ptr = syscall_ptr
        let (time_now) = get_block_timestamp()
        let (que_details) = resources_timelock.read(caller)
        let timelock_end = que_details.lock_end
        let (waited_enough) = is_le(timelock_end, time_now)
        with_attr error_message("RESOURCES::TIMELOCK NOT YET EXPIRED!!!"):
            assert waited_enough = TRUE
        end
        return ()
    end

    func reset_que{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt, building_id : felt
    ):
        resources_qued.write(address, building_id, FALSE)
        return ()
    end

    func reset_timelock{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt
    ):
        resources_timelock.write(address, ResourcesQue(0, 0))
        return ()
    end
end
