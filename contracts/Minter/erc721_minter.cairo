%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add

from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from contracts.Tokens.erc721.interfaces.IERC721 import IERC721

@storage_var
func erc721_address() -> (address : felt):
end

@storage_var
func erc721_owner() -> (address : felt):
end

@storage_var
func admim() -> (address : felt):
end

# @args: address -> the erc721 address, owner -> the token contract owner
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    erc721_owner.write(admin_address)
    admim.write(admin_address)
    return ()
end

@external
func setNFTaddress{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
):
    let (caller) = get_caller_address()
    let (admin) = admim.read()
    assert caller = admin
    erc721_address.write(address)
    return ()
end

@external
func setNFTapproval{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    operator : felt, approved : felt
):
    let (caller) = get_caller_address()
    let (admin) = admim.read()
    assert caller = admin
    let (erc721) = erc721_address.read()
    IERC721.setApprovalForAll(erc721, operator, approved)
    return ()
end

@external
func mintAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    n : felt, token_id : Uint256
):
    alloc_locals
    let (owner) = erc721_owner.read()
    let (erc721) = erc721_address.read()
    if n == 0:
        return ()
    end
    let (minter_address) = get_contract_address()
    let (next_id, _) = uint256_add(token_id, Uint256(1, 0))
    mintAll(n - 1, next_id)
    IERC721.mint(erc721, minter_address, token_id)
    return ()
end
