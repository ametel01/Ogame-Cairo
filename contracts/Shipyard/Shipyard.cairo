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
    _light_fighter_requirements_check,
    _light_fighter_cost,
    _cruiser_requirements_check,
    _cruiser_cost,
    _battleship_requirements_check,
    _battleship_cost,
    CARGO_SHIP_ID,
    RECYCLER_SHIP_ID,
    ESPIONAGE_PROBE_ID,
    SOLAR_SATELLITE_ID,
    LIGHT_FIGHTER_ID,
    CRUISER_ID,
    BATTLESHIP_ID,
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

@external
func _build_light_fighter_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, number_of_units : felt
) -> (metal_spent : felt, crystal_spent : felt, deuterium_spent : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _light_fighter_cost(
        number_of_units
    )
    assert_not_zero(caller)
    _check_shipyard_que_not_busy(caller)
    _light_fighter_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_shipyard_timelock_and_que(
        caller,
        LIGHT_FIGHTER_ID,
        number_of_units,
        metal_required,
        crystal_required,
        deuterium_required,
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _build_light_fighter_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (units_produced : felt, success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_ship(caller, LIGHT_FIGHTER_ID)
    let (units_produced) = _check_waited_enough(caller)
    _reset_shipyard_timelock(caller)
    _reset_shipyard_que(caller, LIGHT_FIGHTER_ID)
    return (units_produced, TRUE)
end

@external
func _build_cruiser_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, number_of_units : felt
) -> (metal_spent : felt, crystal_spent : felt, deuterium_spent : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = _cruiser_cost(number_of_units)
    assert_not_zero(caller)
    _check_shipyard_que_not_busy(caller)
    _cruiser_requirements_check(caller)
    _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    _set_shipyard_timelock_and_que(
        caller, CRUISER_ID, number_of_units, metal_required, crystal_required, deuterium_required
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _build_cruiser_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (units_produced : felt, success : felt):
    alloc_locals
    _check_trying_to_complete_the_right_ship(caller, CRUISER_ID)
    let (units_produced) = _check_waited_enough(caller)
    _reset_shipyard_timelock(caller)
    _reset_shipyard_que(caller, CRUISER_ID)
    return (units_produced, TRUE)
end

# @external
# func _build_battleship_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     caller : felt, number_of_units : felt
# ) -> (metal_spent : felt, crystal_spent : felt, deuterium_spent : felt):
#     alloc_locals
#     let (metal_required, crystal_required, deuterium_required) = _battleship_cost(
#         number_of_units
#     )
#     assert_not_zero(caller)
#     _check_shipyard_que_not_busy(caller)
#     _battleship_requirements_check(caller)
#     _check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
#     _set_shipyard_timelock_and_que(
#         caller,
#         BATTLESHIP_ID,
#         number_of_units,
#         metal_required,
#         crystal_required,
#         deuterium_required,
#     )
#     return (metal_required, crystal_required, deuterium_required)
# end

# @external
# func _build_battleship_complete{
#     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
# }(caller : felt) -> (units_produced : felt, success : felt):
#     alloc_locals
#     _check_trying_to_complete_the_right_ship(caller, BATTLESHIP_ID)
#     let (units_produced) = _check_waited_enough(caller)
#     _reset_shipyard_timelock(caller)
#     _reset_shipyard_que(caller, BATTLESHIP_ID)
#     return (units_produced, TRUE)
# end
