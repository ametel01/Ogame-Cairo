import pytest
from utils.helpers import (
    assert_equals, update_starknet_block, TIME_ELAPS_SIX_HOURS, TIME_ELAPS_ONE_HOUR)
from conftest import user1


@pytest.mark.asyncio
async def test_account(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one) = deploy_game_v1

    # # Equivalent of 12 hours pass.
    # update_starknet_block(
    #     starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR)

    # # User collect resources.
    # await user1.send_transaction(user_one,
    #                              ogame.contract_address,
    #                              'collect_resources',
    #                              [])
    # # Assert that the right amount of resources has accrued.
    # data = await user1.send_transaction(user_one,
    #                                     ogame.contract_address,
    #                                     'resources_available',
    #                                     [])
    # assert_equals(data.result.response, [516, 310, 105])

    # update_starknet_block(
    #     starknet=starknet, block_timestamp=TIME_ELAPS_SIX_HOURS)

    # # User collect resources.
    # await user1.send_transaction(user_one,
    #                              ogame.contract_address,
    #                              'collect_resources',
    #                              [])
    # # Assert that the right amount of resources has accrued.
    # data = await user1.send_transaction(user_one,
    #                                     ogame.contract_address,
    #                                     'resources_available',
    #                                     [])
    # assert_equals(data.result.response, [597, 364, 132])

    # Assert that the right amount of resources has accrued.
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'upgrade_solar_plant',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [])
    assert_equals(data.result.response, [1, 1, 1, 2])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_SIX_HOURS)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    # Assert that the right amount of resources has accrued.
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [])
    assert_equals(data.result.response, [597, 364, 132])
