%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.ResearchManager import (
    research_lab_upgrade_cost, energy_tech_upgrade_cost, combustion_drive_upgrade_cost)
from contracts.utils.Formulas import (
    formulas_solar_plant, _resources_production_formula, formulas_solar_plant_building,
    formulas_metal_building, formulas_crystal_building, formulas_deuterium_building,
    formulas_production_scaler, _consumption, _consumption_deuterium,
    formulas_buildings_production_time, formulas_robot_factory_building)

@external
func test_resources_production{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> ():
    # Test for metal production scaled to 10k
    let (actual) = _resources_production_formula(30, 0)
    let expected = 0
    assert actual = expected
    let (actual) = _resources_production_formula(30, 1)
    let expected = 33
    assert actual = expected
    let (actual) = _resources_production_formula(30, 2)
    let expected = 72
    assert actual = expected
    let (actual) = _resources_production_formula(30, 10)
    let expected = 778
    assert actual = expected
    let (actual) = _resources_production_formula(30, 25)
    let expected = 8126
    assert actual = expected
    # Test for crystal production scaled to 10k
    let (actual) = _resources_production_formula(20, 2)
    let expected = 48
    assert actual = expected
    let (actual) = _resources_production_formula(20, 10)
    let expected = 518
    assert actual = expected
    let (actual) = _resources_production_formula(20, 25)
    let expected = 5417
    assert actual = expected
    # Test for deuterium production scaled to 10k
    let (actual) = _resources_production_formula(10, 2)
    let expected = 24
    assert actual = expected
    let (actual) = _resources_production_formula(10, 10)
    let expected = 259
    assert actual = expected
    let (actual) = _resources_production_formula(10, 25)
    let expected = 2708
    assert actual = expected
    return ()
end

@external
func test_solar_plant_production{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> ():
    let (actual) = formulas_solar_plant(2)
    let expected = 48
    assert actual = expected

    let (actual) = formulas_solar_plant(10)
    let expected = 518
    assert actual = expected

    let (actual) = formulas_solar_plant(25)
    let expected = 5417
    assert actual = expected
    return ()
end

@external
func test_metal_building_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> ():
    let (metal, crystal) = formulas_metal_building(1)
    let expected = (90, 22)
    assert (metal, crystal) = expected

    let (metal, crystal) = formulas_metal_building(9)
    let expected = (2306, 576)
    assert (metal, crystal) = expected

    let (metal, crystal) = formulas_metal_building(24)
    let expected = (1010046, 252511)
    assert (metal, crystal) = expected
    return ()
end

@external
func test_crystal_building_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> ():
    let (metal, crystal) = formulas_crystal_building(1)
    let expected = (76, 38)
    assert (metal, crystal) = expected

    let (metal, crystal) = formulas_crystal_building(9)
    let expected = (3298, 1649)
    assert (metal, crystal) = expected

    let (metal, crystal) = formulas_crystal_building(24)
    let expected = (3802951, 1901475)
    assert (metal, crystal) = expected
    return ()
end

@external
func test_deuterium_building_cost{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    let (metal, crystal) = formulas_deuterium_building(1)
    let expected = (337, 112)
    assert (metal, crystal) = expected

    let (metal, crystal) = formulas_deuterium_building(9)
    let expected = (8649, 2883)
    assert (metal, crystal) = expected

    let (metal, crystal) = formulas_deuterium_building(24)
    let expected = (3787675, 1262558)
    assert (metal, crystal) = expected
    return ()
end

@external
func test_solar_plant_building_cost{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (metal, crystal) = formulas_solar_plant_building(1)
    let expected = (75, 30)
    assert (metal, crystal) = expected

    let (metal, crystal) = formulas_solar_plant_building(9)
    let expected = (2883, 1153)
    assert (metal, crystal) = expected

    let (metal, crystal) = formulas_solar_plant_building(24)
    let expected = (1262558, 505023)
    assert (metal, crystal) = expected
    return ()
end

@external
func test_robot_factory_building_cost{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (metal, crystal, deuterium) = formulas_robot_factory_building(0)
    let expected = (400, 120, 200)
    assert (metal, crystal, deuterium) = expected

    let (metal, crystal, deuterium) = formulas_robot_factory_building(1)
    let expected = (800, 240, 400)
    assert (metal, crystal, deuterium) = expected

    let (metal, crystal, deuterium) = formulas_robot_factory_building(10)
    let expected = (409600, 122880, 204800)
    assert (metal, crystal, deuterium) = expected

    let (metal, crystal, deuterium) = formulas_robot_factory_building(25)
    let expected = (13421772800, 4026531840, 6710886400)
    assert (metal, crystal, deuterium) = expected
    return ()
end

@external
func test_production_scaler{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (metal, crystal, deuterium) = formulas_production_scaler(1000, 500, 250, 100, 150)
    let expected = (1000, 500, 250)
    assert (metal, crystal, deuterium) = expected

    let (metal, crystal, deuterium) = formulas_production_scaler(1000, 500, 250, 100, 33)
    let expected = (330, 165, 82)
    assert (metal, crystal, deuterium) = expected

    let (metal, crystal, deuterium) = formulas_production_scaler(1000, 500, 250, 100, 50)
    let expected = (500, 250, 125)
    assert (metal, crystal, deuterium) = expected
    return ()
end

@external
func test_mine_consumption{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (metal_crystal_cons) = _consumption(2)
    let expected = 24
    assert (metal_crystal_cons) = expected

    let (deut_cons) = _consumption_deuterium(2)
    let expected = 48
    assert (deut_cons) = expected
    return ()
end

@external
func test_buildings_production_time{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (prod_time) = formulas_buildings_production_time(60, 15, 0)
    let expected = 108
    assert prod_time = expected

    let (prod_time) = formulas_buildings_production_time(5189, 1297, 0)
    let expected = 9338
    assert prod_time = expected

    let (prod_time) = formulas_buildings_production_time(5189, 1297, 9)
    let expected = 932
    assert prod_time = expected
    return ()
end

@external
func test_research_lab_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (metal, crystal, deuterium) = research_lab_upgrade_cost(0)
    let exp_met = 200
    let exp_cryst = 400
    let exp_deut = 200
    assert metal = exp_met
    assert crystal = exp_cryst
    assert deuterium = exp_deut

    let (metal, crystal, deuterium) = research_lab_upgrade_cost(9)
    let exp_met = 102400
    let exp_cryst = 204800
    let exp_deut = 102400
    assert metal = exp_met
    assert crystal = exp_cryst
    assert deuterium = exp_deut
    return ()
end

@external
func test_energy_tech_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let (metal, crystal, deuterium) = energy_tech_upgrade_cost(0)
    let exp_met = 0
    let exp_cryst = 800
    let exp_deut = 400
    assert metal = exp_met
    assert crystal = exp_cryst
    assert deuterium = exp_deut

    let (metal, crystal, deuterium) = energy_tech_upgrade_cost(9)
    let exp_met = 0
    let exp_cryst = 409600
    let exp_deut = 204800
    assert metal = exp_met
    assert crystal = exp_cryst
    assert deuterium = exp_deut
    return ()
end

@external
func test_combustion_drive_cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
    alloc_locals
    let (metal, crystal, deuterium) = combustion_drive_upgrade_cost(0)
    let exp_met = 400
    let exp_cryst = 0
    let exp_deut = 600
    assert metal = exp_met
    assert crystal = exp_cryst
    assert deuterium = exp_deut

    let (metal, crystal, deuterium) = combustion_drive_upgrade_cost(9)
    let exp_met = 204800
    let exp_cryst = 0
    let exp_deut = 307200
    assert metal = exp_met
    assert crystal = exp_cryst
    assert deuterium = exp_deut
    return ()
end
