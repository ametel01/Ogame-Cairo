%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.pow import pow
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.utils.library import _players_spent_resources

##############
# Production #
##############

const E18 = 10 ** 18

namespace Formulas:
    # Prod per second = 30 * Level * 11**Level / 10**Level * 10000 / 3600 * 10000
    func metal_mine_production{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        last_timestamp : felt, mine_level : felt
    ) -> (metal_produced : felt):
        alloc_locals
        let (time_now) = get_block_timestamp()
        local time_elapsed = time_now - last_timestamp
        let (metal_hour) = _resources_production_formula(30, mine_level)
        let (prod_second, _) = unsigned_div_rem(metal_hour * 10000, 3600)  # 91
        let fact8 = prod_second * time_elapsed
        let (prod_scaled, _) = unsigned_div_rem(fact8, 1000)  # 32
        return (metal_produced=prod_scaled)
    end

    func crystal_mine_production{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        last_timestamp : felt, mine_level : felt
    ) -> (crystal_produced : felt):
        alloc_locals
        let (time_now) = get_block_timestamp()
        local time_elapsed = time_now - last_timestamp
        let (crystal_hour) = _resources_production_formula(20, mine_level)
        let (fact7, _) = unsigned_div_rem(crystal_hour * 10000, 3600)
        let fact8 = fact7 * time_elapsed
        let (prod_scaled, _) = unsigned_div_rem(fact8, 1000)
        return (crystal_produced=prod_scaled)
    end

    func deuterium_mine_production{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(last_timestamp : felt, mine_level : felt) -> (deuterium_produced : felt):
        alloc_locals
        let (time_now) = get_block_timestamp()
        local time_elapsed = time_now - last_timestamp
        let (deuterium_hour) = _resources_production_formula(10, mine_level)
        let (fact7, _) = unsigned_div_rem(deuterium_hour * 10000, 3600)
        let fact8 = fact7 * time_elapsed
        let (prod_scaled, _) = unsigned_div_rem(fact8, 1000)
        return (deuterium_produced=prod_scaled)
    end

    #############
    # Buildings #
    #############

    func metal_building_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        metal_mine_level : felt
    ) -> (metal_cost : felt, crystal_cost : felt):
        alloc_locals
        let base_metal = 60
        let base_crystal = 15
        let exponent = metal_mine_level
        if exponent == 0:
            return (metal_cost=base_metal, crystal_cost=base_crystal)
        else:
            let (second_fact) = pow(15, exponent)
            local metal_cost = base_metal * second_fact
            local crystal_cost = base_crystal * second_fact
            let (local exp2) = pow(10, metal_mine_level)
            let (metal_scaled, _) = unsigned_div_rem(metal_cost, exp2)
            let (crystal_scaled, _) = unsigned_div_rem(crystal_cost, exp2)
            return (metal_cost=metal_scaled, crystal_cost=crystal_scaled)
        end
    end

    func crystal_building_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        crystal_mine_level : felt
    ) -> (metal_cost : felt, crystal_cost : felt):
        alloc_locals
        let base_metal = 48
        let base_crystal = 24
        let exponent = crystal_mine_level
        if exponent == 0:
            return (metal_cost=base_metal, crystal_cost=base_crystal)
        else:
            let (second_fact) = pow(16, exponent)
            local metal_cost = base_metal * second_fact
            local crystal_cost = base_crystal * second_fact
            let (local exp2) = pow(10, crystal_mine_level)
            let (metal_scaled, _) = unsigned_div_rem(metal_cost, exp2)
            let (crystal_scaled, _) = unsigned_div_rem(crystal_cost, exp2)
            return (metal_cost=metal_scaled, crystal_cost=crystal_scaled)
        end
    end

    func deuterium_building_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        deuterium_mine_level : felt
    ) -> (metal_cost : felt, crystal_cost : felt):
        alloc_locals
        let base_metal = 225
        let base_crystal = 75
        let exponent = deuterium_mine_level
        if exponent == 0:
            return (metal_cost=base_metal, crystal_cost=base_crystal)
        else:
            let (second_fact) = pow(15, exponent)
            local metal_cost = base_metal * second_fact
            local crystal_cost = base_crystal * second_fact
            let (local exp2) = pow(10, deuterium_mine_level)
            let (metal_scaled, _) = unsigned_div_rem(metal_cost, exp2)
            let (crystal_scaled, _) = unsigned_div_rem(crystal_cost, exp2)
            return (metal_cost=metal_scaled, crystal_cost=crystal_scaled)
        end
    end

    func solar_plant_building_cost{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(solar_plant_level : felt) -> (metal_cost : felt, crystal_cost : felt):
        alloc_locals
        let base_metal = 75
        let base_crystal = 30
        let exponent = solar_plant_level
        if exponent == 1:
            return (metal_cost=base_metal, crystal_cost=base_crystal)
        else:
            let (fact0) = pow(15, exponent)
            local factM = base_metal * fact0
            local factC = base_crystal * fact0
            let (fact1) = pow(10, exponent)
            let (metal_scaled, _) = unsigned_div_rem(factM, fact1)
            let (crystal_scaled, _) = unsigned_div_rem(factC, fact1)
            return (metal_cost=metal_scaled, crystal_cost=crystal_scaled)
        end
    end

    func robot_factory_building_cost{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(factory_level : felt) -> (metal_cost : felt, crystal_cost : felt, deuterium_cost : felt):
        let base_metal = 400
        let base_crystal = 120
        let base_deuterium = 200
        if factory_level == 0:
            return (base_metal, base_crystal, base_deuterium)
        else:
            let (fact0) = pow(2, factory_level)
            let metal = base_metal * fact0
            let crystal = base_crystal * fact0
            let deuterium = base_deuterium * fact0
            return (metal, crystal, deuterium)
        end
    end

    ##########
    # Energy #
    ##########
    func solar_plant_production{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        plant_level : felt
    ) -> (production : felt):
        let (production) = solar_production(plant_level)
        return (production=production)
    end

    func energy_production_scaler{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(
        net_metal : felt,
        net_crystal : felt,
        net_deuterium : felt,
        energy_required : felt,
        energy_available : felt,
    ) -> (actual_metal : felt, actual_crystal : felt, actual_deuterium : felt):
        alloc_locals
        let (enough_energy, _) = unsigned_div_rem(energy_available, energy_required)
        if enough_energy == FALSE:
            let (local metal) = _production_limiter(
                production=net_metal,
                energy_required=energy_required,
                energy_available=energy_available,
            )
            let (local crystal) = _production_limiter(
                production=net_crystal,
                energy_required=energy_required,
                energy_available=energy_available,
            )
            let (local deuterium) = _production_limiter(
                production=net_deuterium,
                energy_required=energy_required,
                energy_available=energy_available,
            )
            return (actual_metal=metal, actual_crystal=crystal, actual_deuterium=deuterium)
        else:
            return (net_metal, net_crystal, net_deuterium)
        end
    end

    func consumption_energy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        mine_level : felt
    ) -> (consumption : felt):
        alloc_locals
        let fact1 = 10 * mine_level
        let (fact2) = pow(11, mine_level)
        local fact3 = fact1 * fact2
        let (fact4) = pow(10, mine_level)
        let (level_in_bound) = is_le(mine_level, 25)
        if level_in_bound == TRUE:
            let (res, _) = unsigned_div_rem(fact3, fact4)
            return (res)
        else:
            let (fact5, _) = unsigned_div_rem(fact3, 1000)
            let (fact6, _) = unsigned_div_rem(fact4, 1000)
            let (res, _) = unsigned_div_rem(fact5, fact6)
            return (res)
        end
    end

    func consumption_energy_deuterium{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(mine_level : felt) -> (consumption : felt):
        alloc_locals
        let fact1 = 20 * mine_level
        let (fact2) = pow(11, mine_level)
        local fact3 = fact1 * fact2
        let (fact4) = pow(10, mine_level)
        let (level_in_bound) = is_le(mine_level, 25)
        if level_in_bound == TRUE:
            let (res, _) = unsigned_div_rem(fact3, fact4)
            return (res)
        else:
            let (fact5, _) = unsigned_div_rem(fact3, 1000)
            let (fact6, _) = unsigned_div_rem(fact4, 1000)
            let (res, _) = unsigned_div_rem(fact5, fact6)
            return (res)
        end
    end

    func _production_limiter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        production : felt, energy_required : felt, energy_available : felt
    ) -> (production : felt):
        let fact0 = energy_available * 100
        let (fact1, _) = unsigned_div_rem(fact0, energy_required)
        let fact2 = fact1 * production
        let (res, _) = unsigned_div_rem(fact2, 100)
        return (production=res)
    end

    # 30 * M * 1.1 ** M
    func _resources_production_formula{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(mine_factor : felt, mine_level : felt) -> (production_hour):
        alloc_locals
        let (local max_level) = is_le(25, mine_level)
        let fact1 = mine_factor * mine_level
        let (fact2) = pow(11, mine_level)
        local fact3 = fact1 * fact2
        if max_level == TRUE:
            let (local fact3a, _) = unsigned_div_rem(fact3, E18)
            let (fact4) = pow(10, mine_level)
            let (fact4a, _) = unsigned_div_rem(fact4, E18)
            let (fact5, _) = unsigned_div_rem(fact3a, fact4a)
            return (production_hour=fact5)
        else:
            let (fact4) = pow(10, mine_level)
            let (fact5, _) = unsigned_div_rem(fact3, fact4)
            return (production_hour=fact5)
        end
    end

    func solar_production{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        plant_level : felt
    ) -> (production_hour):
        alloc_locals
        let fact1 = 20 * plant_level
        let (local fact2) = pow(11, plant_level)
        local fact3 = fact1 * fact2
        let (fact4) = pow(10, plant_level)
        let (level_in_bound) = is_le(plant_level, 25)
        if level_in_bound == TRUE:
            let (res, _) = unsigned_div_rem(fact3, fact4)
            return (res)
        else:
            let (fact5, _) = unsigned_div_rem(fact3, 1000)
            let (fact6, _) = unsigned_div_rem(fact4, 1000)
            let (res, _) = unsigned_div_rem(fact5, fact6)
            return (res)
        end
    end

    func buildings_production_time{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(metal_cost : felt, crystal_cost : felt, robot_level : felt, nanite_level) -> (
        time_required : felt
    ):
        if nanite_level == 0:
            let fact1 = metal_cost + crystal_cost
            let fact2 = fact1 * 1000
            let fact3 = robot_level + 1
            let fact4 = 2500 * fact3
            let (fact5, _) = unsigned_div_rem(fact2, fact4)
            let fact6 = fact5 * 3600
            let (res, _) = unsigned_div_rem(fact6, 1000)
        else:
            let fact1 = metal_cost + crystal_cost
            let fact2 = fact1 * 1000
            let fact3 = robot_level + 1
            let fact4a = 2500 * fact3
            let (fact4b) = pow(2, nanite_level)
            let fact4 = fact4a * fact4b
            let (fact5, _) = unsigned_div_rem(fact2, fact4)
            let fact6 = fact5 * 3600
            let (res, _) = unsigned_div_rem(fact6, 1000)
        end
        return (time_required=res)
    end

    func calculate_player_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address : felt
    ) -> (points : felt):
        let (total_spent) = _players_spent_resources.read(address)
        let (points, _) = unsigned_div_rem(total_spent, 1000)
        return (points)
    end
end
