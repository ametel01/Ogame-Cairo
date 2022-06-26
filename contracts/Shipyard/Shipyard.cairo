%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from contracts.Shipyard.library import _ogame_address, Shipyard
from contracts.Ogame.IOgame import IOgame
from contracts.utils.formulas import Formulas

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
    let (metal_required, crystal_required, deuterium_required) = Shipyard.cargo_ship_cost(
        number_of_units
    )
    assert_not_zero(caller)
    Shipyard.check_que_not_busy(caller)
    Shipyard.cargo_ship_requirements_check(caller)
    Shipyard.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    Shipyard.set_timelock_and_que(
        caller,
        Shipyard.CARGO_SHIP_ID,
        number_of_units,
        metal_required,
        crystal_required,
        deuterium_required,
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _cargo_ship_build_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (unit_produced : felt, success : felt):
    alloc_locals
    Shipyard.check_trying_to_complete_the_right_ship(caller, Shipyard.CARGO_SHIP_ID)
    let (units_produced) = Shipyard.check_waited_enough(caller)
    Shipyard.reset_timelock(caller)
    Shipyard.reset_que(caller, Shipyard.CARGO_SHIP_ID)
    return (units_produced, TRUE)
end

@external
func _build_recycler_ship_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, number_of_units : felt
) -> (metal_spent : felt, crystal_spent : felt, deuterium_spent : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = Shipyard.recycler_ship_cost(
        number_of_units
    )
    assert_not_zero(caller)
    Shipyard.check_que_not_busy(caller)
    Shipyard.recycler_ship_requirements_check(caller)
    Shipyard.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    Shipyard.set_timelock_and_que(
        caller,
        Shipyard.RECYCLER_SHIP_ID,
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
    Shipyard.check_trying_to_complete_the_right_ship(caller, Shipyard.RECYCLER_SHIP_ID)
    let (units_produced) = Shipyard.check_waited_enough(caller)
    Shipyard.reset_timelock(caller)
    Shipyard.reset_que(caller, Shipyard.RECYCLER_SHIP_ID)
    return (units_produced, TRUE)
end

@external
func _build_espionage_probe_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, number_of_units : felt) -> (
    metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = Shipyard.espionage_probe_cost(
        number_of_units
    )
    assert_not_zero(caller)
    Shipyard.check_que_not_busy(caller)
    Shipyard.espionage_probe_requirements_check(caller)
    Shipyard.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    Shipyard.set_timelock_and_que(
        caller,
        Shipyard.ESPIONAGE_PROBE_ID,
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
    Shipyard.check_trying_to_complete_the_right_ship(caller, Shipyard.ESPIONAGE_PROBE_ID)
    let (units_produced) = Shipyard.check_waited_enough(caller)
    Shipyard.reset_timelock(caller)
    Shipyard.reset_que(caller, Shipyard.ESPIONAGE_PROBE_ID)
    return (units_produced, TRUE)
end

@external
func _build_solar_satellite_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, number_of_units : felt) -> (
    metal_spent : felt, crystal_spent : felt, deuterium_spent : felt
):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = Shipyard.solar_satellite_cost(
        number_of_units
    )
    assert_not_zero(caller)
    Shipyard.check_que_not_busy(caller)
    Shipyard.solar_satellite_requirements_check(caller)
    Shipyard.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    Shipyard.set_timelock_and_que(
        caller,
        Shipyard.SOLAR_SATELLITE_ID,
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
    Shipyard.check_trying_to_complete_the_right_ship(caller, Shipyard.SOLAR_SATELLITE_ID)
    let (units_produced) = Shipyard.check_waited_enough(caller)
    Shipyard.reset_timelock(caller)
    Shipyard.reset_que(caller, Shipyard.SOLAR_SATELLITE_ID)
    return (units_produced, TRUE)
end

@external
func _build_light_fighter_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, number_of_units : felt
) -> (metal_spent : felt, crystal_spent : felt, deuterium_spent : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = Shipyard.light_fighter_cost(
        number_of_units
    )
    assert_not_zero(caller)
    Shipyard.check_que_not_busy(caller)
    Shipyard.light_fighter_requirements_check(caller)
    Shipyard.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    Shipyard.set_timelock_and_que(
        caller,
        Shipyard.LIGHT_FIGHTER_ID,
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
    Shipyard.check_trying_to_complete_the_right_ship(caller, Shipyard.LIGHT_FIGHTER_ID)
    let (units_produced) = Shipyard.check_waited_enough(caller)
    Shipyard.reset_timelock(caller)
    Shipyard.reset_que(caller, Shipyard.LIGHT_FIGHTER_ID)
    return (units_produced, TRUE)
end

@external
func _build_cruiser_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, number_of_units : felt
) -> (metal_spent : felt, crystal_spent : felt, deuterium_spent : felt):
    alloc_locals
    let (metal_required, crystal_required, deuterium_required) = Shipyard.cruiser_cost(number_of_units)
    assert_not_zero(caller)
    Shipyard.check_que_not_busy(caller)
    Shipyard.cruiser_requirements_check(caller)
    Shipyard.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
    Shipyard.set_timelock_and_que(
        caller,
        Shipyard.CRUISER_ID,
        number_of_units,
        metal_required,
        crystal_required,
        deuterium_required,
    )
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _build_cruiser_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (units_produced : felt, success : felt):
    alloc_locals
    Shipyard.check_trying_to_complete_the_right_ship(caller, Shipyard.CRUISER_ID)
    let (units_produced) = Shipyard.check_waited_enough(caller)
    Shipyard.reset_timelock(caller)
    Shipyard.reset_que(caller, Shipyard.CRUISER_ID)
    return (units_produced, TRUE)
end

# @external
# Shipyard.func _build_battleship_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     caller : felt, number_of_units : felt
# ) -> (metal_spent : felt, crystal_spent : felt, deuterium_spent : felt):
#     Shipyard.alloc_locals
#     let (metal_required, crystal_required, deuterium_required) = _battleship_cost(
#         number_of_units
#     )
#     assert_not_zero(caller)
#     Shipyard.check_que_not_busy(caller)
#     Shipyard.battleship_requirements_check(caller)
#     Shipyard.check_enough_resources(caller, metal_required, crystal_required, deuterium_required)
#     Shipyard.set_timelock_and_que(
#         caller,
#         Shipyard.BATTLESHIP_ID,
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
#     Shipyard.check_trying_to_complete_the_right_ship(caller, Shipyard.BATTLESHIP_ID)
#     let (units_produced) = Shipyard.check_waited_enough(caller)
#     Shipyard.reset_timelock(caller)
#     Shipyard.reset_que(caller, Shipyard.BATTLESHIP_ID)
#     return (units_produced, TRUE)
