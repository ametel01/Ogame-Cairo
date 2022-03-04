from numpy import source
import pytest
import os
from utils.Signer import Signer

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.business_logic.state import BlockInfo
from starkware.starknet.compiler.compile import get_selector_from_name

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "PlanetFactory.cairo")
ACCOUNT_FILE = os.path.join("contracts", "utils", "Account.cairo")
ERC721_FILE = os.path.join("contracts", "token", "erc721",
                           "ERC721_Mintable_Burnable.cairo")
TIME_ELAPS_ONE_HOUR = 32000
TIME_ELAPS_SIX_HOURS = 192000

signer = Signer(123456789987654321)


@pytest.fixture
async def get_starknet():
    starknet = await Starknet.empty()
    return starknet


def update_starknet_block(starknet, block_number=1, block_timestamp=TIME_ELAPS_ONE_HOUR):
    starknet.state.state.block_info = BlockInfo(
        block_number=block_number, block_timestamp=block_timestamp)


def reset_starknet_block(starknet):
    update_starknet_block(starknet=starknet)


@pytest.fixture
async def account_factory(get_starknet):
    starknet = get_starknet
    account = await starknet.deploy(
        source=ACCOUNT_FILE,
        constructor_calldata=[signer.public_key])
    return account


@pytest.fixture
async def contract_factory(get_starknet, erc721_factory):
    starknet = get_starknet
    erc721 = erc721_factory
    erc721_address = erc721.contract_address
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
        constructor_calldata=[erc721_address])
    return contract


@pytest.fixture
async def erc721_factory(get_starknet):
    starknet = get_starknet
    contract = await starknet.deploy(
        source=ERC721_FILE,
        constructor_calldata=[79717795807684, 79717795807684, signer.public_key])
    return contract


@pytest.mark.asyncio
async def test_initializer(account_factory):
    account = account_factory
    assert (await account.get_public_key().call()).result.res == (signer.public_key)


@pytest.mark.asyncio
async def test_constructor(contract_factory, erc721_factory):
    contract = contract_factory
    erc721 = erc721_factory

    assert (await contract.erc721_address().call()).result.res == erc721.contract_address


@pytest.mark.asyncio
async def test_generate_planet(get_starknet, contract_factory, account_factory, erc721_factory):
    starknet = get_starknet
    contract = contract_factory
    account = account_factory
    erc721 = erc721_factory
    update_starknet_block(
        starknet=starknet, block_timestamp=156*TIME_ELAPS_ONE_HOUR)
    await account.execute(contract.contract_address,
                          get_selector_from_name('generate_planet'),
                          [], 0).invoke()

    assert (await contract.number_of_planets().call()).result.n_planets == 1

    data = await account.execute(contract.contract_address,
                                 get_selector_from_name('get_planet'),
                                 [], 1).invoke()

    assert data.result.response[0] == 1
    assert data.result.response[1] == 1
    assert data.result.response[2] == 1

#     # assert (await contract.query_metal_production(signer.public_key).call()).result.production == 6


@pytest.mark.asyncio
async def test_production(get_starknet, contract_factory, account_factory):
    starknet = get_starknet
    contract = contract_factory
    account = account_factory
    await account.execute(contract.contract_address,
                          get_selector_from_name('generate_planet'),
                          [], 0).invoke()

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_ONE_HOUR)
    await account.execute(contract.contract_address,
                          get_selector_from_name('collect_resources'),
                          [], 1).invoke()

    data = await account.execute(contract.contract_address,
                                 get_selector_from_name('resources_available'),
                                 [], 2).invoke()
    assert data.result.response == [711, 440, 170]


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
