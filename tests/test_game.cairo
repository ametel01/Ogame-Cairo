%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from pytest_cairo.contract_index import contracts
from pytest_cairo.helpers import deploy_contract, impersonate, set_block_timestamp

from contracts.interfaces.IOgame import IOgame
from contracts.minter.interfaces.Ierc721_minter import Ierc721_minter
from contracts.token.erc20.interfaces.IERC20 import IERC20
from contracts.token.erc721.interfaces.IERC721 import IERC721

const ADMIN_ADDRESS = 1
const USER_1_ADDRESS = 2
const USER_2_ADDRESS = 3

const MAX_UINT = 2 ** 128 - 1  # conftest.MAX_UINT
const TIME_ELAPS_ONE_HOUR = 3600  # conftest.TIME_ELAPS_ONE_HOUR
const TIME_ELAPS_SIX_HOURS = 21600  # conftest.TIME_ELAPS_SIX_HOURS

@external
func test_game{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # deploy_game_v1 fixture

    impersonate(ADMIN_ADDRESS)

    let (calldata : felt*) = alloc()
    assert calldata[0] = ADMIN_ADDRESS
    let (minter_address) = deploy_contract(contracts.minter.erc721_minter, 1, calldata)

    let (calldata : felt*) = alloc()
    assert calldata[0] = 79717795807684
    assert calldata[1] = 79717795807684
    assert calldata[2] = minter_address
    assert calldata[3] = 3
    assert calldata[4] = 184555836509371486644298270517380613565396767415278678887948391494588501258
    assert calldata[5] = 184555836509371486644298270517380613565396767415278678887948391494588501258
    assert calldata[6] = 2511981064129509550770777692765514099620440566643524046090
    let (erc721_address) = deploy_contract(contracts.token.erc721.ERC721, 7, calldata)

    let (calldata : felt*) = alloc()
    assert calldata[0] = erc721_address
    assert calldata[1] = ADMIN_ADDRESS
    let (game_address) = deploy_contract(contracts.Ogame, 2, calldata)

    Ierc721_minter.setNFTaddress(minter_address, erc721_address)
    Ierc721_minter.setNFTapproval(minter_address, game_address, 1)

    let token_id = Uint256(1, 0)
    Ierc721_minter.mintAll(minter_address, 200, token_id)

    let (calldata : felt*) = alloc()
    assert calldata[0] = 469853561196
    assert calldata[1] = 22314920797099084
    assert calldata[2] = 0
    assert calldata[3] = 0
    assert calldata[4] = 0
    assert calldata[5] = game_address
    assert calldata[6] = game_address
    let (metal_adress) = deploy_contract(contracts.token.erc20.ERC20_Mintable, 7, calldata)

    let (calldata : felt*) = alloc()
    assert calldata[0] = 27991888647971180
    assert calldata[1] = 5712619723889529932
    assert calldata[2] = 0
    assert calldata[3] = 0
    assert calldata[4] = 0
    assert calldata[5] = game_address
    assert calldata[6] = game_address
    let (crystal_adress) = deploy_contract(contracts.token.erc20.ERC20_Mintable, 7, calldata)

    let (calldata : felt*) = alloc()
    assert calldata[0] = 1851985284920121062765
    assert calldata[1] = 22314920796505429
    assert calldata[2] = 0
    assert calldata[3] = 0
    assert calldata[4] = 0
    assert calldata[5] = game_address
    assert calldata[6] = game_address
    let (deuterium_adress) = deploy_contract(contracts.token.erc20.ERC20_Mintable, 7, calldata)

    IOgame.erc20_addresses(game_address, metal_adress, crystal_adress, deuterium_adress)

    impersonate(USER_1_ADDRESS)
    IOgame.generate_planet(game_address)

    # tests/test_game::test_account

    let token_id = Uint256(1, 0)
    let (actual_a) = IERC721.ownerOf(erc721_address, token_id)
    assert actual_a = USER_1_ADDRESS

    let (actual_b) = IERC721.balanceOf(erc721_address, USER_1_ADDRESS)
    let expected = Uint256(1, 0)
    assert actual_b = expected

    let (actual_c) = IERC20.balanceOf(metal_adress, USER_1_ADDRESS)
    let expected = Uint256(5000, 0)
    assert actual_c = expected

    let (actual_d) = IERC20.balanceOf(crystal_adress, USER_1_ADDRESS)
    let expected = Uint256(3000, 0)
    assert actual_d = expected

    let (actual_e) = IERC20.balanceOf(deuterium_adress, USER_1_ADDRESS)
    let expected = Uint256(1000, 0)
    assert actual_e = expected

    # tests/test_game::test_collect_resources

    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2)

    IOgame.collect_resources(game_address)

    let actual_f = IOgame.resources_available(game_address, USER_1_ADDRESS)
    assert actual_f.metal = 696
    assert actual_f.crystal = 431
    assert actual_f.deuterium = 164
    assert actual_f.energy = 0

    let (actual_g) = IERC20.balanceOf(metal_adress, USER_1_ADDRESS)
    let expected = Uint256(6960, 0)
    assert actual_g = expected

    let (actual_h) = IERC20.balanceOf(crystal_adress, USER_1_ADDRESS)
    let expected = Uint256(4310, 0)
    assert actual_h = expected

    let (actual_i) = IERC20.balanceOf(deuterium_adress, USER_1_ADDRESS)
    let expected = Uint256(1640, 0)
    assert actual_i = expected

    # tests/test_game::test_structures_upgrades

    let actual_j = IOgame.get_structures_levels(game_address, USER_1_ADDRESS)
    assert actual_j.metal_mine = 1
    assert actual_j.crystal_mine = 1
    assert actual_j.deuterium_mine = 1
    assert actual_j.solar_plant = 1
    assert actual_j.robot_factory = 0

    IOgame.solar_plant_upgrade_start(game_address)
    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR)
    IOgame.solar_plant_upgrade_complete(game_address)

    IOgame.solar_plant_upgrade_start(game_address)
    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR * 2)
    IOgame.solar_plant_upgrade_complete(game_address)

    IOgame.solar_plant_upgrade_start(game_address)
    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR * 3)
    IOgame.solar_plant_upgrade_complete(game_address)

    IOgame.collect_resources(game_address)

    let actual_k = IOgame.get_structures_levels(game_address, USER_1_ADDRESS)
    assert actual_k.metal_mine = 1
    assert actual_k.crystal_mine = 1
    assert actual_k.deuterium_mine = 1
    assert actual_k.solar_plant = 4
    assert actual_k.robot_factory = 0

    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR * 25)

    IOgame.collect_resources(game_address)
    let actual_l = IOgame.resources_available(game_address, USER_1_ADDRESS)
    assert actual_l.metal = 1018
    assert actual_l.crystal = 781
    assert actual_l.deuterium = 433
    assert actual_l.energy = 73

    IOgame.metal_upgrade_start(game_address)
    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR * 26)
    IOgame.metal_upgrade_complete(game_address)

    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR * 27)

    let actual_m = IOgame.get_structures_levels(game_address, USER_1_ADDRESS)
    assert actual_m.metal_mine = 2
    assert actual_m.crystal_mine = 1
    assert actual_m.deuterium_mine = 1
    assert actual_m.solar_plant = 4
    assert actual_m.robot_factory = 0

    IOgame.crystal_upgrade_start(game_address)
    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR * 28)
    IOgame.crystal_upgrade_complete(game_address)

    let actual_n = IOgame.get_structures_levels(game_address, USER_1_ADDRESS)
    assert actual_n.metal_mine = 2
    assert actual_n.crystal_mine = 2
    assert actual_n.deuterium_mine = 1
    assert actual_n.solar_plant = 4
    assert actual_n.robot_factory = 0

    IOgame.collect_resources(game_address)
    let actual_o = IOgame.resources_available(game_address, USER_1_ADDRESS)
    assert actual_o.metal = 1068
    assert actual_o.crystal = 864
    assert actual_o.deuterium = 465
    assert actual_o.energy = 47

    IOgame.robot_factory_upgrade_start(game_address)
    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR * 29)
    IOgame.robot_factory_upgrade_complete(game_address)

    let actual_p = IOgame.get_structures_levels(game_address, USER_1_ADDRESS)
    assert actual_p.metal_mine = 2
    assert actual_p.crystal_mine = 2
    assert actual_p.deuterium_mine = 1
    assert actual_p.solar_plant = 4
    assert actual_p.robot_factory = 1

    IOgame.deuterium_upgrade_start(game_address)
    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR * 30)
    IOgame.deuterium_upgrade_complete(game_address)

    let actual_q = IOgame.get_structures_levels(game_address, USER_1_ADDRESS)
    assert actual_q.metal_mine = 2
    assert actual_q.crystal_mine = 2
    assert actual_q.deuterium_mine = 2
    assert actual_q.solar_plant = 4
    assert actual_q.robot_factory = 1

    IOgame.metal_upgrade_start(game_address)
    set_block_timestamp(TIME_ELAPS_SIX_HOURS * 2 + TIME_ELAPS_ONE_HOUR * 31)
    IOgame.metal_upgrade_complete(game_address)

    let actual_r = IOgame.get_structures_levels(game_address, USER_1_ADDRESS)
    assert actual_r.metal_mine = 3
    assert actual_r.crystal_mine = 2
    assert actual_r.deuterium_mine = 2
    assert actual_r.solar_plant = 4
    assert actual_r.robot_factory = 1

    IOgame.collect_resources(game_address)
    let actual_o = IOgame.resources_available(game_address, USER_1_ADDRESS)
    assert actual_o.metal = 552
    assert actual_o.crystal = 742
    assert actual_o.deuterium = 336
    assert actual_o.energy = 6

    return ()
end
