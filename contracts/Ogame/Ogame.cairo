%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from starkware.cairo.common.uint256 import Uint256
from contracts.utils.constants import TRUE, RESEARCH_LAB_BUILDING_ID, SHIPYARD_BUILDING_ID
from contracts.FacilitiesManager import _start_robot_factory_upgrade, _end_robot_factory_upgrade
from contracts.StructuresManager import (
    get_upgrades_cost,
    _generate_planet,
    _start_metal_upgrade,
    _end_metal_upgrade,
    _start_crystal_upgrade,
    _end_crystal_upgrade,
    _start_deuterium_upgrade,
    _end_deuterium_upgrade,
    _start_solar_plant_upgrade,
    _end_solar_plant_upgrade,
    _get_planet,
)
from contracts.ResourcesManager import (
    _collect_resources,
    _get_net_energy,
    _calculate_available_resources,
    _pay_resources_erc20,
)
from contracts.utils.library import (
    _number_of_planets,
    _planets,
    _planet_to_owner,
    erc721_token_address,
    erc20_metal_address,
    erc20_crystal_address,
    erc20_deuterium_address,
    _research_lab_address,
    _research_lab_level,
    _shipyard_address,
    _shipyard_level,
    buildings_timelock,
    building_qued,
    _players_spent_resources,
    reset_timelock,
    reset_building_que,
)
from contracts.utils.Formulas import (
    formulas_metal_building,
    formulas_crystal_building,
    formulas_deuterium_building,
    formulas_calculate_player_points,
)
from contracts.utils.Ownable import Ownable_initializer, Ownable_only_owner
from contracts.ResearchLab.IResearchLab import IResearchLab
from contracts.Shipyard.IShipyard import IShipyard
from contracts.Ogame.storage import (
    _energy_tech,
    _computer_tech,
    _laser_tech,
    _armour_tech,
    _astrophysics,
    _espionage_tech,
    _hyperspace_drive,
    _hyperspace_tech,
    _impulse_drive,
    _ion_tech,
    _plasma_tech,
    _weapons_tech,
    _shielding_tech,
    _combustion_drive,
    _ships_cargo,
    _ships_recycler,
    _ships_espionage_probe,
    _ships_solar_satellite,
    _ships_light_fighter,
    _ships_cruiser,
    _ships_battleship,
    _ships_deathstar,
)
from contracts.Ogame.structs import (
    TechLevels,
    BuildingQue,
    Cost,
    Planet,
    MineLevels,
    Energy,
    Facilities,
    Fleet,
)
#########################################################################################
#                                   Constructor                                         #
#########################################################################################

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    erc721_address : felt, owner : felt
):
    erc721_token_address.write(erc721_address)
    Ownable_initializer(owner)
    return ()
end

#########################################################################################
#                                       Getters                                         #
#########################################################################################

@view
func number_of_planets{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    n_planets : felt
):
    let (n) = _number_of_planets.read()
    return (n_planets=n)
end

@view
func owner_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (planet_id : Uint256):
    let (id) = _planet_to_owner.read(address)
    return (id)
end

@view
func erc721_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (res) = erc721_token_address.read()
    return (res)
end

@view
func metal_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (res) = erc20_metal_address.read()
    return (res)
end

@view
func crystal_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (res) = erc20_crystal_address.read()
    return (res)
end

@view
func deuterium_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (res) = erc20_deuterium_address.read()
    return (res)
end

@view
func research_lab_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (res) = _research_lab_address.read()
    return (res)
end

@view
func shipyard_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (res) = _shipyard_address.read()
    return (res)
end

