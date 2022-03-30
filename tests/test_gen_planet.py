import pytest
from utils.helpers import (
    assert_equals, update_starknet_block, TIME_ELAPS_ONE_HOUR, TIME_ELAPS_SIX_HOURS)
from conftest import user1

@pytest.mark.asyncio
async def test_collect_resources(starknet, deploy_game_v1):
    (_, ogame, _, metal, crystal, deuterium, user_one) = deploy_game_v1

    data = await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'get_my_planet',
                                 [])
    assert_equals(data.result.response, [1,0])
    
    data = await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'owner_of',
                                 [user_one.contract_address])
    assert_equals(data.result.response, [1,0])
