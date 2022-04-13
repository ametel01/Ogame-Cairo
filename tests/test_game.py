import pytest
from utils.helpers import (
    assert_equals, update_starknet_block, reset_starknet_block, get_block_timestamp,
    TIME_ELAPS_SIX_HOURS, TIME_ELAPS_ONE_HOUR)
from conftest import user1


@pytest.mark.asyncio
async def test_account(deploy_game_v1):
    (_, _, erc721, metal, crystal, deuterium, user_one) = deploy_game_v1

    # Assert user is the owner of the NFT generated.
    data = await user1.send_transaction(user_one,
                                        erc721.contract_address,
                                        'ownerOf',
                                        [1, 0])
    assert_equals(data.result.response[0], user_one.contract_address)

    # Assert the NFT balance of user is correct.
    data = await user1.send_transaction(user_one,
                                        erc721.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response[0], 1)

    # Assert that initial amount of resources ERC20 is tranferred to user.
    data = await user1.send_transaction(user_one,
                                        metal.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [500, 0])

    data = await user1.send_transaction(user_one,
                                        crystal.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [300, 0])

    data = await user1.send_transaction(user_one,
                                        deuterium.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [100, 0])


@pytest.mark.asyncio
async def test_collect_resources(starknet, deploy_game_v1):
    (_, ogame, _, metal, crystal, deuterium, user_one) = deploy_game_v1

    # Assert that the right amount of resources has accrued.
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [500, 300, 100, 0])

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
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [425, 270, 100, 22])

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
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [430, 255, 100, 11])

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
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [415, 237, 100, 0])

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
    
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [373, 209, 100, 26])
    
    # User collect resources.
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
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
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [311, 144, 105, 4])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*15)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'robot_factory_upgrade_start',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*16)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'robot_factory_upgrade_complete',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [763, 80, 133, 4])

  
    


@pytest.mark.asyncio
async def test_structures_upgrades(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one) = deploy_game_v1

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [0, 0, 0, 0, 0])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*7)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_complete',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_start',
                                 [])

    # Equivalent of 12 hours pass.
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*8)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_complete',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_start',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*9)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'solar_plant_upgrade_complete',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])

    
    # Assert metal mine level is increasead.
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [0, 0, 0, 3, 0])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*25)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [728, 692, 400, 79])                             
    response = await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'metal_upgrade_start',
                                 [])
    
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*26)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'metal_upgrade_complete',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*27)
    #Assert metal mine level is increasead.
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [1, 0, 0, 3, 0])

    response = await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'crystal_upgrade_start',
                                 [])
    
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*28)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'crystal_upgrade_complete',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [1, 1, 0, 3, 0])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [3074, 1426, 800, 57]) 
    response = await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'deuterium_upgrade_start',
                                 [])
    
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*29)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'deuterium_upgrade_complete',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*30)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    
    response = await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'robot_factory_upgrade_start',
                                 [])
    
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*31)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'robot_factory_upgrade_complete',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [1, 1, 1, 3, 1])
    response = await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'deuterium_upgrade_start',
                                 [])
    
   