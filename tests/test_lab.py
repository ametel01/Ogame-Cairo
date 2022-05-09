import pytest
from utils.helpers import (
    assert_equals, update_starknet_block, reset_starknet_block, get_block_timestamp,
    TIME_ELAPS_SIX_HOURS, TIME_ELAPS_ONE_HOUR)
from conftest import user1


@pytest.mark.asyncio
async def test_lab_upgrades(starknet, deploy_game_v1):
    (_, ogame, _, _, _, _, user_one, research_lab) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'GOD_MODE',
                                 [20, 8, 0, 0, 0, 8, 0, 0, 3, 5, 5, 10, 0, 5, 1])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1000)
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [813020, 411780, 155260, 2594])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [25, 23, 21, 30, 20, 20])
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_tech_levels',
                                        [1, 0])
    assert_equals(data.result.response, [
                  20, 8, 0, 0, 0, 8, 0, 0, 3, 5, 5, 10, 0, 5, 1])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'energy_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1101)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'energy_tech_upgrade_complete',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'computer_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1202)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'computer_tech_upgrade_complete',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'laser_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1303)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'laser_tech_upgrade_complete',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'armour_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1404)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'armour_tech_upgrade_complete',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'ion_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1505)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'ion_tech_upgrade_complete',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'espionage_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1606)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'espionage_tech_upgrade_complete',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'plasma_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1707)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'plasma_tech_upgrade_complete',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'weapons_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1808)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'weapons_tech_upgrade_complete',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'shielding_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*1909)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'shielding_tech_upgrade_complete',
                                 [])
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'hyperspace_tech_upgrade_start',
                                 [])

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*2010)

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'hyperspace_tech_upgrade_complete',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'astrophysics_upgrade_start',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*3011)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'astrophysics_upgrade_complete',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'combustion_drive_upgrade_start',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*4011)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'combustion_drive_upgrade_complete',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'hyperspace_drive_upgrade_start',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*5011)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'hyperspace_drive_upgrade_complete',
                                 [])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'impulse_drive_upgrade_start',
                                 [])
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR*6011)
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'impulse_drive_upgrade_complete',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_tech_levels',
                                        [1, 0])
    assert_equals(data.result.response, [
                  20, 9, 1, 1, 1, 9, 1, 1, 4, 6, 6, 11, 1, 6, 2])
