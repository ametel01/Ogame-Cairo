import pytest
from utils.helpers import assert_equals
from starkware.starknet.compiler.compile import get_selector_from_name
from conftest import owner


@pytest.mark.asyncio
async def test_mint_NFTs(deploy_game_v1, minter_factory):
    (ogame, erc721, _, _, _, admin, _) = deploy_game_v1
    minter = minter_factory

    # Assert minte contract NFT balance is equal 199.
    data = await admin.execute(1, erc721.contract_address,
                               get_selector_from_name('balanceOf'),
                               [minter.contract_address], 4).invoke()
    assert_equals(data.result.response[0], 199)

    # Assert that the game received approval.
    data = await admin.execute(erc721.contract_address,
                               get_selector_from_name('isApprovedForAll'),
                               [minter.contract_address, ogame.contract_address], 5).invoke()
    assert_equals(data.result.response[0], 1)
