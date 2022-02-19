%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.math import unsigned_div_rem
from contracts.utils.Math64x61 import Math64x61_pow, Math64x61_div


const Math64x61_FRACT_PART = 2 ** 61
const Math64x61_ONE = 1 * Math64x61_FRACT_PART

##############
# Production #
##############

# Prod per second = (6 x Level x 11^Level)
func formulas_metal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (metal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let first_part = 6 * mine_level#Math64x61_mul(6, mine_level)
    let (second_part) = Math64x61_pow(11,mine_level)
    let prod_per_second = first_part * second_part#Math64x61_mul(first_part, second_part)
    let amount_produced = prod_per_second * time_elapsed #Math64x61_mul(prod_per_second,time_elapsed)
    let (prod_scaled,_) = unsigned_div_rem(amount_produced, 10000)
    return(metal_produced=prod_scaled)
end 

func formulas_crystal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (metal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let first_part = 4 * mine_level#Math64x61_mul(6, mine_level)
    let (second_part) = Math64x61_pow(11,mine_level)
    let prod_per_second = first_part * second_part#Math64x61_mul(first_part, second_part)
    let amount_produced = prod_per_second * time_elapsed #Math64x61_mul(prod_per_second,time_elapsed)
    let (prod_scaled,_) = unsigned_div_rem(amount_produced, 10000)
    return(metal_produced=prod_scaled)
end 

func formulas_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (metal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let first_part = 2 * mine_level#Math64x61_mul(6, mine_level)
    let (second_part) = Math64x61_pow(11,mine_level)
    let prod_per_second = first_part * second_part#Math64x61_mul(first_part, second_part)
    let amount_produced = prod_per_second * time_elapsed #Math64x61_mul(prod_per_second,time_elapsed)
    let (prod_scaled,_) = unsigned_div_rem(amount_produced, 10000)
    return(metal_produced=prod_scaled)
end 