@view
func get_structures_levels{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (
    metal_mine : felt,
    crystal_mine : felt,
    deuterium_mine : felt,
    solar_plant : felt,
    robot_factory : felt,
    research_lab : felt,
    shipyard : felt,
):
    let (planet_id) = _planet_to_owner.read(caller)
    let (planet) = _planets.read(planet_id)
    let metal = planet.mines.metal
    let crystal = planet.mines.crystal
    let deuterium = planet.mines.deuterium
    let solar_plant = planet.energy.solar_plant
    let robot_factory = planet.facilities.robot_factory
    let (research_lab) = _research_lab_level.read(planet_id)
    let (shipyard) = _shipyard_level.read(planet_id)
    return (
        metal_mine=metal,
        crystal_mine=crystal,
        deuterium_mine=deuterium,
        solar_plant=solar_plant,
        robot_factory=robot_factory,
        research_lab=research_lab,
        shipyard=shipyard,
    )
end

@view
func resources_available{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (metal : felt, crystal : felt, deuterium : felt, energy : felt):
    alloc_locals
    let (id) = _planet_to_owner.read(caller)
    let (planet) = _planets.read(id)
    let (metal_available, crystal_available, deuterium_available) = _calculate_available_resources(
        caller
    )
    let metal = planet.mines.metal
    let crystal = planet.mines.crystal
    let deuterium = planet.mines.deuterium
    let solar_plant = planet.energy.solar_plant
    let (energy_available) = _get_net_energy(metal, crystal, deuterium, solar_plant)
    return (metal_available, crystal_available, deuterium_available, energy_available)
end

@view
func get_structures_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (
    metal_mine : Cost,
    crystal_mine : Cost,
    deuterium_mine : Cost,
    solar_plant : Cost,
    robot_factory : Cost,
):
    let (metal, crystal, deuterium, solar_plant, robot_factory) = get_upgrades_cost(caller)
    return (metal, crystal, deuterium, solar_plant, robot_factory)
end

@view
func build_time_completion{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (building_id : felt, time_end : felt):
    let (que_details) = buildings_timelock.read(caller)
    let time_end = que_details.lock_end
    let building_id = que_details.id
    return (building_id, time_end)
end

@view
func get_buildings_timelock_status{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(caller : felt) -> (status : BuildingQue):
    let (que_details) = buildings_timelock.read(caller)
    return (que_details)
end

@view
func is_building_qued{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt, building_id : felt
) -> (status : felt):
    let (que_status) = building_qued.read(caller, building_id)
    return (que_status)
end

@view
func player_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (points : felt):
    let (points) = formulas_calculate_player_points(caller)
    return (points)
end

##########################################################################################
#                                      Externals                                         #
##########################################################################################

@external
func erc20_addresses{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    metal_token : felt, crystal_token : felt, deuterium_token : felt
):
    Ownable_only_owner()
    erc20_metal_address.write(metal_token)
    erc20_crystal_address.write(crystal_token)
    erc20_deuterium_address.write(deuterium_token)
    return ()
end

@external
func set_facilities_addresses{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    lab_address : felt, shipyard_address : felt
):
    Ownable_only_owner()
    _research_lab_address.write(lab_address)
    _shipyard_address.write(shipyard_address)
    return ()
end

# @external
# func facilities_addresses{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     research_lab_address : felt
# ):
#     Ownable_only_owner()
#     _research_lab_address.write(research_lab_address)
#     return ()
# end

@external
func generate_planet{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    _generate_planet(caller)
    return ()
end

@external
func collect_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (address) = get_caller_address()
    assert_not_zero(address)
    let (id) = _planet_to_owner.read(address)
    _collect_resources(address)
    return ()
end

##############################################################################################
#                               RESOURCES EXTERNALS FUNCS                                    #
##############################################################################################

@external
func metal_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _start_metal_upgrade()
    return ()
end

@external
func metal_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _end_metal_upgrade()
    return ()
end

@external
func crystal_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _start_crystal_upgrade()
    return ()
end

@external
func crystal_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _end_crystal_upgrade()
    return ()
end

@external
func deuterium_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _start_deuterium_upgrade()
    return ()
end

@external
func deuterium_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    _end_deuterium_upgrade()
    return ()
end

@external
func solar_plant_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _start_solar_plant_upgrade()
    return ()
end

@external
func solar_plant_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    _end_solar_plant_upgrade()
    return ()
end

##############################################################################################
#                              FACILITIES EXTERNALS FUNCS                                    #
##############################################################################################

@external
func robot_factory_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    _start_robot_factory_upgrade()
    return ()
end

@external
func robot_factory_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    _end_robot_factory_upgrade()
    return ()
end

@external
func research_lab_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (
        metal_spent, crystal_spent, deuterium_spent, time_unlocked
    ) = IResearchLab._research_lab_upgrade_start(lab_address, caller)
    _pay_resources_erc20(caller, metal_spent, crystal_spent, deuterium_spent)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal_spent + crystal_spent
    _players_spent_resources.write(caller, new_total_spent)
    let que_details = BuildingQue(RESEARCH_LAB_BUILDING_ID, time_unlocked)
    buildings_timelock.write(caller, que_details)
    building_qued.write(caller, RESEARCH_LAB_BUILDING_ID, TRUE)

    return ()
end

@external
func research_lab_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (lab_address) = _research_lab_address.read()
    let (success) = IResearchLab._research_lab_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_lab_level) = _research_lab_level.read(planet_id)
    _research_lab_level.write(planet_id, current_lab_level + 1)
    reset_timelock(caller)
    reset_building_que(caller, RESEARCH_LAB_BUILDING_ID)
    return ()
end

@external
func shipyard_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (shipyard_address) = _shipyard_address.read()
    let (
        metal_spent, crystal_spent, deuterium_spent, time_unlocked
    ) = IShipyard._shipyard_upgrade_start(shipyard_address, caller)
    _pay_resources_erc20(caller, metal_spent, crystal_spent, deuterium_spent)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal_spent + crystal_spent
    _players_spent_resources.write(caller, new_total_spent)
    let que_details = BuildingQue(SHIPYARD_BUILDING_ID, time_unlocked)
    buildings_timelock.write(caller, que_details)
    building_qued.write(caller, SHIPYARD_BUILDING_ID, TRUE)

    return ()
end

@external
func shipyard_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (shipyard_address) = _shipyard_address.read()
    let (success) = IShipyard._shipyard_upgrade_complete(shipyard_address, caller)
    assert success = TRUE
    let (current_shipyard_level) = _shipyard_level.read(planet_id)
    _shipyard_level.write(planet_id, current_shipyard_level + 1)
    reset_timelock(caller)
    reset_building_que(caller, SHIPYARD_BUILDING_ID)
    return ()
end

##############################################################################################
#                              RESEARCH EXTERNALS FUNCS                                      #
##############################################################################################
@external
func energy_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _energy_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._energy_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func energy_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._energy_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _energy_tech.read(planet_id)
    _energy_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func computer_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _computer_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._computer_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func computer_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._computer_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _computer_tech.read(planet_id)
    _computer_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func laser_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _laser_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._laser_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func laser_tech_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._laser_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _laser_tech.read(planet_id)
    _laser_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func armour_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _armour_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._armour_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func armour_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._armour_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _armour_tech.read(planet_id)
    _armour_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func ion_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _ion_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._ion_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func ion_tech_upgrade_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._ion_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _ion_tech.read(planet_id)
    _ion_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func espionage_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _espionage_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._espionage_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func espionage_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._espionage_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _espionage_tech.read(planet_id)
    _espionage_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func plasma_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _plasma_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._plasma_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func plasma_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._plasma_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _plasma_tech.read(planet_id)
    _plasma_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func weapons_tech_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _weapons_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._weapons_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func weapons_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._weapons_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _weapons_tech.read(planet_id)
    _weapons_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func shielding_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _shielding_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._shielding_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func shielding_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._shielding_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _shielding_tech.read(planet_id)
    _shielding_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func hyperspace_tech_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _hyperspace_tech.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._hyperspace_tech_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func hyperspace_tech_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._hyperspace_tech_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _hyperspace_tech.read(planet_id)
    _hyperspace_tech.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func astrophysics_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _astrophysics.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._astrophysics_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func astrophysics_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._astrophysics_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _astrophysics.read(planet_id)
    _astrophysics.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func combustion_drive_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _combustion_drive.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._combustion_drive_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func combustion_drive_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._combustion_drive_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _combustion_drive.read(planet_id)
    _combustion_drive.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func hyperspace_drive_upgrade_start{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _hyperspace_drive.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._hyperspace_drive_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func hyperspace_drive_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._hyperspace_drive_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _hyperspace_drive.read(planet_id)
    _hyperspace_drive.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func impulse_drive_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (current_tech_level) = _impulse_drive.read(planet_id)
    let (lab_address) = _research_lab_address.read()
    let (metal, crystal, deuterium) = IResearchLab._impulse_drive_upgrade_start(
        lab_address, caller, current_tech_level
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func impulse_drive_upgrade_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (lab_address) = _research_lab_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (success) = IResearchLab._impulse_drive_upgrade_complete(lab_address, caller)
    assert success = TRUE
    let (current_tech_level) = _impulse_drive.read(planet_id)
    _impulse_drive.write(planet_id, current_tech_level + 1)
    return ()
end

@external
func get_tech_levels{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (result : TechLevels):
    let (planet_id) = _planet_to_owner.read(caller)
    let (research_lab) = _research_lab_level.read(planet_id)
    let (armour_tech) = _armour_tech.read(planet_id)
    let (astrophysics) = _astrophysics.read(planet_id)
    let (combustion_drive) = _combustion_drive.read(planet_id)
    let (computer_tech) = _computer_tech.read(planet_id)
    let (energy_tech) = _energy_tech.read(planet_id)
    let (espionage_tech) = _espionage_tech.read(planet_id)
    let (hyperspace_drive) = _hyperspace_drive.read(planet_id)
    let (hyperspace_tech) = _hyperspace_tech.read(planet_id)
    let (impulse_drive) = _impulse_drive.read(planet_id)
    let (ion_tech) = _ion_tech.read(planet_id)
    let (laser_tech) = _laser_tech.read(planet_id)
    let (plasma_tech) = _plasma_tech.read(planet_id)
    let (shielding_tech) = _shielding_tech.read(planet_id)
    let (weapons_tech) = _weapons_tech.read(planet_id)

    return (
        TechLevels(research_lab, armour_tech, astrophysics, combustion_drive, computer_tech, energy_tech, espionage_tech, hyperspace_drive, hyperspace_tech, impulse_drive, ion_tech, laser_tech, plasma_tech, shielding_tech, weapons_tech),
    )
end

#########################################################################################################
#                                           SHIPYARD FUNCTIONS                                          #
#########################################################################################################

@external
func cargo_ship_build_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    number_of_units : felt
):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (shipyard_address) = _shipyard_address.read()
    let (metal, crystal, deuterium) = IShipyard._cargo_ship_build_start(
        shipyard_address, caller, number_of_units
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func cargo_ship_build_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (shipyard_address) = _shipyard_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (units_produced, success) = IShipyard._cargo_ship_build_complete(shipyard_address, caller)
    assert success = TRUE
    let (current_amount_of_units) = _ships_cargo.read(planet_id)
    _ships_cargo.write(planet_id, current_amount_of_units + units_produced)
    return ()
end

@external
func recycler_ship_build_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    number_of_units : felt
):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (shipyard_address) = _shipyard_address.read()
    let (metal, crystal, deuterium) = IShipyard._build_recycler_ship_start(
        shipyard_address, caller, number_of_units
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func recycler_ship_build_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (shipyard_address) = _shipyard_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (units_produced, success) = IShipyard._build_recycler_ship_complete(
        shipyard_address, caller
    )
    assert success = TRUE
    let (current_amount_of_units) = _ships_recycler.read(planet_id)
    _ships_recycler.write(planet_id, current_amount_of_units + units_produced)
    return ()
end

@external
func espionage_probe_build_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    number_of_units : felt
):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (shipyard_address) = _shipyard_address.read()
    let (metal, crystal, deuterium) = IShipyard._build_espionage_probe_start(
        shipyard_address, caller, number_of_units
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func espionage_probe_build_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (shipyard_address) = _shipyard_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (units_produced, success) = IShipyard._build_espionage_probe_complete(
        shipyard_address, caller
    )
    assert success = TRUE
    let (current_amount_of_units) = _ships_espionage_probe.read(planet_id)
    _ships_espionage_probe.write(planet_id, current_amount_of_units + units_produced)
    return ()
end

@external
func solar_satellite_build_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    number_of_units : felt
):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (shipyard_address) = _shipyard_address.read()
    let (metal, crystal, deuterium) = IShipyard._build_solar_satellite_start(
        shipyard_address, caller, number_of_units
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func solar_satellite_build_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (shipyard_address) = _shipyard_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (units_produced, success) = IShipyard._build_solar_satellite_complete(
        shipyard_address, caller
    )
    assert success = TRUE
    let (current_amount_of_units) = _ships_solar_satellite.read(planet_id)
    _ships_solar_satellite.write(planet_id, current_amount_of_units + units_produced)
    return ()
end

@external
func light_fighter_build_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    number_of_units : felt
):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (shipyard_address) = _shipyard_address.read()
    let (metal, crystal, deuterium) = IShipyard._build_light_fighter_start(
        shipyard_address, caller, number_of_units
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func light_fighter_build_complete{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller) = get_caller_address()
    let (shipyard_address) = _shipyard_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (units_produced, success) = IShipyard._build_light_fighter_complete(
        shipyard_address, caller
    )
    assert success = TRUE
    let (current_amount_of_units) = _ships_light_fighter.read(planet_id)
    _ships_light_fighter.write(planet_id, current_amount_of_units + units_produced)
    return ()
end

@external
func cruiser_build_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    number_of_units : felt
):
    let (caller) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(caller)
    let (shipyard_address) = _shipyard_address.read()
    let (metal, crystal, deuterium) = IShipyard._build_cruiser_start(
        shipyard_address, caller, number_of_units
    )
    _pay_resources_erc20(caller, metal, crystal, deuterium)
    let (spent_so_far) = _players_spent_resources.read(caller)
    let new_total_spent = spent_so_far + metal + crystal
    _players_spent_resources.write(caller, new_total_spent)
    return ()
end

@external
func cruiser_build_complete{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (shipyard_address) = _shipyard_address.read()
    let (planet_id) = _planet_to_owner.read(caller)
    let (units_produced, success) = IShipyard._build_cruiser_complete(shipyard_address, caller)
    assert success = TRUE
    let (current_amount_of_units) = _ships_cruiser.read(planet_id)
    _ships_cruiser.write(planet_id, current_amount_of_units + units_produced)
    return ()
end

# @external
# func battelship_build_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     number_of_units : felt
# ):
#     let (caller) = get_caller_address()
#     let (planet_id) = _planet_to_owner.read(caller)
#     let (shipyard_address) = _shipyard_address.read()
#     let (metal, crystal, deuterium) = IShipyard._build_battleship_start(
#         shipyard_address, caller, number_of_units
#     )
#     _pay_resources_erc20(caller, metal, crystal, deuterium)
#     let (spent_so_far) = _players_spent_resources.read(caller)
#     let new_total_spent = spent_so_far + metal + crystal
#     _players_spent_resources.write(caller, new_total_spent)
#     return ()
# end

# @external
# func battleship_build_complete{
#     syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
# }():
#     let (caller) = get_caller_address()
#     let (shipyard_address) = _shipyard_address.read()
#     let (planet_id) = _planet_to_owner.read(caller)
#     let (units_produced, success) = IShipyard._build_battleship_complete(
#         shipyard_address, caller
#     )
#     assert success = TRUE
#     let (current_amount_of_units) = _ships_battleship.read(planet_id)
#     _ships_battleship.write(planetr_id, current_amount_of_units + units_produced)
#     return ()
# end

@external
func get_fleet{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    caller : felt
) -> (result : Fleet):
    let (planet_id) = _planet_to_owner.read(caller)
    let (shipyard) = _shipyard_level.read(planet_id)
    let (cargo_ship) = _ships_cargo.read(planet_id)
    let (recycler_ship) = _ships_recycler.read(planet_id)
    let (espionage_probe) = _ships_espionage_probe.read(planet_id)
    let (solar_satellite) = _ships_solar_satellite.read(planet_id)
    let (light_fighter) = _ships_light_fighter.read(planet_id)
    let (cruiser) = _ships_cruiser.read(planet_id)
    let (battleship) = _ships_battleship.read(planet_id)
    let (deathstar) = _ships_deathstar.read(planet_id)
    return (
        Fleet(shipyard, cargo_ship, recycler_ship, espionage_probe, solar_satellite, light_fighter, cruiser, battleship, deathstar),
    )
end

#########################################################################################################
#                                           GOD MODE                                                    #
#                       @external TO BE REMOVED BEFORE DEPLOYMENT                                       #
#########################################################################################################

@external
func GOD_MODE{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    preset_techs : TechLevels, preset_fleet : Fleet
):
    let (caller) = get_caller_address()
    let (time_now) = get_block_timestamp()
    let planet = Planet(
        MineLevels(metal=25, crystal=23, deuterium=21),
        Energy(solar_plant=30),
        Facilities(robot_factory=20),
    )
    let planet_id = Uint256(1, 0)
    _planet_to_owner.write(caller, planet_id)
    _planets.write(planet_id, planet)
    # Techs setups
    _research_lab_level.write(planet_id, preset_techs.research_lab)
    _energy_tech.write(planet_id, preset_techs.energy_tech)
    _laser_tech.write(planet_id, preset_techs.laser_tech)
    _computer_tech.write(planet_id, preset_techs.computer_tech)
    _armour_tech.write(planet_id, preset_techs.armour_tech)
    _ion_tech.write(planet_id, preset_techs.ion_tech)
    _espionage_tech.write(planet_id, preset_techs.espionage_tech)
    _plasma_tech.write(planet_id, preset_techs.plasma_tech)
    _weapons_tech.write(planet_id, preset_techs.weapons_tech)
    _shielding_tech.write(planet_id, preset_techs.shielding_tech)
    _hyperspace_tech.write(planet_id, preset_techs.hyperspace_tech)
    _astrophysics.write(planet_id, preset_techs.astrophysics)
    _combustion_drive.write(planet_id, preset_techs.combustion_drive)
    _hyperspace_drive.write(planet_id, preset_techs.hyperspace_drive)
    _impulse_drive.write(planet_id, preset_techs.impulse_drive)

    # Fleet setup
    _shipyard_level.write(planet_id, preset_fleet.shipyard)
    _ships_cargo.write(planet_id, preset_fleet.cargo)
    _ships_recycler.write(planet_id, preset_fleet.recycler)
    _ships_espionage_probe.write(planet_id, preset_fleet.espionage_probe)
    _ships_solar_satellite.write(planet_id, preset_fleet.solar_satellite)
    _ships_light_fighter.write(planet_id, preset_fleet.light_fighter)
    _ships_cruiser.write(planet_id, preset_fleet.cruiser)
    _ships_battleship.write(planet_id, preset_fleet.battle_ship)
    _ships_deathstar.write(planet_id, preset_fleet.death_star)
    return ()
end
