%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.starknet.common.syscalls import get_caller_address
from contracts.token.erc721.interfaces.IERC721 import IERC721

@storage_var
func erc721_address() -> (address : felt):
end

@storage_var
func erc721_owner() -> (address : felt):
end

# @args: address -> the erc721 address, owner -> the token contract owner
@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(address : felt, owner : felt):
    erc721_owner.write(owner)
    erc721_address.write(address)
    return()
end

@external
func mint_all{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(n : felt, token_id : Uint256):
    alloc_locals
    let (owner) = erc721_owner.read()
    let (erc721) = erc721_address.read()
    if n == 0:
        return()
    end
    let (next_id, _) = uint256_add(token_id, Uint256(1,0))
    mint_all(n-1, next_id)
    IERC721.mint(erc721, owner, token_id)
    return()
end
