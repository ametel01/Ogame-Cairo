%lang starknet

from starkware.cairo.common.uint256 import Uint256

##################################################################################
#                              RESOURCES STORAGE                                 #
##################################################################################

@storage_var
func _resources_timer(planet_id : Uint256) -> (last_collection_timestamp : felt):
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
