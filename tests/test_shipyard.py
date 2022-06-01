import pytest
from utils.helpers import (
    assert_equals, update_starknet_block, reset_starknet_block, get_block_timestamp,
    TIME_ELAPS_SIX_HOURS, TIME_ELAPS_ONE_HOUR)
from conftest import user1


@pytest.mark.asyncio
async def test_shipyard_building(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one, _, _) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'GOD_MODE',
                                 [20, 8, 0, 2, 0, 8, 4, 0, 3, 5, 5, 10, 0, 5, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1000)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [8125700, 4115100, 1551700, 2594])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'shipyard_upgrade_start',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [7716100, 3910300, 1449300, 2594])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1015)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'shipyard_upgrade_complete',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [25, 23, 21, 30, 20, 20, 11])


@pytest.mark.asyncio
async def test_cargo(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one, _, _) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'GOD_MODE',
                                 [20, 8, 0, 2, 0, 8, 4, 0, 3, 5, 5, 10, 0, 5, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0])
    update_starknet_block(
        starknet=starknet, block_timestamp=36000)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [81752, 41448, 15616, 2594])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'cargo_ship_build_start',
                                 [10])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [61752, 21448, 15616, 2594])
    update_starknet_block(
        starknet=starknet, block_timestamp=36172)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'cargo_ship_build_complete',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_fleet',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [10, 10, 0, 0, 0, 0, 0, 0, 0])


@pytest.mark.asyncio
async def test_recycler(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one, _, _) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'GOD_MODE',
                                 [20, 8, 0, 6, 0, 8, 4, 0, 3, 5, 5, 10, 0, 5, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0])
    update_starknet_block(
        starknet=starknet, block_timestamp=3600*10)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [81752, 41448, 15616, 2594])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'recycler_ship_build_start',
                                 [5])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [31752, 11448, 5616, 2594])
    update_starknet_block(
        starknet=starknet, block_timestamp=36000+3520)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'recycler_ship_build_complete',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_fleet',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [10, 0, 5, 0, 0, 0, 0, 0, 0])


@pytest.mark.asyncio
async def test_espionage_probe(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one, _, _) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'GOD_MODE',
                                 [20, 8, 0, 3, 0, 8, 4, 0, 3, 5, 5, 10, 0, 5, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0])
    update_starknet_block(
        starknet=starknet, block_timestamp=3600*10)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [81752, 41448, 15616, 2594])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'espionage_probe_build_start',
                                 [10])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [81752, 31448, 15616, 2594])
    update_starknet_block(
        starknet=starknet, block_timestamp=36000+440)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'espionage_probe_build_complete',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_fleet',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [10, 0, 0, 10, 0, 0, 0, 0, 0])


@pytest.mark.asyncio
async def test_solar_satellite(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one, _, _) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'GOD_MODE',
                                 [20, 8, 0, 3, 0, 8, 4, 0, 3, 5, 5, 10, 0, 5, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0])
    update_starknet_block(
        starknet=starknet, block_timestamp=3600*10)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [81752, 41448, 15616, 2594])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_satellite_build_start',
                                 [10])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [81752, 21448, 10616, 2594])
    update_starknet_block(
        starknet=starknet, block_timestamp=36000+1100)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_satellite_build_complete',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_fleet',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [10, 0, 0, 0, 10, 0, 0, 0, 0])


@pytest.mark.asyncio
async def test_light_fighter(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one, _, _) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'GOD_MODE',
                                 [20, 8, 0, 3, 0, 8, 4, 0, 3, 5, 5, 10, 0, 5, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0])
    update_starknet_block(
        starknet=starknet, block_timestamp=3600*10)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [81752, 41448, 15616, 2594])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'light_fighter_build_start',
                                 [10])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [51752, 31448, 15616, 2594])
    update_starknet_block(
        starknet=starknet, block_timestamp=36000+1760)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'light_fighter_build_complete',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_fleet',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [10, 0, 0, 0, 0, 10, 0, 0, 0])

@pytest.mark.asyncio
async def test_cruiser(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one, _, _) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'GOD_MODE',
                                 [20, 8, 0, 3, 0, 8, 4, 0, 3, 5, 5, 10, 0, 5, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0])
    update_starknet_block(
        starknet=starknet, block_timestamp=3600*40)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [325508, 164892, 62164, 2594])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'cruiser_build_start',
                                 [10])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [125508, 94892, 42164, 2594])
    update_starknet_block(
        starknet=starknet, block_timestamp=36000+11800)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'cruiser_build_complete',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_fleet',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [10, 0, 0, 0, 0, 0, 0, 10, 0])

    @pytest.mark.asyncio
    async def test_battleship(starknet, deploy_game_v1):
        (_, ogame, _, _, _, _, user_one, _, _) = deploy_game_v1

        await user1.send_transaction(user_one,
                                    ogame.contract_address,
                                    'GOD_MODE',
                                    [20, 8, 0, 3, 0, 8, 4, 0, 3, 5, 5, 10, 0, 5, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0])
        update_starknet_block(
            starknet=starknet, block_timestamp=3600*40)
        await user1.send_transaction(user_one,
                                    ogame.contract_address,
                                    'collect_resources',
                                    [])

        data = await user1.send_transaction(user_one,
                                            ogame.contract_address,
                                            'resources_available',
                                            [user_one.contract_address])
        assert_equals(data.result.response, [325508, 164892, 62164, 2594])

        await user1.send_transaction(user_one,
                                    ogame.contract_address,
                                    'cruiser_build_start',
                                    [10])
        data = await user1.send_transaction(user_one,
                                            ogame.contract_address,
                                            'resources_available',
                                            [user_one.contract_address])
        assert_equals(data.result.response, [125508, 94892, 42164, 2594])
        update_starknet_block(
            starknet=starknet, block_timestamp=36000+11800)

        await user1.send_transaction(user_one,
                                    ogame.contract_address,
                                    'cruiser_build_complete',
                                    [])
        data = await user1.send_transaction(user_one,
                                            ogame.contract_address,
                                            'get_fleet',
                                            [user_one.contract_address])
        assert_equals(data.result.response, [10, 0, 0, 0, 0, 0, 0, 10, 0])