%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256
from contracts.StructuresManager import (
    get_upgrades_cost,
    _generate_planet,
    _upgrade_crystal_mine,
    _upgrade_deuterium_mine,
    _upgrade_solar_plant,
    _start_metal_upgrade,
    _end_metal_upgrade,
    _get_planet,
)
from contracts.ResourcesManager import (
    _collect_resources,
)
from contracts.utils.library import (
    Planet, 
    Cost,
    _number_of_planets, 
    _planets,
    _planet_to_owner,
    erc721_token_address,
    erc20_metal_address,
    erc20_crystal_address,
    erc20_deuterium_address,
)
from contracts.utils.Formulas import (
    formulas_metal_building, 
    formulas_crystal_building,
    formulas_deuterium_building
)
from contracts.utils.Ownable import (
    Ownable_initializer,
    Ownable_only_owner
)



###########
# Getters #
###########

@view
func number_of_planets{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (n_planets : felt):
    let (n) = _number_of_planets.read()
    return(n_planets=n)
end

@view
func get_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (planet : Planet):
    let (address) = get_caller_address()
    let (planet_id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(planet_id)
    return(planet=planet)
end

@view
func get_my_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (planet_id : Uint256):
    let (address) = get_caller_address()
    let (id) = _planet_to_owner.read(address)
    return(planet_id=id)
end

@view
func erc721_address{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (res : felt):
    let (res) = erc721_token_address.read()
    return(res)
end

@view
func get_structures_levels{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (metal_mine : felt, crystal_mine : felt, deuterium_mine : felt, solar_plant : felt):
    let (address) = get_caller_address()
    let (id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(id)
    let metal = planet.mines.metal 
    let crystal = planet.mines.crystal 
    let deuterium = planet.mines.deuterium
    let solar_plant = planet.energy.solar_plant
    return(metal_mine=metal, crystal_mine=crystal, deuterium_mine=deuterium, solar_plant=solar_plant)
end

@view
func resources_available{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (metal : felt, crystal : felt, deuterium : felt):
    let (address) = get_caller_address()
    let (id) = _planet_to_owner.read(address)
    let (planet) = _planets.read(id)
    let metal_available = planet.storage.metal
    let crystal_available = planet.storage.crystal
    let deuterium_available = planet.storage.deuterium
    return(metal=metal_available, crystal=crystal_available, deuterium=deuterium_available)
end

@view
func get_structures_upgrade_cost{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }() -> (metal_mine : Cost, crystal_mine : Cost, deuterium_mine : Cost, solar_plant : Cost):
    let (metal, crystal, deuterium, solar_plant) = get_upgrades_cost()
    return(metal, crystal, deuterium, solar_plant)
end

###############
# Constructor #
###############

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }(erc721_address : felt, owner : felt):
    erc721_token_address.write(erc721_address)
    Ownable_initializer(owner)
    return()
end

#############
# Externals #
#############

@external
func erc20_addresses{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }(metal_token : felt, crystal_token : felt, deuterium_token : felt):
    Ownable_only_owner()
    erc20_metal_address.write(metal_token)
    erc20_crystal_address.write(crystal_token)
    erc20_deuterium_address.write(deuterium_token)
    return()
end

@external
func generate_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    _generate_planet()
    return()
end

@external
func collect_resources{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    let (address) = get_caller_address()
    assert_not_zero(address)
    let (id) = _planet_to_owner.read(address)
    _collect_resources(address)
    return()
end

@external
func metal_upgrade_start{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }():
    _start_metal_upgrade()
    return()
end

@external
func metal_upgrade_complete{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }():
    _end_metal_upgrade()
    return()
end

@external
func upgrade_crystal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }():
    _upgrade_crystal_mine()
    return()
end

@external
func upgrade_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    _upgrade_deuterium_mine()
    return()
end

@external
func upgrade_solar_plant{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }():
    _upgrade_solar_plant()
    return()
end