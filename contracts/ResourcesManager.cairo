%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.uint256 import Uint256
from contracts.token.erc20.interfaces.IERC20 import IERC20
from contracts.utils.library import (
    _planet_to_owner, _planets, Planet, MineLevels, MineStorage, Energy, erc20_metal_address,
    erc20_crystal_address, erc20_deuterium_address, FALSE)
from contracts.utils.Formulas import (
    _consumption, _consumption_deuterium, formulas_metal_mine, formulas_crystal_mine,
    formulas_deuterium_mine, formulas_solar_plant, formulas_production_scaler)

func _collect_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller : felt):
    alloc_locals
    let (planet_id) = _planet_to_owner.read(caller)
    let (planet) = _planets.read(planet_id)
    let time_start = planet.timer
    let metal_level = planet.mines.metal
    let crystal_level = planet.mines.crystal
    let deuterium_level = planet.mines.deuterium
    # Calculate energy requirerments.
    let (energy_required_metal) = _consumption(metal_level)
    let (energy_required_crystal) = _consumption(crystal_level)
    let (energy_required_deuterium) = _consumption_deuterium(deuterium_level)
    let total_energy_required = energy_required_metal + energy_required_crystal + energy_required_deuterium
    let solar_plant_level = planet.energy.solar_plant
    let (energy_available) = formulas_solar_plant(solar_plant_level)

    let (enough_energy) = is_le(total_energy_required, energy_available)
    # Calculate amount of resources produced.
    let (metal_produced) = formulas_metal_mine(last_timestamp=time_start, mine_level=metal_level)
    let (crystal_produced) = formulas_crystal_mine(
        last_timestamp=time_start, mine_level=crystal_level)
    let (deuterium_produced) = formulas_deuterium_mine(
        last_timestamp=time_start, mine_level=deuterium_level)
    # If energy available < than energy required scale down amount produced.
    if enough_energy == FALSE:
        let (actual_metal, actual_crystal, actual_deuterium) = formulas_production_scaler(
            net_metal=metal_produced,
            net_crystal=crystal_produced,
            net_deuterium=deuterium_produced,
            energy_required=total_energy_required,
            energy_available=energy_available)
        let (time_now) = get_block_timestamp()
        let updated_planet = Planet(
            MineLevels(metal=1, crystal=1, deuterium=1),
            MineStorage(metal=planet.storage.metal + actual_metal,
            crystal=planet.storage.crystal + actual_crystal,
            deuterium=planet.storage.deuterium + actual_deuterium),
            Energy(solar_plant=1),
            timer=time_now)
        _planets.write(planet_id, updated_planet)
        # Update ERC20 contract for resources
        _update_resources_erc20(
            to=caller,
            metal_amount=actual_metal,
            crystal_amount=actual_crystal,
            deuterium_amount=actual_deuterium)
    else:
        let (time_now) = get_block_timestamp()
        let updated_planet = Planet(
            MineLevels(metal=1, crystal=1, deuterium=1),
            MineStorage(metal=planet.storage.metal + metal_produced,
            crystal=planet.storage.crystal + crystal_produced,
            deuterium=planet.storage.deuterium + deuterium_produced),
            Energy(solar_plant=planet.energy.solar_plant),
            timer=time_now)
        _planets.write(planet_id, updated_planet)
        # Update ERC20 contract for resources
        _update_resources_erc20(
            to=caller,
            metal_amount=metal_produced,
            crystal_amount=crystal_produced,
            deuterium_amount=deuterium_produced)
    end
    return ()
end

# Updates the ERC20 resources contract
func _update_resources_erc20{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        to : felt, metal_amount : felt, crystal_amount : felt, deuterium_amount : felt):
    let (metal_address) = erc20_metal_address.read()
    let (crystal_address) = erc20_crystal_address.read()
    let (deuterium_address) = erc20_deuterium_address.read()
    let metal = Uint256(metal_amount, 0)
    let crystal = Uint256(crystal_amount, 0)
    let deuterium = Uint256(deuterium_amount, 0)
    IERC20.transfer(metal_address, to, metal)
    IERC20.transfer(crystal_address, to, crystal)
    IERC20.transfer(deuterium_address, to, deuterium)
    return ()
end
