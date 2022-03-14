import pytest
from starkware.starknet.compiler.compile import get_selector_from_name
from utils.helpers import (
    assert_equals, update_starknet_block, TIME_ELAPS_SIX_HOURS)
from conftest import (crystal, deuterium, metal, owner, user1, user_one)


@pytest.mark.asyncio
async def test_account(deploy_game_v1):
    (_, game, erc721, metal, crystal, deuterium, user_one) = deploy_game_v1

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

    # Equivalent of 12 hours pass.
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_SIX_HOURS*2)

    # User collect resources.
    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'collect_resources',
                                 [])
    # Assert that the right amount of resources has accrued.
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'resources_available',
                                        [])
    assert_equals(data.result.response, [785, 490, 195])

    # Assert tokens have been tranferred on ERC20 accounts.
    data = await user1.send_transaction(user_one,
                                        metal.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [785, 0])

    data = await user1.send_transaction(user_one,
                                        crystal.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [490, 0])

    data = await user1.send_transaction(user_one,
                                        deuterium.contract_address,
                                        'balanceOf',
                                        [user_one.contract_address])
    assert_equals(data.result.response, [195, 0])


@pytest.mark.asyncio
async def test_mines_upgrade(deploy_game_v1):
    (_, ogame, _, _, _, _, user_one) = deploy_game_v1

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'upgrade_metal_mine',
                                 [])

    # Assert metal mine level is increasead.
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [])
    assert_equals(data.result.response, [2, 1, 1])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'upgrade_metal_mine',
                                 [])

    # Assert metal mine level is increasead.
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [])
    assert_equals(data.result.response, [3, 1, 1])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'upgrade_crystal_mine',
                                 [])

    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [])
    assert_equals(data.result.response, [3, 2, 1])

    await user1.send_transaction(user_one,
                                 ogame.contract_address,
                                 'upgrade_deuterium_mine',
                                 [])

    # Assert deuterium mine level is increasead.
    data = await user1.send_transaction(user_one,
                                        ogame.contract_address,
                                        'get_structures_levels',
                                        [])
    assert_equals(data.result.response, [3, 2, 2])
