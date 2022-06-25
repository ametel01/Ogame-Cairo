import pytest
from utils.helpers import assert_equals
from conftest import owner


@pytest.mark.asyncio
async def test_mint_NFTs(deploy_game_v1, admin):
    (minter, ogame, erc721, _, _, _, _) = deploy_game_v1

    # Assert mint contract NFT balance is equal 199.
    data = await owner.send_transaction(
        admin, erc721.contract_address, "balanceOf", [minter.contract_address]
    )
    assert_equals(data.result.response[0] / 10**18, 200.0)

    # Assert that the game received approval.
    data = await owner.send_transaction(
        admin,
        erc721.contract_address,
        "isApprovedForAll",
        [minter.contract_address, ogame.contract_address],
    )
    assert_equals(data.result.response[0], 1)
