import pytest
from utils.helpers import (
    assert_equals, update_starknet_block, TIME_ELAPS_ONE_HOUR, TIME_ELAPS_SIX_HOURS)
from conftest import owner

@pytest.mark.asyncio
async def test_collect_resources(minter, admin, game, erc721):

    await owner.send_transaction(admin,
                                 minter.contract_address,
                                 'setNFTaddress',
                                 [erc721.contract_address])

    await owner.send_transaction(admin,
                                 minter.contract_address,
                                 'setNFTapproval',
                                 [game.contract_address, 1])