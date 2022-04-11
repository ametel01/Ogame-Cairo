%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256
from contracts.FacilitiesManager import _start_robot_factory_upgrade, _end_robot_factory_upgrade
from contracts.StructuresManager import (
    get_upgrades_cost, _generate_planet, _start_metal_upgrade, _end_metal_upgrade,
    _start_crystal_upgrade, _end_crystal_upgrade, _start_deuterium_upgrade, _end_deuterium_upgrade,
    _start_solar_plant_upgrade, _end_solar_plant_upgrade, _get_planet)
from contracts.ResourcesManager import (
    _collect_resources, _get_net_energy, _calculate_available_resources)
from contracts.utils.library import (
    Planet, Cost, _number_of_planets, _planets, _planet_to_owner, erc721_token_address,
    erc20_metal_address, erc20_crystal_address, erc20_deuterium_address, buildings_timelock,
    building_qued)
from contracts.utils.Formulas import (
    formulas_metal_building, formulas_crystal_building, formulas_deuterium_building,
    formulas_calculate_player_points)
from contracts.utils.Ownable import Ownable_initializer, Ownable_only_owner

#########################################################################################
#                                       Getters                                         #
#########################################################################################

@view
func number_of_planets{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        n_planets : felt):
    let (n) = _number_of_planets.read()
    return (n_planets=n)
end

@view
func owner_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt) -> (planet_id : Uint256):
    let (id) = _planet_to_owner.read(address)
    return (id)
end

@view
func erc721_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = erc721_token_address.read()
    return (res)
end

@view
func metal_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = erc20_metal_address.read()
    return (res)
end

@view
func crystal_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = erc20_crystal_address.read()
    return (res)
end

@view
func deuterium_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = erc20_deuterium_address.read()
    return (res)
end

@view
func get_structures_levels{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        your_address : felt) -> (
        metal_mine : felt, crystal_mine : felt, deuterium_mine : felt, solar_plant : felt,
        robot_factory : felt):
    let (id) = _planet_to_owner.read(your_address)
    let (planet) = _planets.read(id)
    let metal = planet.mines.metal
    let crystal = planet.mines.crystal
    let deuterium = planet.mines.deuterium
    let solar_plant = planet.energy.solar_plant
    let robot_factory = planet.facilities.robot_factory
    return (
        metal_mine=metal,
        crystal_mine=crystal,
        deuterium_mine=deuterium,
        solar_plant=solar_plant,
        robot_factory=robot_factory)
end

@view
func resources_available{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        your_address : felt) -> (metal : felt, crystal : felt, deuterium : felt, energy : felt):
    alloc_locals
    let (id) = _planet_to_owner.read(your_address)
    let (planet) = _planets.read(id)
    let (metal_available, crystal_available, deuterium_available) = _calculate_available_resources(
        your_address)
    let metal = planet.mines.metal
    let crystal = planet.mines.crystal
    let deuterium = planet.mines.deuterium
    let solar_plant = planet.energy.solar_plant
    let (energy_available) = _get_net_energy(metal, crystal, deuterium, solar_plant)
    return (metal_available, crystal_available, deuterium_available, energy_available)
end

@view
func get_structures_upgrade_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        your_address : felt) -> (
        metal_mine : Cost, crystal_mine : Cost, deuterium_mine : Cost, solar_plant : Cost,
        robot_factory : Cost):
    let (metal, crystal, deuterium, solar_plant, robot_factory) = get_upgrades_cost(your_address)
    return (metal, crystal, deuterium, solar_plant, robot_factory)
end

@view
func build_time_completion{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        your_address : felt) -> (building_id : felt, time_end : felt):
    let (que_details) = buildings_timelock.read(your_address)
    let time_end = que_details.lock_end
    let building_id = que_details.id
    return (building_id, time_end)
end

@view
func player_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        your_address : felt) -> (points : felt):
    let (points) = formulas_calculate_player_points(your_address)
    return (points)
end

#########################################################################################
#                                   Constructor                                         #
#########################################################################################

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        erc721_address : felt, owner : felt):
    erc721_token_address.write(erc721_address)
    Ownable_initializer(owner)
    return ()
end

##########################################################################################
#                                      Externals                                         #
##########################################################################################

@external
func erc20_addresses{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        metal_token : felt, crystal_token : felt, deuterium_token : felt):
    Ownable_only_owner()
    erc20_metal_address.write(metal_token)
    erc20_crystal_address.write(crystal_token)
    erc20_deuterium_address.write(deuterium_token)
    return ()
end

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
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _end_solar_plant_upgrade()
    return ()
end

@external
func robot_factory_upgrade_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
    _start_robot_factory_upgrade()
    return ()
end

@external
func robot_factory_upgrade_complete{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    _end_robot_factory_upgrade()
    return ()
end
