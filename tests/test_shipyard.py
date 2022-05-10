import pytest
from utils.helpers import (
    assert_equals, update_starknet_block, reset_starknet_block, get_block_timestamp,
    TIME_ELAPS_SIX_HOURS, TIME_ELAPS_ONE_HOUR)
from conftest import user1


@pytest.mark.asyncio
async def test_shipyard(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one, _, _) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'GOD_MODE',
                                 [20, 8, 0, 2, 0, 8, 4, 0, 3, 5, 5, 10, 0, 5, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1000)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [813020, 411780, 155260, 2594])

    await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'shipyard_upgrade_start',
                                        [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [812220, 411380, 155060, 2594])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1001)
    await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'shipyard_upgrade_complete',
                                        [])

    await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'cargo_ship_build_start',
                                        [5])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1005)
    await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'cargo_ship_build_complete',
                                        [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_fleet',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [2, 5, 0, 0, 0, 0, 0, 0, 0])


    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [25, 23, 21, 30, 20, 20, 2])

