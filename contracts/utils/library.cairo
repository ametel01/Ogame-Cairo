%lang starknet

from starkware.cairo.common.uint256 import Uint256


##########################################################################################
#                                               Structs                                  #
##########################################################################################

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

struct Cost:
    member metal : felt
    member crystal : felt
    member deuterium : felt
end

##########################################################################################
#                                               Storage                                  #
##########################################################################################

@storage_var
func _number_of_planets() -> (n : felt):
end

@storage_var
func _planets(planet_id : Uint256) -> (planet : Planet):
end

@storage_var
func _planet_to_owner(address : felt) -> (planet_id : Uint256):
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

##########################################################################################
#                                               Events                                   #
##########################################################################################

@event
func planet_genereted(planet_id : Uint256):
end

@event
func structure_updated(metal_used : felt, crystal_used : felt, deuterium_used : felt):
end

##########################################################################################
#                                               Constants                                #
##########################################################################################

const TRUE = 1
const FALSE = 0