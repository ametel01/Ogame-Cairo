import pytest
from utils.helpers import assert_equals
from starkware.starknet.testing.contract import StarknetContract
from conftest import (admin, erc721, game, owner, user1, user_one)


@pytest.mark.asyncio
async def test_account(deploy_game_v1):
    (_, game, erc721, _, _, _, user_one) = deploy_game_v1
    data = await user1.send_transaction(user_one,
                                        erc721.contract_address,
                                        'ownerOf',
                                        [1, 0])
    assert_equals(data.result.response[0], user_one.contract_address)
