%lang starknet

from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    get_block_timestamp,
    get_contract_address,
    get_caller_address,
)
from contracts.Ogame.structs import Planet, BuildingQue
from contracts.Ogame.storage import _planet_to_owner, _planets

##########################################################################################
#                                       Storage                                          #
##########################################################################################

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

@storage_var
func _research_lab_address() -> (address : felt):
end

@storage_var
func _research_lab_level(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _shipyard_address() -> (address : felt):
end

@storage_var
func _shipyard_level(planet_id : Uint256) -> (level : felt):
end

# @dev Stores the timestamp of the end of the timelock for buildings upgrades.
# @params The address of the player.
@storage_var
func buildings_timelock(address : felt) -> (cued_details : BuildingQue):
end

# @dev Stores the que status for a specific building. IDs:
# 1-metal mine, 2-crystal-mine, 3-deuterium mine, 4-solar plant, 5-robot factory, 6-research lab
@storage_var
func building_qued(address : felt, id : felt) -> (is_qued : felt):
end

@storage_var
func resources_timer(planet_id : Uint256) -> (timestamp : felt):
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
