%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from contracts.Shipyard.library import (
    _ogame_address,
    get_available_resources,
    ShipyardQue,
    shipyard_upgrade_cost,
    shipyard_timelock,
    ships_qued,
    _cargo_ship_requirements_check,
    _cargo_ship_cost,
    _recycler_ship_requirements_check,
    _recycler_ship_cost,
    _espionage_probe_requirements_check,
    _espionage_probe_cost,
    _solar_satellite_requirements_check,
    _solar_satellite_cost,
    CARGO_SHIP_ID,
    RECYCLER_SHIP_ID,
    ESPIONAGE_PROBE_ID,
    SOLAR_SATELLITE_ID,
    _reset_shipyard_que,
    _reset_shipyard_timelock,
    _check_shipyard_que_not_busy,
    _check_enough_resources,
    _set_shipyard_timelock_and_que,
    _check_trying_to_complete_the_right_ship,
    _check_waited_enough,
)
from contracts.Ogame.IOgame import IOgame
from contracts.utils.constants import TRUE, SHIPYARD_BUILDING_ID
from contracts.utils.Formulas import formulas_buildings_production_time

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ogame_address : felt
):
    _ogame_address.write(ogame_address)
    return ()
end

########################################################################################################
#                                   SHIPYARD UPGRADE FUNCTION                                          #
# ######################################################################################################

@external
func _shipyard_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt, time_unlocked : felt):
    alloc_locals
    assert_not_zero(caller)
    let (ogame_address) = _ogame_address.read()
    let (cue_status) = IOgame.get_buildings_timelock_status(ogame_address, caller)
    let current_timelock = cue_status.lock_end
    with_attr error_message("Building que is busy"):
        assert current_timelock = 0
    end
    let (planet_id) = IOgame.owner_of(ogame_address, caller)
    let (_, _, _, _, robot_factory_level, _, shipyard_level) = IOgame.get_structures_levels(
        ogame_address, caller
    )
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = shipyard_upgrade_cost(
        shipyard_level
    )
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (building_time) = formulas_buildings_production_time(
        metal_required, crystal_required, robot_factory_level
    )
    let (time_now) = get_block_timestamp()
    let time_unlocked = time_now + building_time

    return (metal_required, crystal_required, deuterium_required, time_unlocked)
end

@external
func _shipyard_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (success : felt):
    alloc_locals
    let (ogame_address) = _ogame_address.read()
    let (is_qued) = IOgame.is_building_qued(ogame_address, caller, SHIPYARD_BUILDING_ID)
    with_attr error_message("Tried to complete the wrong structure"):
        assert is_qued = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (planet_id) = IOgame.owner_of(ogame_address, caller)
    let (cue_details) = IOgame.get_buildings_timelock_status(ogame_address, caller)
    let timelock_end = cue_details.lock_end
    let (time_now) = get_block_timestamp()
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    return (TRUE)
end

########################################################################################################
#                                   SHIPS UPGRADE FUNCTION                                             #
# ######################################################################################################

@external
func _cargo_ship_build_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, number_of_units : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _cargo_ship_cost(number_of_units)
    assert_not_zero(caller)
    _check_shipyard_que_not_busy(caller)
    _cargo_ship_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_shipyard_timelock_and_que(
        caller, CARGO_SHIP_ID, number_of_units, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _cargo_ship_build_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (unit_produced : felt, success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_ship(caller, CARGO_SHIP_ID)
    let (units_produced) = _check_waited_enough(caller)
    _reset_shipyard_timelock(caller)
    _reset_shipyard_que(caller, CARGO_SHIP_ID)
    return (units_produced, TRUE)
end

@external
func _build_recycler_ship_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, number_of_units : felt
) -> (metal_spent : felt, crystal_spent : felt, deuterium_spent : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _recycler_ship_cost(
        number_of_units
    )
    assert_not_zero(caller)
    _check_shipyard_que_not_busy(caller)
    _recycler_ship_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_shipyard_timelock_and_que(
        caller,
        RECYCLER_SHIP_ID,
        number_of_units,
        metal_required,
        crystal_required,
        deuterium_required,
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _build_recycler_ship_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (unit_produced : felt, success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_ship(caller, RECYCLER_SHIP_ID)
    let (units_produced) = _check_waited_enough(caller)
    _reset_shipyard_timelock(caller)
    _reset_shipyard_que(caller, RECYCLER_SHIP_ID)
    return (units_produced, TRUE)
end

@external
func _build_espionage_probe_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, number_of_units : felt) -> (
    metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _espionage_probe_cost(
        number_of_units
    )
    assert_not_zero(caller)
    _check_shipyard_que_not_busy(caller)
    _espionage_probe_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_shipyard_timelock_and_que(
        caller,
        ESPIONAGE_PROBE_ID,
        number_of_units,
        metal_required,
        crystal_required,
        deuterium_required,
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _build_espionage_probe_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (units_produced : felt, success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_ship(caller, ESPIONAGE_PROBE_ID)
    let (units_produced) = _check_waited_enough(caller)
    _reset_shipyard_timelock(caller)
    _reset_shipyard_que(caller, ESPIONAGE_PROBE_ID)
    return (units_produced, TRUE)
end

@external
func _build_solar_satellite_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, number_of_units : felt) -> (
    metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _solar_satellite_cost(
        number_of_units
    )
    assert_not_zero(caller)
    _check_shipyard_que_not_busy(caller)
    _solar_satellite_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_shipyard_timelock_and_que(
        caller,
        SOLAR_SATELLITE_ID,
        number_of_units,
        metal_required,
        crystal_required,
        deuterium_required,
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _build_solar_satellite_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (units_produced : felt, success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_ship(caller, SOLAR_SATELLITE_ID)
    let (units_produced) = _check_waited_enough(caller)
    _reset_shipyard_timelock(caller)
    _reset_shipyard_que(caller, SOLAR_SATELLITE_ID)
    return (units_produced, TRUE)
end
