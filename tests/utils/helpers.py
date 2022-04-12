import pytest
from starkware.starknet.business_logic.state import BlockInfo

TIME_ELAPS_ONE_HOUR = 3600
TIME_ELAPS_SIX_HOURS = 21600
UINT_DECIMALS = 10**18


def assert_equals(a, b):
    assert a == b


def update_starknet_block(starknet, block_number=1, block_timestamp=TIME_ELAPS_ONE_HOUR):
    starknet.state.state.block_info = BlockInfo(
        block_number=block_number, block_timestamp=block_timestamp)


def reset_starknet_block(starknet):
    update_starknet_block(starknet=starknet)

def get_block_timestamp(starknet_state):
    return starknet_state.state.block_info.block_timestamp
