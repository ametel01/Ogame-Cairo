import pytest
import pytest_asyncio
from utils.helpers import (
    assert_equals, update_starknet_block, reset_starknet_block, get_block_timestamp,
    TIME_ELAPS_SIX_HOURS, TIME_ELAPS_ONE_HOUR)
from conftest import research_lab, user1

@pytest.mark.asyncio
async def test_lab(deploy_game_v1):
    (_, ogame, _, metal, crystal, deuterium, user_one, research_lab) = deploy_game_v1

    # execution_info = await research_lab.get_metal_address().call()
    # assert execution_info.result == (metal.contract_address)
    data = await user1.send_transaction(user_one,
                                        research_lab.contract_address,
                                        'upgrade_research_lab',
                                        [])
    assert_equals(data.result.response[0], 1)

