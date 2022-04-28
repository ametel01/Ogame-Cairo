from numpy import source
import pytest
import os
import pytest_asyncio
from sympy import construct_domain
from utils.Signer import Signer

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.business_logic.state.state import BlockInfo
from starkware.starknet.compiler.compile import get_selector_from_name
# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "Ogame.cairo")
ACCOUNT_FILE = os.path.join("contracts", "utils", "Account.cairo")
ERC721_FILE = os.path.join("contracts", "token", "erc721",
                           "ERC721.cairo")
ERC20_FILE = os.path.join("contracts", "token", "erc20",
                          "ERC20_Mintable.cairo")
MINTER_FILE = os.path.join("contracts", "minter", "erc721_minter.cairo")
LAB_FILE = os.path.join("contracts", "ResearchManager.cairo")
TIME_ELAPS_ONE_HOUR = 3600
TIME_ELAPS_SIX_HOURS = 21600
MAX_UINT = 2**128-1

owner = Signer(123456789987654321)
user1 = Signer(11111111111111111)
user2 = Signer(22222222222222222)


@pytest_asyncio.fixture
async def starknet():
    return await Starknet.empty()


@pytest_asyncio.fixture
async def admin(starknet: Starknet) -> StarknetContract:
    return await starknet.deploy(
        source=ACCOUNT_FILE,
        constructor_calldata=[owner.public_key])


@pytest_asyncio.fixture
async def user_one(starknet: StarknetContract) -> StarknetContract:
    return await starknet.deploy(
        source=ACCOUNT_FILE,
        constructor_calldata=[user1.public_key])


@pytest_asyncio.fixture
async def user_two(starknet):
    return await starknet.deploy(
        source=ACCOUNT_FILE,
        constructor_calldata=[user2.public_key])


@pytest_asyncio.fixture
async def game(starknet, erc721, admin):
    return await starknet.deploy(
        source=CONTRACT_FILE,
        constructor_calldata=[erc721.contract_address, admin.contract_address])


@ pytest_asyncio.fixture
async def erc721(starknet, minter):
    return await starknet.deploy(
        source=ERC721_FILE,
        constructor_calldata=[79717795807684, 79717795807684, minter.contract_address, 3,
                              184555836509371486644298270517380613565396767415278678887948391494588501258,
                              184555836509371486644298270517380613565396767415278678887948391494588501258,
                              2511981064129509550770777692765514099620440566643524046090])


@ pytest_asyncio.fixture
async def metal(starknet, game):
    return await starknet.deploy(
        source=ERC20_FILE,
        constructor_calldata=[469853561196, 22314920797099084, 1, 0, 0,
                              game.contract_address, game.contract_address])


@ pytest_asyncio.fixture
async def crystal(starknet, game):
    return await starknet.deploy(
        source=ERC20_FILE,
        constructor_calldata=[27991888647971180, 5712619723889529932, 1, 0, 0,
                              game.contract_address, game.contract_address])


@ pytest_asyncio.fixture
async def deuterium(starknet, game):
    return await starknet.deploy(
        source=ERC20_FILE,
        constructor_calldata=[1851985284920121062765, 22314920796505429, 1, 0, 0,
                              game.contract_address, game.contract_address])


@pytest_asyncio.fixture
async def minter(starknet, admin):
    return await starknet.deploy(
        source=MINTER_FILE,
        constructor_calldata=[admin.contract_address])


@pytest_asyncio.fixture
async def research_lab(starknet, game, metal, crystal, deuterium):
    return await starknet.deploy(
        source=LAB_FILE,
        constructor_calldata=[game.contract_address,
                              metal.contract_address,
                              crystal.contract_address,
                              deuterium.contract_address])


@pytest_asyncio.fixture
async def deploy_game_v1(minter, erc721, game, admin, user_one,
                         metal, crystal, deuterium, research_lab):

    # Submit NFT contract address to minter.
    await owner.send_transaction(admin,
                                 minter.contract_address,
                                 'setNFTaddress', [erc721.contract_address])

    # Assert admin can give game contract approval on NFT transfer.
    await owner.send_transaction(admin, minter.contract_address,
                                 'setNFTapproval',
                                 [game.contract_address, 1])

    # Mint 200 NFTs and assign them to minter.
    await owner.send_transaction(admin,
                                 minter.contract_address,
                                 'mintAll', [200, 1, 0])

    await owner.send_transaction(admin,
                                 game.contract_address,
                                 'erc20_addresses', [metal.contract_address,
                                                     crystal.contract_address,
                                                     deuterium.contract_address])

    await user1.send_transaction(user_one,
                                 game.contract_address,
                                 'generate_planet', [])

    return(minter, game, erc721, metal, crystal, deuterium, user_one)
