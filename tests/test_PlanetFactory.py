"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.business_logic.state import BlockInfo

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "PlanetFactory.cairo")


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_generate_planet():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    await contract.generate_planet().invoke()
    assert (await contract.number_of_planets().call()) = 1
    assert data.result.n_planets == 1

    await contract.generate_planet().invoke()
    assert (await contract.number_of_planets().call()) == 2

    data = await contract.get_planet(1).call()
    assert data.result.planet.metal_mine == 1
    assert data.result.planet.crystal_mine == 1
    assert data.result.planet.deuterium_mine == 1

    starknet.state.state.block_info = BlockInfo(1, 10)
    data = await contract.calculate_metal_production().invoke()
    assert data == 3
