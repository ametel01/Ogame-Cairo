%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.keccak import unsafe_keccak
from starkware.cairo.common.math import unsigned_div_rem

const MAXPLANETIDDIGITS = 16
const IDMOD = 10**16

struct Planet:
    member planet_id : felt
    member metal_mine : felt
    member crystal_mine : felt
    member deuterium_mine : felt
end

@storage_var
func planets(id : felt) -> (planet : Planet):
end

@external
func generate_planet{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
        }(planet_name_len : felt, planet_name : felt*) -> (new_planet : Planet):
    let (id_low, id_high) = unsafe_keccak(planet_name, planet_name_len)
    let (_, id) = unsigned_div_rem(id_low, IDMOD)
    let planet = Planet(planet_id=id, metal_mine=1, crystal_mine=1, deuterium_mine=1)
    return(new_planet=planet)
end
