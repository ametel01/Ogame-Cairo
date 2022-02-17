%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.keccak import unsafe_keccak
from starkware.cairo.common.math import unsigned_div_rem

const MAXPLANETIDDIGITS = 16
const IDMOD = 10**16

struct Planet:
    member planet_name : felt
    member metal_mine : felt
    member crystal_mine : felt
    member deuterium_mine : felt
end

@storage_var
func number_of_planets() -> (n : felt):
end

@storage_var
func planets(id : felt) -> (planet : Planet):
end

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }():
    return()
end

@external
func generate_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }(planet_name : felt) -> (new_planet : Planet):
    let planet = Planet(planet_name=planet_name, metal_mine=1, crystal_mine=1, deuterium_mine=1)
    let (id) = number_of_planets.read()
    planets.write(id + 1, planet)
    return(new_planet=planet)
end
