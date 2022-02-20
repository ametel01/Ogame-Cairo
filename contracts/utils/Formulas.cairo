%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero
from contracts.utils.Math64x61 import Math64x61_pow, Math64x61_div
from contracts.utils.constants import TRUE, FALSE


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

#############
# Buildings #
#############

func formulas_metal_building{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(metal_mine_level : felt) -> (metal_cost : felt, crystal_cost : felt):
    let base_metal = 60
    let base_crystal = 15
    let exponent = metal_mine_level - 1
    if exponent == 0:
        return(metal_cost=base_metal, crystal_cost=base_crystal)
    else: 
        let (second_fact) = Math64x61_pow(15, exponent)
        let metal_cost = base_metal * second_fact
        let crystal_cost = base_crystal * second_fact
        let (metal_scaled,_) = unsigned_div_rem(metal_cost, 10)
        let (crystal_scaled,_) = unsigned_div_rem(crystal_cost, 10)
        return(metal_cost=metal_scaled, crystal_cost=crystal_scaled)
    end
end

func formulas_crystal_building{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(crystal_mine_level : felt) -> (metal_cost : felt, crystal_cost : felt):
    let base_metal = 48
    let base_crystal = 24
    let exponent = crystal_mine_level - 1
    if exponent == 0:
        return(metal_cost=base_metal, crystal_cost=base_crystal)
    else: 
        let (second_fact) = Math64x61_pow(16, exponent)
        let metal_cost = base_metal * second_fact
        let crystal_cost = base_crystal * second_fact
        let (metal_scaled,_) = unsigned_div_rem(metal_cost, 10)
        let (crystal_scaled,_) = unsigned_div_rem(crystal_cost, 10)
        return(metal_cost=metal_scaled, crystal_cost=crystal_scaled)
    end
end

func formulas_deuterium_building{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(deuterium_mine_level : felt) -> (metal_cost : felt, crystal_cost : felt):
    let base_metal = 225
    let base_crystal = 75
    let exponent = deuterium_mine_level - 1
    if exponent == 0:
        return(metal_cost=base_metal, crystal_cost=base_crystal)
    else: 
        let (second_fact) = Math64x61_pow(15, exponent)
        let metal_cost = base_metal * second_fact
        let crystal_cost = base_crystal * second_fact
        let (metal_scaled,_) = unsigned_div_rem(metal_cost, 10)
        let (crystal_scaled,_) = unsigned_div_rem(crystal_cost, 10)
        return(metal_cost=metal_scaled, crystal_cost=crystal_scaled)
    end
end