import pytest
from conftest import owner, user1


@pytest.mark.asyncio
async def test_single_ownership(erc721_2, admin, user_one):
    await owner.send_transaction(
        admin,
        erc721_2.contract_address,
        "mint",
        [admin.contract_address, 1, 0],
    )
    await owner.send_transaction(
        admin,
        erc721_2.contract_address,
        "mint",
        [admin.contract_address, 2, 0],
    )
    await owner.send_transaction(
        admin,
        erc721_2.contract_address,
        "transferFrom",
        [admin.contract_address, user_one.contract_address, 1, 0],
    )
    await owner.send_transaction(
        admin,
        erc721_2.contract_address,
        "transferFrom",
        [admin.contract_address, user_one.contract_address, 2, 0],
    )
