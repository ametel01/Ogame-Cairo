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
    let time_elapsed = time_now - last_timestamp
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
        }(last_timestamp : felt, mine_level : felt) -> (crystal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    let time_elapsed = time_now - last_timestamp
    let first_part = 4 * mine_level#Math64x61_mul(6, mine_level)
    let (second_part) = Math64x61_pow(11,mine_level)
    let prod_per_second = first_part * second_part#Math64x61_mul(first_part, second_part)
    let amount_produced = prod_per_second * time_elapsed #Math64x61_mul(prod_per_second,time_elapsed)
    let (prod_scaled,_) = unsigned_div_rem(amount_produced, 10000)
    return(crystal_produced=prod_scaled)
end 

func formulas_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (deuterium_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    let  time_elapsed = time_now - last_timestamp
    let first_part = 2 * mine_level#Math64x61_mul(6, mine_level)
    let (second_part) = Math64x61_pow(11,mine_level)
    let prod_per_second = first_part * second_part#Math64x61_mul(first_part, second_part)
    let amount_produced = prod_per_second * time_elapsed #Math64x61_mul(prod_per_second,time_elapsed)
    let (prod_scaled,_) = unsigned_div_rem(amount_produced, 10000)
    return(deuterium_produced=prod_scaled)
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

##########
# Energy #
##########
func formulas_solar_plant{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(plant_level : felt) -> (production : felt):
    let first_part = 4 * plant_level#Math64x61_mul(6, mine_level)
    let (second_part) = Math64x61_pow(11,plant_level)
    let production = first_part * second_part#Math64x61_mul(first_part, second_part)
    let (prod_scaled,_) = unsigned_div_rem(production, 1000)
    return(production=prod_scaled)
end

func formulas_production_scaler{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(
        net_metal : felt,
        net_crystal : felt,
        net_deuterium : felt,
        energy_required : felt,
        energy_available : felt
        ) -> (actual_metal : felt, actual_crystal : felt, actual_deuterium : felt):
    alloc_locals
    let (metal) = _production_limiter(net_metal, energy_required, energy_available)
    let (crystal) = _production_limiter(net_crystal, energy_required, energy_available)
    let (deuterium) = _production_limiter(net_deuterium, energy_required, energy_available)
    return(actual_metal=metal, actual_crystal=crystal, actual_deuterium=deuterium)
end

func _consumption{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(mine_level : felt) -> (consumption : felt):
    alloc_locals
    let fact1 = 10 * mine_level
    let (fact2) = Math64x61_pow(11, mine_level)
    let fact3 = fact1 * fact2
    let (fact4) = Math64x61_pow(10, mine_level)
    let (res, _) = unsigned_div_rem(fact3, fact4)
    return(consumption=res)
end

func _consumption_deuterium{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(mine_level : felt) -> (consumption : felt):
    alloc_locals
    let fact1 = 20 * mine_level
    let (fact2) = Math64x61_pow(11, mine_level)
    let fact3 = fact1 * fact2
    let (fact4) = Math64x61_pow(10, mine_level)
    let (res, _) = unsigned_div_rem(fact3, fact4)
    return(consumption=res)
end

func _production_limiter{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(
        production : felt, 
        energy_required : felt, 
        energy_available : felt) -> (production : felt):
    let (fact1,_) = unsigned_div_rem(energy_available, energy_required)
    let fact2 = fact1 * 100
    let fact3 = fact2 * production
    let (res,_) = unsigned_div_rem(fact3, 100)
    return(production=res)
end
    
