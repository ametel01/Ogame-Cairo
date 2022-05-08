%lang starknet

from starkware.cairo.common.uint256 import Uint256

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
