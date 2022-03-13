import pytest
from utils.helpers import (update_starknet_block, TIME_ELAPS_SIX_HOURS)
from starkware.starknet.compiler.compile import get_selector_from_name


@pytest.mark.asyncio
async def test_generate_planet(get_starknet, game_factory, owner_factory, user1_factory, 
    user2_factory, erc721_factory, metal_erc20_factory, crystal_erc20_factory, deuterium_erc20_factory):
    starknet = get_starknet
    contract = game_factory
    owner = owner_factory
    user1 = user1_factory
    user2 = user2_factory
    erc721 = erc721_factory
    metal_contract = metal_erc20_factory
    crystal_contract = crystal_erc20_factory
    deuterium_contract = deuterium_erc20_factory

    assert (await contract.erc721_address().call()).result.res == erc721.contract_address

    await owner.execute(erc721.contract_address,
                        get_selector_from_name('mint'),
                        [owner.contract_address, 1, 0], 0).invoke()
    await owner.execute(erc721.contract_address,
                        get_selector_from_name('mint'),
                        [owner.contract_address, 2, 0], 1).invoke()

    await owner.execute(erc721.contract_address,
                        get_selector_from_name('setApprovalForAll'),
                        [contract.contract_address, 1], 2).invoke()

    await owner.execute(erc721.contract_address,
                        get_selector_from_name('isApprovedForAll'),
                        [owner.contract_address, contract.contract_address], 3).invoke()

    await user1.execute(contract.contract_address,
                        get_selector_from_name('generate_planet'),
                        [], 0).invoke()

    await owner.execute(contract.contract_address,
                        get_selector_from_name('erc20_addresses'),
                        [metal_contract.contract_address,
                         crystal_contract.contract_address,
                         deuterium_contract.contract_address], 4).invoke()
    
    assert (await contract.number_of_planets().call()).result.n_planets == 1
    data = await user1.execute(erc721.contract_address,
                               get_selector_from_name('ownerOf'),
                               [1, 0], 1).invoke()
    assert data.result.response[0] == user1.contract_address

    await user2.execute(contract.contract_address,
                        get_selector_from_name('generate_planet'),
                        [], 0).invoke()

    assert (await contract.number_of_planets().call()).result.n_planets == 2

    data = await user2.execute(erc721.contract_address,
                               get_selector_from_name('ownerOf'),
                               [2, 0], 1).invoke()

    assert data.result.response[0] == user2.contract_address

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_SIX_HOURS*2)
    await user1.execute(contract.contract_address,
                        get_selector_from_name(
                            'collect_resources'),
                        [], 2).invoke()
    data = await user1.execute(contract.contract_address,
                               get_selector_from_name('resources_available'),
                               [], 3).invoke()
    assert data.result.response == [785, 490, 195]

    # await user1.execute(contract.contract_address,
    #                     get_selector_from_name(
    #                         'upgrade_metal_mine'),
    #                     [], 4).invoke()

    # data = await user1.execute(contract.contract_address,
    #                            get_selector_from_name(
    #                                'get_structures_levels'),
    #                            [], 5).invoke()
    # assert data.result.response == [2, 1, 1]

    # await user1.execute(contract.contract_address,
    #                     get_selector_from_name(
    #                         'upgrade_metal_mine'),
    #                     [], 6).invoke()

    # data = await user1.execute(contract.contract_address,
    #                            get_selector_from_name(
    #                                'get_structures_levels'),
    #                            [], 7).invoke()
    # assert data.result.response == [3, 1, 1]

    # await user1.execute(contract.contract_address,
    #                     get_selector_from_name(
    #                         'upgrade_crystal_mine'),
    #                     [], 8).invoke()

    # data = await user1.execute(contract.contract_address,
    #                            get_selector_from_name(
    #                                'get_structures_levels'),
    #                            [], 9).invoke()
    # assert data.result.response == [3, 2, 1]

    # await user1.execute(contract.contract_address,
    #                     get_selector_from_name(
    #                         'upgrade_crystal_mine'),
    #                     [], 10).invoke()

    # data = await user1.execute(contract.contract_address,
    #                            get_selector_from_name(
    #                                'get_structures_levels'),
    #                            [], 11).invoke()
    # assert data.result.response == [3, 3, 1]

    # await user1.execute(contract.contract_address,
    #                     get_selector_from_name(
    #                         'upgrade_deuterium_mine'),
    #                     [], 12).invoke()

    # data = await user1.execute(contract.contract_address,
    #                            get_selector_from_name(
    #                                'get_structures_levels'),
    #                            [], 13).invoke()
    # assert data.result.response == [3, 3, 2]

    # await user1.execute(contract.contract_address,
    #                     get_selector_from_name(
    #                         'upgrade_deuterium_mine'),
    #                     [], 14).invoke()

    # data = await user1.execute(contract.contract_address,
    #                            get_selector_from_name(
    #                                'get_structures_levels'),
    #                            [], 15).invoke()
    # assert data.result.response == [3, 3, 3]
#     assert data.result.response[1] == 1
#     assert data.result.response[2] == 1

#     # assert (await contract.query_metal_production(signer.public_key).call()).result.production == 6


# @pytest.mark.asyncio
# async def test_production(get_starknet, contract_factory, account_factory):
#     starknet = get_starknet
#     contract = contract_factory
#     account = account_factory
#     await account.execute(contract.contract_address,
#                           get_selector_from_name('generate_planet'),
#                           [], 0).invoke()

#     update_starknet_block(
#         starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR)
#     await account.execute(contract.contract_address,
#                           get_selector_from_name('collect_resources'),
#                           [], 1).invoke()


# @pytest.mark.asyncio
# async def test_mines_upgrade(get_starknet, contract_factory, account_factory):
#     starknet = get_starknet
#     contract = contract_factory
#     account = account_factory
#     pkey = (await account.get_public_key().call()).result.res
#     await account.execute(contract.contract_address,
#                           get_selector_from_name('generate_planet'),
#                           [], 0).invoke()

#     update_starknet_block(
#         starknet=starknet, block_timestamp=TIME_ELAPS_SIX_HOURS)
#     await account.execute(contract.contract_address,
#                           get_selector_from_name('collect_resources'),
#                           [], 1).invoke()

#     await account.execute(contract.contract_address,
#                           get_selector_from_name('upgrade_metal_mine'),
#                           [], 2).invoke()

#     await account.execute(contract.contract_address,
#                           get_selector_from_name(
#                               'get_structures_levels'),
#                           [], 3).invoke()

#     await account.execute(contract.contract_address,
#                           get_selector_from_name('upgrade_metal_mine'),
#                           [], 4).invoke()

#     await account.execute(contract.contract_address,
#                           get_selector_from_name(
#                               'get_structures_levels'),
#                           [], 5).invoke()
