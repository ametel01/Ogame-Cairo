import pytest
import os
from utils.Signer import Signer

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.business_logic.state import BlockInfo
from starkware.starknet.compiler.compile import get_selector_from_name

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "PlanetFactory.cairo")
ACCOUNT_FILE = os.path.join("contracts", "utils", "Account.cairo")
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
async def contract_factory(get_starknet):
    starknet = get_starknet
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    return contract


@pytest.mark.asyncio
async def test_mines_upgrade(get_starknet, contract_factory, account_factory):
    starknet = get_starknet
    contract = contract_factory
    account = account_factory

    await account.execute(contract.contract_address,
                          get_selector_from_name('generate_planet'),
                          [], 0).invoke()

    update_starknet_block(
        starknet=starknet, block_timestamp=TIME_ELAPS_SIX_HOURS*2)
    await account.execute(contract.contract_address,
                          get_selector_from_name(
                              'collect_resources'),
                          [], 1).invoke()

    await account.execute(contract.contract_address,
                          get_selector_from_name(
                              'upgrade_metal_mine'),
                          [], 2).invoke()

    data = await account.execute(contract.contract_address,
                                 get_selector_from_name(
                                     'get_structures_levels'),
                                 [], 3).invoke()
    assert data.result.response == [2, 1, 1]

    await account.execute(contract.contract_address,
                          get_selector_from_name(
                              'upgrade_metal_mine'),
                          [], 4).invoke()

    data = await account.execute(contract.contract_address,
                                 get_selector_from_name(
                                     'get_structures_levels'),
                                 [], 5).invoke()
    assert data.result.response == [3, 1, 1]

    await account.execute(contract.contract_address,
                          get_selector_from_name(
                              'upgrade_crystal_mine'),
                          [], 6).invoke()

    data = await account.execute(contract.contract_address,
                                 get_selector_from_name(
                                     'get_structures_levels'),
                                 [], 7).invoke()
    assert data.result.response == [3, 2, 1]

    await account.execute(contract.contract_address,
                          get_selector_from_name(
                              'upgrade_crystal_mine'),
                          [], 8).invoke()

    data = await account.execute(contract.contract_address,
                                 get_selector_from_name(
                                     'get_structures_levels'),
                                 [], 9).invoke()
    assert data.result.response == [3, 3, 1]

    await account.execute(contract.contract_address,
                          get_selector_from_name(
                              'upgrade_deuterium_mine'),
                          [], 10).invoke()

    data = await account.execute(contract.contract_address,
                                 get_selector_from_name(
                                     'get_structures_levels'),
                                 [], 11).invoke()
    assert data.result.response == [3, 3, 2]

    await account.execute(contract.contract_address,
                          get_selector_from_name(
                              'upgrade_deuterium_mine'),
                          [], 12).invoke()

    data = await account.execute(contract.contract_address,
                                 get_selector_from_name(
                                     'get_structures_levels'),
                                 [], 13).invoke()
    assert data.result.response == [3, 3, 3]
