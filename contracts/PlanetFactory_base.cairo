%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

###########
# Structs #
###########

struct Planet:
    member metal_mine : felt
    member metal_timer : felt
    member crystal_mine : felt
    member crystal_timer : felt
    member deuterium_mine : felt
    member deuterium_timer : felt
end

###########
# Storage #
###########

@storage_var
func PlanetFactory_number_of_planets() -> (n : felt):
end

@storage_var
func PlanetFactory_planets(id : felt) -> (planet : Planet):
end

@storage_var
func PlanetFactory_planet_to_owner(address : felt) -> (planet_id : felt):
end


##########
# Events #
##########

@event
func planet_genereted(id : felt):
end

######################
# Internal functions #
######################

