import pytest
from utils.helpers import (
    assert_equals,
    update_starknet_block,
    TIME_ELAPS_ONE_HOUR,
    TIME_ELAPS_SIX_HOURS,
)
from conftest import owner, user1


@pytest.mark.asyncio
async def test_collect_resources(minter, admin, game, user_one):

    await user1.send_transaction(
        user_one, game.contract_address, "solar_plant_upgrade_start", []
    )
    await user1.send_transaction(
        user_one, game.contract_address, "solar_plant_upgrade_complete", []
    )
