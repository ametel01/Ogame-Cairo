%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp
from contracts.utils.Math64x61 import Math64x61_pow


const Math64x61_FRACT_PART = 2 ** 61
const Math64x61_ONE = 1 * Math64x61_FRACT_PART

##############
# Production #
##############

func formulas_metal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (metal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let first_part = 5 * mine_level
    let second_part = first_part * 11
    let (prod_per_second) = Math64x61_pow(second_part, mine_level)
    let amount_produced = prod_per_second * time_elapsed
    return(metal_produced=amount_produced)
end 

