import pytest
from utils.helpers import (
    assert_equals, update_starknet_block, TIME_ELAPS_SIX_HOURS)
from conftest import user1

@pytest.mark.asyncio
async def test_collect_resources(starknet, deploy_game_v1):
    (_, ogame, _, metal, crystal, deuterium, user_one) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'metal_upgrade_start',
                                 [])

    # Equivalent of 12 hours pass.
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_SIX_HOURS*2)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'metal_upgrade_complete',
                                 [])

    # Assert metal mine level is increasead.
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [])
    assert_equals(data.result.response, [2, 1, 1, 1])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [])
    assert_equals(data.result.response, [410, 278, 100])

    # Assert tokens have been tranferred on ERC20 accounts.
    data = await user1.send_transaction(user_one,
                                        metal.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [410, 0])

    data = await user1.send_transaction(user_one,
                                        crystal.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [278, 0])

    data = await user1.send_transaction(user_one,
                                        deuterium.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [100, 0])
