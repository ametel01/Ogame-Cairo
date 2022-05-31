%lang starknet

from starkware.cairo.common.uint256 import Uint256
from contracts.Ogame.structs import BuildingQue
##################################################################################
#                              TOKENS ADDRESSES                              #
##################################################################################
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

##################################################################################
#                              COMPONENTS ADDRESSES                              #
##################################################################################

@storage_var
func resources_address() -> (address : felt):
end

@storage_var
func facilities_address() -> (address : felt):
end

@storage_var
func shipyard_address() -> (address : felt):
end

@storage_var
func research_lab_address() -> (address : felt):
end

##################################################################################
#                              LOCKS AND QUES                                    #
##################################################################################

@storage_var
func _resources_timer(planet_id : Uint256) -> (last_collection_timestamp : felt):
end

@storage_var
func building_qued(caller : felt, building_id : felt) -> (is_qued : felt):
end

##################################################################################
#                             FACILITIES STORAGE                                 #
##################################################################################

@storage_var
func shipyard_level() -> (level : felt):
end

# TODO: this need to be changed
@storage_var
func robot_factory_level(planete_id : Uint256) -> (level : felt):
end

@storage_var
func research_lab_level(planete_id : Uint256) -> (level : felt):
end

@storage_var
func nanite_factory_level(planete_id : Uint256) -> (level : felt):
end

@storage_var
func buildings_timelock(address : felt) -> (cued_details : BuildingQue):
end

##################################################################################
#                              RESEARCH STORAGE                                  #
##################################################################################

@storage_var
func _energy_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _computer_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _laser_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _armour_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _ion_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _espionage_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _plasma_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _weapons_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _shielding_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _hyperspace_tech(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _astrophysics(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _combustion_drive(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _hyperspace_drive(planet_id : Uint256) -> (level : felt):
end

@storage_var
func _impulse_drive(planet_id : Uint256) -> (level : felt):
end

##################################################################################
#                             SHIPYARD STORAGE                                   #
##################################################################################

@storage_var
func _ships_cargo(planet_id : Uint256) -> (amount : felt):
end

@storage_var
func _ships_recycler(planet_id : Uint256) -> (amount : felt):
end

@storage_var
func _ships_espionage_probe(planet_id : Uint256) -> (amount : felt):
end

@storage_var
func _ships_solar_satellite(planet_id : Uint256) -> (amount : felt):
end

@storage_var
func _ships_light_fighter(planet_id : Uint256) -> (amount : felt):
end

@storage_var
func _ships_cruiser(planet_id : Uint256) -> (amount : felt):
end

@storage_var
func _ships_battleship(planet_id : Uint256) -> (amount : felt):
end

@storage_var
func _ships_deathstar(planet_id : Uint256) -> (amount : felt):
end
