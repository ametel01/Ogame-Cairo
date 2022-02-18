%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp
from contracts.utils.Math64x61 import Math64x61_pow, Math64x61_mul


const Math64x61_FRACT_PART = 2 ** 61
const Math64x61_ONE = 1 * Math64x61_FRACT_PART

##############
# Production #
##############

# Prod per second = (5 x Level x 11^Level)
func formulas_metal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (metal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let (first_part) = Math64x61_mul(6, mine_level)
    # let (second_part) = Math64x61_pow(11,mine_level)
    # let (prod_per_second) = Math64x61_mul(first_part, second_part)
    # let (amount_produced) = Math64x61_mul(prod_per_second,time_elapsed)
    return(metal_produced=6)
end 

func formulas_crystal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (metal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let (first_part) = Math64x61_mul(4, mine_level)
    let (second_part) = Math64x61_pow(11,mine_level)
    let (prod_per_second) = Math64x61_mul(first_part, second_part)
    let (amount_produced) = Math64x61_mul(prod_per_second,time_elapsed)
    return(metal_produced=amount_produced)
end 

func formulas_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (metal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let (first_part) = Math64x61_mul(2, mine_level)
    let (second_part) = Math64x61_pow(11,mine_level)
    let (prod_per_second) = Math64x61_mul(first_part, second_part)
    let (amount_produced) = Math64x61_mul(prod_per_second,time_elapsed)
    return(metal_produced=amount_produced)
end 