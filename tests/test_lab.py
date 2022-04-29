import pytest
import pytest_asyncio
from utils.helpers import (
    assert_equals, update_starknet_block, reset_starknet_block, get_block_timestamp,
    TIME_ELAPS_SIX_HOURS, TIME_ELAPS_ONE_HOUR)
from conftest import research_lab, starknet, user1

@pytest.mark.asyncio
async def test_lab(deploy_game_v1):
    (_, ogame, _, metal, crystal, deuterium, user_one, research_lab) = deploy_game_v1

    
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_complete',
                                 [])

    
    response = await user1.send_transaction(user_one,
                                            ogame.contract_address,
                                            'metal_upgrade_start',
                                            [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*2)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'metal_upgrade_complete',
                                 [])
    
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'crystal_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*3)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'crystal_upgrade_complete',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*4)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_complete',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'deuterium_upgrade_start',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*5)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'deuterium_upgrade_complete',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1205)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    
    data = await user1.send_transaction(user_one,
                                        research_lab.contract_address,
                                        'research_lab_upgrade_start',
                                        [])
    assert_equals(data.result.response[0], 1)

    data = await user1.send_transaction(user_one,
                                        research_lab.contract_address,
                                        'research_lab_upgrade_complete',
                                        [])
    assert_equals(data.result.response[0], 1)

    
