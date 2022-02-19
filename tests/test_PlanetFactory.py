import pytest
import os
from eth_account import Account
from utils.Signer import Signer

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.business_logic.state import BlockInfo
from starkware.starknet.compiler.compile import get_selector_from_name

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "PlanetFactory.cairo")
ACCOUNT_FILE = os.path.join("contracts", "utils", "Account.cairo")
DEFAULT_TIMESTAMP = 320000

signer = Signer(123456789987654321)


@pytest.fixture
async def get_starknet():
    starknet = await Starknet.empty()
    return starknet


def update_starknet_block(starknet, block_number=1, block_timestamp=DEFAULT_TIMESTAMP):
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
async def contract_factory(get_starknet):
    starknet = get_starknet
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    return contract


@pytest.mark.asyncio
async def test_initializer(account_factory):
    account = account_factory
    assert (await account.get_public_key().call()).result.res == (signer.public_key)


@pytest.mark.asyncio
async def test_generate_planet(get_starknet, contract_factory, account_factory):
    starknet = get_starknet
    contract = contract_factory
    account = account_factory
    await account.execute(contract.contract_address,
                          get_selector_from_name('generate_planet'),
                          [], 0).invoke()

    assert (await contract.number_of_planets().call()).result.n_planets == 1

    data = await contract.get_planet(1).call()
    assert data.result.planet.metal_mine == 1
    assert data.result.planet.crystal_mine == 1
    assert data.result.planet.deuterium_mine == 1

    # update_starknet_block(starknet=starknet, block_timestamp=DEFAULT_TIMESTAMP)
    # assert (await contract.query_metal_production(signer.public_key).call()).result.production == 6
    # data = await account.execute(contract.contract_address,
    #                              get_selector_from_name(
    #                                  'query_metal_production'),
    #                              [], 1).invoke()

    # assert data.result.response == 0
