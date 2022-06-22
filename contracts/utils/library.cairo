%lang starknet

from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_block_timestamp,
    get_contract_address,
    get_caller_address,
)
from contracts.token.erc721.interfaces.IERC721 import IERC721
##########################################################################################
#                                               Structs                                  #
##########################################################################################

# @dev Stores the levels of the mines.
struct MineLevels:
    member metal : felt
    member crystal : felt
    member deuterium : felt
end

# @dev Stores the energy available.
struct Energy:
    member solar_plant : felt
    # member satellites : felt
end

# @dev Stores the level of the facilities.
struct Facilities:
    member robot_factory : felt
end

# @dev The main planet struct.
struct Planet:
    member mines : MineLevels
    member energy : Energy
    member facilities : Facilities
end

# @dev Used to handle costs.
struct Cost:
    member metal : felt
    member crystal : felt
    member deuterium : felt
end

# @dev Used to represent the civil ships.
struct CivilShips:
    member cargo : felt
    member recycler : felt
    member espyonage_probe : felt
    member solar_satellite : felt
end

# @dev Used to represent the combat ships.
struct CombatShips:
    member light_fighter : felt
    member heavy_fighter : felt
    member cruiser : felt
    member battle_ship : felt
    member death_star : felt
end

# @dev Temporary struct to represent a fleet.
struct Fleet:
    member civil : CivilShips
    member combat : CombatShips
end

# @dev Stores the building on cue details
struct BuildingQue:
    member id : felt
    member lock_end : felt
end

##########################################################################################
#                                       Storage                                          #
##########################################################################################

# @dev Returns the total number of planets present in the universe.
@storage_var
func _number_of_planets() -> (n : felt):
end

# @dev Returns the planet struct of a given planet.
# @params The planet ID which is = to the NFT ID.
@storage_var
func _planets(planet_id : Uint256) -> (planet : Planet):
end

@storage_var
func _players_spent_resources(address : felt) -> (spent_resources : felt):
end

# @dev Returns the address of the game's ERC721 contract.
@storage_var
func erc721_token_address() -> (address : felt):
end

# @dev Returns the address of the owner of the ERC721 contract.
@storage_var
func erc721_owner_address() -> (address : felt):
end

# @dev Returns the address of the ERC20 metal address.
@storage_var
func erc20_metal_address() -> (address : felt):
end

# @dev Returns the address of the ERC20 crystal address.
@storage_var
func erc20_crystal_address() -> (address : felt):
end

# @dev Returns the address of the ERC20 deuterium address.
@storage_var
func erc20_deuterium_address() -> (address : felt):
end

# @dev Stores the timestamp of the end of the timelock for buildings upgrades.
# @params The address of the player.
@storage_var
func buildings_timelock(address : felt) -> (cued_details : BuildingQue):
end

# @dev Stores the que status for a specific building. IDs:
# 1-metal mine, 2-crystal-mine, 3-deuterium mine, 4-solar plant, 5-robot factory
@storage_var
func building_qued(address : felt, id : felt) -> (is_qued : felt):
end

@storage_var
func _resources_timer(planet_id : Uint256) -> (timestamp : felt):
end

##########################################################################################
#                                               Events                                   #
##########################################################################################

# @dev Emits the planet_id when a player get assigned an nft.
@event
func planet_genereted(planet_id : Uint256):
end

# @dev Emits the resources used when a structure is updated.
@event
func structure_updated(metal_used : felt, crystal_used : felt, deuterium_used : felt):
end

##########################################################################################
#                                               Constants                                #
##########################################################################################

const TRUE = 1
const FALSE = 0

##########################################################################################
#                                               Functions                                #
##########################################################################################

func _get_planet{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    planet : Planet
):
    let (address) = get_caller_address()
    let (erc721_address) = erc721_token_address.read()
    let (planet_id) = IERC721.ownerToPlanet(erc721_address, address)
    let (res) = _planets.read(planet_id)
    return (planet=res)
end

func reset_timelock{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
):
    buildings_timelock.write(address, BuildingQue(0, 0))
    return ()
end

func reset_building_que{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, id : felt
):
    building_qued.write(address, id, FALSE)
    return ()
end
