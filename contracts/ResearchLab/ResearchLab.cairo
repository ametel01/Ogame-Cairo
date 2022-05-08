%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from contracts.ResearchLab.library import (
    _ogame_address,
    research_lab_upgrade_cost,
    energy_tech_upgrade_cost,
    energy_tech_requirements_check,
    computer_tech_upgrade_cost,
    computer_tech_requirements_check,
    laser_tech_requirements_check,
    laser_tech_upgrade_cost,
    armour_tech_requirements_check,
    armour_tech_upgrade_cost,
    ion_tech_requirements_check,
    ion_tech_upgrade_cost,
    espionage_tech_requirements_check,
    espionage_tech_upgrade_cost,
    plasma_tech_requirements_check,
    plasma_tech_upgrade_cost,
    weapons_tech_requirements_check,
    weapons_tech_upgrade_cost,
    shielding_tech_requirements_check,
    shieldieng_tech_upgrade_cost,
    hyperspace_tech_requirements_check,
    hyperspace_tech_upgrade_cost,
    astrophysics_requirements_check,
    astrophysics_upgrade_cost,
    get_available_resources,
    ResearchQue,
    research_timelock,
    research_qued,
    ENERGY_TECH_ID,
    COMPUTER_TECH_ID,
    LASER_TECH_ID,
    ARMOUR_TECH_ID,
    ION_TECH_ID,
    ESPIONAGE_TECH_ID,
    PLASMA_TECH_ID,
    WEAPONS_TECH_ID,
    SHIELDING_TECH_ID,
    HYPERSPACE_TECH_ID,
    ASTROPHYSICS_TECH_ID,
    reset_research_que,
    reset_research_timelock,
)
from contracts.token.erc20.interfaces.IERC20 import IERC20
from contracts.ResourcesManager import _pay_resources_erc20
from contracts.Ogame.IOgame import IOgame
from contracts.utils.Formulas import formulas_buildings_production_time
from contracts.utils.constants import RESEARCH_LAB_BUILDING_ID, UINT256_DECIMALS, TRUE

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ogame_address : felt
):
    _ogame_address.write(ogame_address)
    return ()
end

# ######### UPGRADES FUNCS ############################
@external
func _research_lab_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
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
    let (tech_levels) = IOgame.get_tech_levels(ogame_address, planet_id)
    let (_, _, _, _, robot_factory_level, _) = IOgame.get_structures_levels(ogame_address, caller)
    let current_lab_level = tech_levels.research_lab
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = research_lab_upgrade_cost(
        current_lab_level
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
func _research_lab_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    let (ogame_address) = _ogame_address.read()
    let (is_qued) = IOgame.is_building_qued(ogame_address, caller, RESEARCH_LAB_BUILDING_ID)
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

@external
func _energy_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = energy_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = energy_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(ENERGY_TECH_ID, time_end)
    research_qued.write(caller, ENERGY_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _energy_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, ENERGY_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, ENERGY_TECH_ID)
    return (TRUE)
end

@external
func _computer_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = computer_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = computer_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(COMPUTER_TECH_ID, time_end)
    research_qued.write(caller, COMPUTER_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _computer_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, COMPUTER_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, COMPUTER_TECH_ID)
    return (TRUE)
end

@external
func _laser_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = laser_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = laser_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(LASER_TECH_ID, time_end)
    research_qued.write(caller, LASER_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _laser_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, LASER_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, LASER_TECH_ID)
    return (TRUE)
end

@external
func _armour_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = armour_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = armour_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(ARMOUR_TECH_ID, time_end)
    research_qued.write(caller, ARMOUR_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _armour_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, ARMOUR_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, ARMOUR_TECH_ID)
    return (TRUE)
end

@external
func _ion_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = ion_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = ion_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(ION_TECH_ID, time_end)
    research_qued.write(caller, ION_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _ion_tech_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, ION_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, ION_TECH_ID)
    return (TRUE)
end

@external
func _espionage_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = espionage_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = espionage_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(ESPIONAGE_TECH_ID, time_end)
    research_qued.write(caller, ESPIONAGE_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _espionage_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, ESPIONAGE_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, ESPIONAGE_TECH_ID)
    return (TRUE)
end

@external
func _plasma_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = plasma_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = plasma_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(PLASMA_TECH_ID, time_end)
    research_qued.write(caller, PLASMA_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _plasma_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, PLASMA_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, PLASMA_TECH_ID)
    return (TRUE)
end

@external
func _weapons_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = weapons_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = weapons_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(WEAPONS_TECH_ID, time_end)
    research_qued.write(caller, WEAPONS_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _weapons_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, WEAPONS_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, WEAPONS_TECH_ID)
    return (TRUE)
end

@external
func _shielding_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = shieldieng_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = shielding_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(SHIELDING_TECH_ID, time_end)
    research_qued.write(caller, SHIELDING_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _shielding_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, SHIELDING_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, SHIELDING_TECH_ID)
    return (TRUE)
end

@external
func _hyperspace_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt, current_tech_level : felt) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = hyperspace_tech_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = hyperspace_tech_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(HYPERSPACE_TECH_ID, time_end)
    research_qued.write(caller, HYPERSPACE_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _hyperspace_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, HYPERSPACE_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, HYPERSPACE_TECH_ID)
    return (TRUE)
