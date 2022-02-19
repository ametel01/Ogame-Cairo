%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from contracts.utils.Formulas import formulas_metal_mine, formulas_crystal_mine, formulas_deuterium_mine

###########
# Structs #
###########

struct Planet:
    # Mines level
    member metal_mine : felt
    member crystal_mine : felt
    member deuterium_mine : felt
    # Mines storage
    member metal_storage : felt
    member crystal_storage : felt
    member deuterium_storage : felt
    # Mines timer
    member timer : felt
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

func PlanetFactory_collect_resources{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(planet_id : felt) -> ():
    alloc_locals
    let (local planet) = PlanetFactory_planets.read(planet_id)
    let time_start = planet.timer
    let metal_level = planet.metal_mine
    let crystal_level = planet.crystal_mine
    let deuterium_level = planet.deuterium_mine
    let (metal_produced) = formulas_metal_mine(time_start, metal_level)
    let (crystal_produced) = formulas_crystal_mine(time_start, crystal_level)
    let (deuterium_produced) = formulas_deuterium_mine(time_start, deuterium_level)
    let updated_planet = Planet(
                                metal_mine=1,
                                crystal_mine=1,
                                deuterium_mine=1,
                                metal_storage=metal_produced,
                                crystal_storage=crystal_produced,
                                deuterium_storage=deuterium_produced,
                                timer=time_start
                            )
    PlanetFactory_planets.write(planet_id, updated_planet)
    return()
end

# func PlanetFactory_calculate_crystal{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*, 
#         range_check_ptr
#         }(planet_id : felt) -> ():
#     alloc_locals
#     let (address) = get_caller_address()
#     let (planet_id) = PlanetFactory_planet_to_owner.read(address)
#     let (local planet) = PlanetFactory_planets.read(planet_id)
#     let time_start = planet.timer
#     let mine_level = planet.metal_mine
#     let (production) = formulas_crystal_mine(time_start, mine_level)
#     planet.crystal_storage = production
#     return()
# end

# func PlanetFactory_calculate_deuterium{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*, 
#         range_check_ptr
#         }(planet_id : felt) -> ():
#     alloc_locals
#     let (address) = get_caller_address()
#     let (planet_id) = PlanetFactory_planet_to_owner.read(address)
#     let (local planet) = PlanetFactory_planets.read(planet_id)
#     let time_start = planet.timer
#     let mine_level = planet.metal_mine
#     let (production) = formulas_crystal_mine(time_start, mine_level)
#     planet.crystal_storage = production
#     return()
# end
    
