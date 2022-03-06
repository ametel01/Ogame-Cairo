from ast import operator
import pytest
import os

from sympy import re
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

signer = Signer(123456789987654321)
signer2 = Signer(987654321123456789)
signer3 = Signer(111111111111111111)


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
async def acc_2_factory(get_starknet):
    starknet = get_starknet
    account = await starknet.deploy(
        source=ACCOUNT_FILE,
        constructor_calldata=[signer2.public_key])
    return account


@pytest.fixture
async def acc_3_factory(get_starknet):
    starknet = get_starknet
    account = await starknet.deploy(
        source=ACCOUNT_FILE,
        constructor_calldata=[signer3.public_key])
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
async def erc721_factory(get_starknet, account_factory):
    starknet = get_starknet
    account = account_factory
    contract = await starknet.deploy(
        source=ERC721_FILE,
        constructor_calldata=[79717795807684, 79717795807684, account.contract_address, 3,
                              184555836509371486644298270517380613565396767415278678887948391494588501258,
                              184555836509371486644298270517380613565396767415278678887948391494588501258,
                              2511981064129509550770777692765514099620440566643524046090])
    return contract


@pytest.mark.asyncio
async def test_erc721_constructor(get_starknet, erc721_factory, account_factory, acc_2_factory, acc_3_factory):
    starknet = get_starknet
    token_contract = erc721_factory
    account = account_factory
    receiver = acc_3_factory
    operator = acc_2_factory

    data = await account.execute(token_contract.contract_address,
                                 get_selector_from_name('getOwner'),
                                 [], 0).invoke()
    assert data.result.response[0] == account.contract_address

    await account.execute(token_contract.contract_address,
                          get_selector_from_name('mint'),
                          [account.contract_address, 1, 0], 1).invoke()

    await account.execute(token_contract.contract_address,
                          get_selector_from_name('setApprovalForAll'),
                          [operator.contract_address, 1], 2).invoke()

    await operator.execute(token_contract.contract_address,
                           get_selector_from_name('transferFrom'),
                           [account.contract_address, receiver.contract_address, 1, 0], 0).invoke()

    data = await account.execute(token_contract.contract_address,
                                 get_selector_from_name('ownerOf'),
                                 [1, 0], 3).invoke()
    assert data.result.response[0] == receiver.contract_address

    # data = await account.execute(token_contract.contract_address,
    #                              get_selector_from_name('tokenURI'),
    #                              [1, 0], 2).invoke()
    # data_to_hex = str(hex(data.result.response[1]))[
    #     2:-4] + str(hex(data.result.response[2]))[2:-4] + str(hex(data.result.response[3]))[
    #         2:-4] + "2f" + str(hex(data.result.response[4]))[2:] + "2e6a736f6eS"

    # # 'https://gateway.pinata.cloud/ipfs/QmVijv2FZTxApnNT5bP8CU5dfrNW36s29xJVjckksn6s73/1.json'
    # assert bytes.fromhex(data_to_hex).decode('utf-8') == 0
