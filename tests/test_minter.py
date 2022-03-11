import pytest
from utils.Signer import Signer
from utils.fix import owner
from utils.fix import (
    get_starknet, owner_factory, erc721_factory, minter_factory, assert_equals)
from starkware.starknet.compiler.compile import get_selector_from_name

@pytest.mark.asyncio
async def test_mint_NFTs(get_starknet, owner_factory, erc721_factory, minter_factory):
    starknet = get_starknet
    erc721 = erc721_factory
    owner = owner_factory
    minter = minter_factory
    

    await owner.execute(minter.contract_address,
                        get_selector_from_name('setNftAddress'),
                        [erc721.contract_address], 0).invoke()

    await owner.execute(minter.contract_address,
                        get_selector_from_name('mintAll'),
                        [200, 1, 0], 1).invoke()

    