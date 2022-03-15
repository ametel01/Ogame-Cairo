%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_not_zero, assert_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import (get_caller_address, 
    get_block_timestamp, 
    get_contract_address)
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_unsigned_div_rem
from contracts.utils.constants import TRUE, FALSE
from contracts.utils.Formulas import (
    formulas_metal_mine, 
    formulas_crystal_mine, 
    formulas_deuterium_mine,
    formulas_metal_building,
    formulas_crystal_building,
    formulas_deuterium_building,
    formulas_solar_plant,
    _consumption,
    _consumption_deuterium,
    _production_limiter,
    formulas_production_scaler)
from contracts.utils.Math64x61 import Math64x61_mul
from contracts.token.erc721.interfaces.IERC721 import IERC721
from contracts.token.erc20.interfaces.IERC20 import IERC20



###########
# Structs #
###########
struct MineLevels:
    member metal : felt
    member crystal : felt
    member deuterium : felt
end

struct MineStorage:
    member metal : felt
    member crystal : felt
    member deuterium : felt
end

struct Energy:
    member solar_plant : felt
    #member satellites : felt
end

struct Planet:
    member mines : MineLevels
    member storage : MineStorage
    member energy : Energy
    member timer : felt
end

###########
# Storage #
###########

@storage_var
func PlanetFactory_number_of_planets() -> (n : felt):
end

@storage_var
func PlanetFactory_planets(planet_id : Uint256) -> (planet : Planet):
end

@storage_var
func PlanetFactory_planet_to_owner(address : felt) -> (planet_id : Uint256):
end

@storage_var
func erc721_token_address() -> (address : felt):
end

@storage_var
func erc721_owner_address() -> (address : felt):
end

@storage_var
func erc20_metal_address() -> (address : felt):
end

@storage_var
func erc20_crystal_address() -> (address : felt):
end

@storage_var
func erc20_deuterium_address() -> (address : felt):
end

##########
# Events #
##########

@event
func planet_genereted(planet_id : Uint256):
end

@event
func structure_updated(metal_used : felt, crystal_used : felt, deuterium_used : felt):
end

# Used to create the first planet for a player. It does register the new planet in the contract storage
# and send the NFT to the caller. At the moment planets IDs are incremental +1. TODO: implement a 
# random ID generator.
func PlanetFactory_generate_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
        }():
    alloc_locals
    let (time_now) = get_block_timestamp()
    let (local address) = get_caller_address()
    assert_not_zero(address)
    # One address can only have one planet at this stage.
    let (has_already_planet) = PlanetFactory_planet_to_owner.read(address)
    assert has_already_planet = Uint256(0,0)
    let planet = Planet(
        MineLevels(metal=1, crystal=1, deuterium=1),
        MineStorage(metal=500, crystal=300,deuterium=100),
        Energy(solar_plant=1),
        timer=time_now)
    # Transfer ERC721 to caller
    let (local erc721_address) = erc721_token_address.read()
    let (local last_id) = PlanetFactory_number_of_planets.read()
    let new_planet_id = Uint256(last_id+1, 0)
    let (erc721_owner) = IERC721.ownerOf(erc721_address, new_planet_id)
    IERC721.transferFrom(erc721_address, erc721_owner, address, new_planet_id)
    PlanetFactory_planet_to_owner.write(address, new_planet_id)
    PlanetFactory_planets.write(new_planet_id, planet)
    PlanetFactory_number_of_planets.write(last_id+1)
    planet_genereted.emit(new_planet_id)
    # Transfer resources ERC20 tokens to caller.
    _update_resources_erc20(to=address, 
                            metal_amount=500, 
                            crystal_amount=300,
                            deuterium_amount=100)
    return()
end

# func _gen_rand_id{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr,
#         }() -> (id : Uint256):
#     alloc_locals
#     let (time_now) = get_block_timestamp()
#     let (_, new_planet_id) = unsigned_div_rem(time_now, 10)
#     let id = Uint256(new_planet_id, 0)
#     return(id)
# end

