"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet

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

    await contract.generate_planet(6465).invoke()
    data = await contract.number_of_planets().call()
    assert data.result.n_planets == 1

    await contract.generate_planet(6465).invoke()
    data = await contract.number_of_planets().call()
    assert data.result.n_planets == 2
