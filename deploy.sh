#!/bin/bash
# Ogame deployment script

export STARKNET_NETWORK=alpha-goerli
export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount
export OA="0x01f8bff995a60a3bdf917e7367020748ad87e9a670b231b483948f67890d2685"
echo Setting OA to $OA...
echo -e "\n"
echo Deployng Minter contract..
nile deploy erc721_minter --network goerli ${OA}
echo -e "\n"
echo Deployng NFT contract...