func PlanetFactory_collect_resources{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(caller : felt):
    alloc_locals
    let (planet_id) = PlanetFactory_planet_to_owner.read(caller)
    let (planet) = PlanetFactory_planets.read(planet_id)
    let time_start = planet.timer
    let metal_level = planet.mines.metal
    let crystal_level = planet.mines.crystal
    let deuterium_level = planet.mines.deuterium
    # Calculate energy requirerments.
    let (energy_required_metal) = _consumption(metal_level)
    let (energy_required_crystal) = _consumption(crystal_level)
    let (energy_required_deuterium) = _consumption_deuterium(deuterium_level)
    let total_energy_required = energy_required_metal + energy_required_crystal + energy_required_deuterium
    let solar_plant_level = planet.energy.solar_plant_level
    let energy_available = formulas_solar_plant(solar_plant_level)
    let enough_energy = is_le(total_energy_required,energy_available)
    # Calculate amount of resources produced.
    let (metal_produced) = formulas_metal_mine(last_timestamp=time_start, mine_level=metal_level)
    let (crystal_produced) = formulas_crystal_mine(last_timestamp=time_start, mine_level=crystal_level)
    let (deuterium_produced) = formulas_deuterium_mine(last_timestamp=time_start, mine_level=deuterium_level)
    # If energy available < than energy required scale down amount produced.
    if enough_energy == FALSE:
        let (actual_metal, actual_crystal, actual_deuterium) = formulas_production_scaler(net_metal=metal_produced,
                                                                                        net_crystal=crystal_produced,
                                                                                        net_deuterium=deuterium_produced,
                                                                                        energy_required=total_energy_required,
                                                                                        energy_available=energy_available)
        let (time_now) = get_block_timestamp()
        let updated_planet = Planet(
                                MineLevels(metal=1,crystal=1,deuterium=1),
                                MineStorage(metal=planet.storage.metal + actual_metal,
                                        crystal=planet.storage.crystal + actual_crystal,
                                        deuterium=planet.storage.deuterium + actual_deuterium),
                                timer=time_now)
        PlanetFactory_planets.write(planet_id, updated_planet)
        # Update ERC20 contract for resources
        _update_resources_erc20(to=caller, 
                                metal_amount=actual_metal, 
                                crystal_amount=actual_crystal,
                                deuterium_amount=actual_deuterium)
    else:
        let (time_now) = get_block_timestamp()
        let updated_planet = Planet(
                                MineLevels(metal=1,crystal=1,deuterium=1),
                                MineStorage(metal=planet.storage.metal + metal_produced,
                                        crystal=planet.storage.crystal + crystal_produced,
                                        deuterium=planet.storage.deuterium + deuterium_produced),
                                timer=time_now)
        PlanetFactory_planets.write(planet_id, updated_planet)
        # Update ERC20 contract for resources
        _update_resources_erc20(to=caller, 
                                metal_amount=metal_produced, 
                                crystal_amount=crystal_produced,
                                deuterium_amount=deuterium_produced)
    end                                
    return()
end

func PlanetFactory_upgrade_metal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = PlanetFactory_planet_to_owner.read(address)
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let current_mine_level = planet.mines.metal
    let (metal_required, crystal_required) = formulas_metal_building(metal_mine_level=current_mine_level)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    assert_le(metal_required, metal_available)
    assert_le(crystal_required, crystal_available)
    let new_planet = Planet(
                        MineLevels(metal=current_mine_level + 1,
                                    crystal=planet.mines.crystal,
                                    deuterium=planet.mines.deuterium),
                        MineStorage(metal=metal_available - metal_required,
                                    crystal=crystal_available - crystal_required,
                                    deuterium = planet.storage.deuterium),
                        timer=planet.timer)             
    PlanetFactory_planets.write(planet_id, new_planet)
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end

func PlanetFactory_upgrade_crystal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = PlanetFactory_planet_to_owner.read(address)
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let current_mine_level = planet.mines.crystal
    let (metal_required, crystal_required) = formulas_crystal_building(crystal_mine_level=current_mine_level)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    assert_le(metal_required, metal_available)
    assert_le(crystal_required, crystal_available)
    let new_planet = Planet(
                        MineLevels(metal=planet.mines.metal,
                                    crystal=planet.mines.crystal + 1,
                                    deuterium=planet.mines.deuterium),
                        MineStorage(metal=metal_available - metal_required,
                                    crystal=crystal_available - crystal_required,
                                    deuterium=planet.storage.deuterium),
                        timer = planet.timer)             
    PlanetFactory_planets.write(planet_id, new_planet)
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end

func PlanetFactory_upgrade_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    alloc_locals
    let (address) = get_caller_address()
    let (planet_id) = PlanetFactory_planet_to_owner.read(address)
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let current_mine_level = planet.mines.deuterium
    let (metal_required, crystal_required) = formulas_deuterium_building(deuterium_mine_level=current_mine_level)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    assert_le(metal_required, metal_available)
    assert_le(crystal_required, crystal_available)
    let new_planet = Planet(
                        MineLevels(metal=planet.mines.metal,
                                    crystal=planet.mines.crystal,
                                    deuterium=planet.mines.deuterium + 1),
                        MineStorage(metal=metal_available - metal_required,
                                    crystal=crystal_available - crystal_required,
                                    deuterium = planet.storage.deuterium),
                        timer = planet.timer)             
    PlanetFactory_planets.write(planet_id, new_planet)
    structure_updated.emit(metal_required, crystal_required, 0)
    return()
end

# Updates the ERC20 resources contract
func _update_resources_erc20{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(to : felt, metal_amount : felt, crystal_amount : felt, deuterium_amount : felt):
    let (metal_address) = erc20_metal_address.read()
    let (crystal_address) = erc20_crystal_address.read()
    let (deuterium_address) = erc20_deuterium_address.read()
    let metal = Uint256(metal_amount, 0)
    let crystal = Uint256(crystal_amount, 0)
    let deuterium = Uint256(deuterium_amount, 0)
    IERC20.transfer(metal_address, to, metal)
    IERC20.transfer(crystal_address, to, crystal)
    IERC20.transfer(deuterium_address, to, deuterium)
    return()
end

    
