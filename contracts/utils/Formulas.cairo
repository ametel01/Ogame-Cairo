%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero
from starkware.cairo.common.pow import pow
from contracts.utils.constants import TRUE, FALSE

##############
# Production #
##############

# Prod per second = 30 * Level * 11**Level / 10**Level * 10000 / 3600 * 10000
func formulas_metal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (metal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let (metal_hour) = _resources_production_formula(30, mine_level)
    let (prod_second, _) = unsigned_div_rem(metal_hour, 3600) #91
    let fact8 = prod_second * time_elapsed  
    let (prod_scaled,_) = unsigned_div_rem(fact8, 10000)#32
    return(metal_produced=prod_scaled)
end 

func formulas_crystal_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (crystal_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let (crystal_hour) = _resources_production_formula(20, mine_level)
    let (fact7, _) = unsigned_div_rem(crystal_hour, 3600)
    let fact8 = fact7 * time_elapsed  
    let (prod_scaled,_) = unsigned_div_rem(fact8, 10000)
    return(crystal_produced=prod_scaled)
end 

func formulas_deuterium_mine{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(last_timestamp : felt, mine_level : felt) -> (deuterium_produced : felt):
    alloc_locals
    let (time_now) = get_block_timestamp()
    local time_elapsed = time_now - last_timestamp
    let (deuterium_hour) = _resources_production_formula(10, mine_level)
    let (fact7, _) = unsigned_div_rem(deuterium_hour, 3600)
    let fact8 = fact7 * time_elapsed  
    let (prod_scaled,_) = unsigned_div_rem(fact8, 10000)
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
        let (second_fact) = pow(15, exponent)
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
        let (second_fact) = pow(16, exponent)
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
        let (second_fact) = pow(15, exponent)
        let metal_cost = base_metal * second_fact
        let crystal_cost = base_crystal * second_fact
        let (metal_scaled,_) = unsigned_div_rem(metal_cost, 10)
        let (crystal_scaled,_) = unsigned_div_rem(crystal_cost, 10)
        return(metal_cost=metal_scaled, crystal_cost=crystal_scaled)
    end
end

func formulas_solar_plant_building{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(solar_plant_level : felt) -> (metal_cost : felt, crystal_cost : felt):
    alloc_locals
    let base_metal = 75
    let base_crystal =30
    let exponent = solar_plant_level
    if exponent == 1:
        return(metal_cost=base_metal, crystal_cost=base_crystal)
    else: 
        let (fact0) = pow(15, exponent)
        local factM = base_metal * fact0
        local factC = base_crystal * fact0
        let (fact1) = pow(10, exponent)
        let (metal_scaled,_) = unsigned_div_rem(factM, fact1)
        let (crystal_scaled,_) = unsigned_div_rem(factC, fact1)
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
    let (production) = _solar_production_formula(plant_level)
    return(production=production)
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
    let (metal) = _production_limiter(production=net_metal, 
                                energy_required=energy_required, 
                                energy_available=energy_available)
    let (crystal) = _production_limiter(production=net_crystal, 
                                energy_required=energy_required, 
                                energy_available=energy_available)
    let (deuterium) = _production_limiter(production=net_deuterium, 
                                energy_required=energy_required, 
                                energy_available=energy_available)
    return(actual_metal=metal, actual_crystal=crystal, actual_deuterium=deuterium)
end

func _consumption{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(mine_level : felt) -> (consumption : felt):
    alloc_locals
    let fact1 = 10 * mine_level
    let (fact2) = pow(11, mine_level)
    let fact3 = fact1 * fact2
    let (fact4) = pow(10, mine_level)
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
    let (fact2) = pow(11, mine_level)
    let fact3 = fact1 * fact2
    let (fact4) = pow(10, mine_level)
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
    let fact0 = energy_available * 100
    let (fact1,_) = unsigned_div_rem(fact0, energy_required)
    let fact2 = fact1 * production
    let (res,_) = unsigned_div_rem(fact2, 100)
    return(production=res)
end

func _resources_production_formula{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(mine_factor : felt, mine_level : felt) -> (production_hour):
    alloc_locals
    let fact1 = mine_factor * mine_level
    let (fact2) = pow(11,mine_level)
    local fact3 = fact1 * fact2
    let (fact4) = pow(10, mine_level)
    let (fact5, _) = unsigned_div_rem(fact3, fact4)
    let fact6 = fact5 * 10000
    return(production_hour=fact6)
end

func _solar_production_formula{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
        }(plant_level : felt) -> (production_hour):
    alloc_locals
    let fact1 = 20 * plant_level
    let (local fact2) = pow(11, plant_level)
    local fact3 = fact1 * fact2
    let (fact4) = pow(10, plant_level)
    let (fact5, _) = unsigned_div_rem(fact3, fact4)
    return(production_hour=fact5)
end