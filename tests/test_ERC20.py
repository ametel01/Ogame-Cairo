import pytest
from utils.Signer import Signer
from utils.fix import CONTRACT_FILE, ACCOUNT_FILE, ERC721_FILE, TIME_ELAPS_SIX_HOURS, MAX_UINT
from utils.fix import owner, user1, user2
from utils.fix import (
    get_starknet, owner_factory, user1_factory, user2_factory,
    game_factory, erc721_factory, update_starknet_block, metal_erc20_factory, crystal_erc20_factory,
    deuterium_erc20_factory, assert_equals)
from starkware.starknet.compiler.compile import get_selector_from_name

metal_contract = metal_erc20_factory
crystal_contract = crystal_erc20_factory
deuterium_contract = deuterium_erc20_factory


@pytest.mark.asyncio
async def test_distribute_resources(get_starknet, owner_factory, user1_factory, game_factory,
                                    metal_erc20_factory, crystal_erc20_factory, deuterium_erc20_factory,
                                    erc721_factory):
    starknet = get_starknet
    game_contract = game_factory
    erc721 = erc721_factory
    metal_contract = metal_erc20_factory
    crystal_contract = crystal_erc20_factory
    deuterium_contract = deuterium_erc20_factory
    owner = owner_factory
    user = user1_factory

    await owner.execute(erc721.contract_address,
                        get_selector_from_name('mint'),
                        [owner.contract_address, 1, 0], 0).invoke()

    await owner.execute(erc721.contract_address,
                        get_selector_from_name('mint'),
                        [owner.contract_address, 2, 0], 1).invoke()

    await owner.execute(erc721.contract_address,
                        get_selector_from_name('setApprovalForAll'),
                        [game_contract.contract_address, 1], 2).invoke()

    await user.execute(game_contract.contract_address,
                       get_selector_from_name('generate_planet'),
                       [], 0).invoke()

    await owner.execute(game_contract.contract_address,
                        get_selector_from_name('erc20_addresses'),
                        [metal_contract.contract_address,
                         crystal_contract.contract_address,
                         deuterium_contract.contract_address], 3).invoke()

    data = await owner.execute(metal_contract.contract_address,
                               get_selector_from_name('balanceOf'),
                               [game_contract.contract_address], 4).invoke()
    assert_equals(data.result.response[0], 2**128-1)

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_SIX_HOURS*2)

    await user.execute(game_contract.contract_address,
                       get_selector_from_name(
                           'collect_resources'),
                       [], 1).invoke()
    data = await user.execute(metal_contract.contract_address,
                              get_selector_from_name(
                                  'balanceOf'),
                              [user.contract_address], 2).invoke()
    assert_equals(data.result.response, [285, 0])

    data = await user.execute(crystal_contract.contract_address,
                              get_selector_from_name(
                                  'balanceOf'),
                              [user.contract_address], 3).invoke()
    assert_equals(data.result.response, [190, 0])

    data = await user.execute(deuterium_contract.contract_address,
                              get_selector_from_name(
                                  'balanceOf'),
                              [user.contract_address], 4).invoke()
    assert_equals(data.result.response, [95, 0])
    # data = await user.execute(game_contract.contract_address,
    #                           get_selector_from_name('resources_available'),
    #                           [], 2).invoke()
    # assert data.result.response == [3034, 1989, 944]
