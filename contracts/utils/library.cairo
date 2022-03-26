%lang starknet

from starkware.cairo.common.uint256 import Uint256


##########################################################################################
#                                               Structs                                  #
##########################################################################################

# @dev Stores the levels of the mines.
struct MineLevels:
    member metal : felt
    member crystal : felt
    member deuterium : felt
end

# @dev Stores the amount of resources available for each resource.
struct MineStorage:
    member metal : felt
    member crystal : felt
    member deuterium : felt
end

# @dev Stores the energy available.
struct Energy:
    member solar_plant : felt
    #member satellites : felt
end

# @dev Stores the level of the facilities.
struct Facilities:
    member robot_factory : felt
end

# @dev The main planet struct.
struct Planet:
    member mines : MineLevels
    member storage : MineStorage
    member energy : Energy
    member timer : felt
end

# @dev Used to handle costs.
struct Cost:
    member metal : felt
    member crystal : felt
    member deuterium : felt
end

##########################################################################################
#                                               Storage                                  #
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

# @dev Mapping between player address and planet ID.
# @params The player address
@storage_var
func _planet_to_owner(address : felt) -> (planet_id : Uint256):
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
func buildings_timelock(address : felt) -> (time_unlocked : felt):
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