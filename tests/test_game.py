import pytest
from starkware.starknet.compiler.compile import get_selector_from_name
from utils.helpers import (
    assert_equals, update_starknet_block, TIME_ELAPS_SIX_HOURS)


@pytest.mark.asyncio
async def test_generate_planet(deploy_game_v1, user1_factory):
    (ogame, erc721, _, _, _) = deploy_game_v1
    user = user1_factory

    # User generate planet and an NFT is assigned.
    await user.execute(ogame.contract_address,
                       get_selector_from_name('generate_planet'),
                       [], 0).invoke()

    # Assert user is the owner of the NFT generated.
    data = await user.execute(erc721.contract_address,
                              get_selector_from_name('ownerOf'),
                              [1, 0], 1).invoke()
    assert_equals(data.result.response[0], user.contract_address)

    # Assert the NFT balance of user is correct.
    data = await user.execute(erc721.contract_address,
                              get_selector_from_name('balanceOf'),
                              [user.contract_address], 2).invoke()
    assert_equals(data.result.response[0], 1)


@pytest.mark.asyncio
async def test_collect_resources(get_starknet, deploy_game_v1, user1_factory):
    starknet = get_starknet
    (ogame, _, metal, crystal, deuterium) = deploy_game_v1
    user = user1_factory

    await user.execute(ogame.contract_address,
                       get_selector_from_name('generate_planet'),
                       [], 0).invoke()

    # Equivalent of 12 hours pass.
    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_SIX_HOURS*2)

    # User collect resources.
    await user.execute(ogame.contract_address,
                       get_selector_from_name('collect_resources'),
                       [], 1).invoke()
    # Assert that the right amount of resources has accrued.
    data = await user.execute(ogame.contract_address,
                              get_selector_from_name('resources_available'),
                              [], 2).invoke()
    assert data.result.response == [785, 490, 195]

    # Assert tokens have been tranferred on ERC20 accounts.
    data = await user.execute(metal.contract_address,
                              get_selector_from_name(
                                  'balanceOf'),
                              [user.contract_address], 3).invoke()
    assert_equals(data.result.response, [785, 0])

    data = await user.execute(crystal.contract_address,
                              get_selector_from_name(
                                  'balanceOf'),
                              [user.contract_address], 4).invoke()
    assert_equals(data.result.response, [490, 0])

    data = await user.execute(deuterium.contract_address,
                              get_selector_from_name(
                                  'balanceOf'),
                              [user.contract_address], 5).invoke()
    assert_equals(data.result.response, [195, 0])
