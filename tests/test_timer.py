import pytest
from utils.helpers import (
    assert_equals, update_starknet_block, TIME_ELAPS_ONE_HOUR, TIME_ELAPS_SIX_HOURS)
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
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'metal_upgrade_complete',
                                 [])

@pytest.mark.asyncio
@pytest.mark.xfail
async def test_collect_resources_fail(starknet, deploy_game_v1):
    (_, ogame, _, metal, crystal, deuterium, user_one) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'metal_upgrade_start',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'metal_upgrade_complete',
                                 [])