end

@external
func _astrophysics_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, current_tech_level : felt
) -> (metal : felt, crystal : felt, deuterium : felt):
    alloc_locals
    assert_not_zero(caller)
    let (que_status) = research_timelock.read(caller)
    let current_timelock = que_status.lock_end
    with_attr error_message("Research lab is busy"):
        assert current_timelock = 0
    end
    let (metal_available, crystal_available, deuterium_available) = get_available_resources(caller)
    let (metal_required, crystal_required, deuterium_required) = astrophysics_upgrade_cost(
        current_tech_level
    )
    let (requirements_met) = astrophysics_requirements_check(caller)
    assert requirements_met = TRUE
    with_attr error_message("not enough resources"):
        let (enough_metal) = is_le(metal_required, metal_available)
        assert enough_metal = TRUE
        let (enough_crystal) = is_le(crystal_required, crystal_available)
        assert enough_crystal = TRUE
        let (enough_deuterium) = is_le(deuterium_required, deuterium_available)
        assert enough_deuterium = TRUE
    end
    let (ogame_address) = _ogame_address.read()
    let (_, _, _, _, _, research_lab_level) = IOgame.get_structures_levels(ogame_address, caller)
    let (research_time) = formulas_buildings_production_time(
        metal_required, crystal_required, research_lab_level
    )
    let (time_now) = get_block_timestamp()
    let time_end = time_now + research_time
    let que_details = ResearchQue(ASTROPHYSICS_TECH_ID, time_end)
    research_qued.write(caller, ASTROPHYSICS_TECH_ID, TRUE)
    research_timelock.write(caller, que_details)
    return (metal_required, crystal_required, deuterium_required)
end

@external
func _astrophysics_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (success : felt):
    alloc_locals
    tempvar syscall_ptr = syscall_ptr
    let (time_now) = get_block_timestamp()
    let (is_qued) = research_qued.read(caller, ASTROPHYSICS_TECH_ID)
    with_attr error_message("Tried to complete the wrong technology"):
        assert is_qued = TRUE
    end
    let (cue_details) = research_timelock.read(caller)
    let timelock_end = cue_details.lock_end
    let (waited_enough) = is_le(timelock_end, time_now)
    with_attr error_message("Timelock not yet expired"):
        assert waited_enough = TRUE
    end
    reset_research_timelock(caller)
    reset_research_que(caller, ASTROPHYSICS_TECH_ID)
    return (TRUE)
end
