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
                           "ERC721.cairo")
TIME_ELAPS_ONE_HOUR = 32000
TIME_ELAPS_SIX_HOURS = 192000

owner = Signer(123456789987654321)
user1 = Signer(11111111111111111)
user2 = Signer(22222222222222222)


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
async def owner_factory(get_starknet):
    starknet = get_starknet
    account = await starknet.deploy(
        source=ACCOUNT_FILE,
        constructor_calldata=[owner.public_key])
    return account


@pytest.fixture
async def user1_factory(get_starknet):
    starknet = get_starknet
    account = await starknet.deploy(
        source=ACCOUNT_FILE,
        constructor_calldata=[user1.public_key])
    return account


@pytest.fixture
async def user2_factory(get_starknet):
    starknet = get_starknet
    account = await starknet.deploy(
        source=ACCOUNT_FILE,
        constructor_calldata=[user2.public_key])
    return account


@pytest.fixture
async def contract_factory(get_starknet, erc721_factory):
    starknet = get_starknet
    erc721 = erc721_factory
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
        constructor_calldata=[erc721.contract_address])
    return contract


@pytest.fixture
async def erc721_factory(get_starknet, owner_factory):
    starknet = get_starknet
    owner = owner_factory
    contract = await starknet.deploy(
        source=ERC721_FILE,
        constructor_calldata=[79717795807684, 79717795807684, owner.contract_address, 3,
                              184555836509371486644298270517380613565396767415278678887948391494588501258,
                              184555836509371486644298270517380613565396767415278678887948391494588501258,
                              2511981064129509550770777692765514099620440566643524046090])
    return contract
