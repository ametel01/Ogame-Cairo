import pytest
from utils.helpers import assert_equals
from starkware.starknet.compiler.compile import get_selector_from_name


@pytest.mark.asyncio
async def test_mint_NFTs(deploy_game_v1, minter_factory):
    (ogame, erc721, _, _, _, admin, _) = deploy_game_v1
    minter = minter_factory

    # Submit NFT contract address to minter.
    await admin.execute(minter.contract_address,
                        get_selector_from_name('setNFTaddress'),
                        [erc721.contract_address], 0).invoke()

    # Mint 200 NFTs and assign them to minter.
    await admin.execute(minter.contract_address,
                        get_selector_from_name('mintAll'),
                        [200, 1, 0], 1).invoke()

    # Assert minte contract NFT balance is equal 200.
    data = await admin.execute(erc721.contract_address,
                               get_selector_from_name('balanceOf'),
                               [minter.contract_address], 2).invoke()
    assert_equals(data.result.response[0], 200)

    # Assert admin can give game contract approval on NFT transfer.
    await admin.execute(minter.contract_address,
                        get_selector_from_name('setNFTapproval'),
                        [ogame.contract_address, 1], 3).invoke()
    data = await admin.execute(erc721.contract_address,
                               get_selector_from_name('isApprovedForAll'),
                               [minter.contract_address, ogame.contract_address], 4).invoke()
    assert_equals(data.result.response[0], 1)
