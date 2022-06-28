# Ogame-Cairo

_Ogame logic implementation written in Cairo for Starknet._

## What is ogame

OGame is a browser-based, money-management and space-war themed massively multiplayer online browser game with over two million accounts. OGame was created in 2002 and is produced and maintained by Gameforge. Players can have multiple planet, a fleet and attack each other to steal resources.

[Game Docs](https://www.notion.so/Ogame-Cairo-POC-spec-c11b0b44cb2e437889702b10a70b093a)

## Roadmap

1. Account can create a planet and upgrade mines. Only mines are available. :heavy_check_mark:
2. Integration of ERC721: planets will be NFTs. :heavy_check_mark:
3. Integration of ERC20: resources will be tokenized. :heavy_check_mark:
4. Add energy production requirements for mines. :heavy_check_mark:
5. Add time constraints for buildings upgrades. :heavy_check_mark:
6. Implementation of Robot Factory. :heavy_check_mark:
7. Add research lab.
8. Add technologies.
9. Allow creation of colonies.
10. Implement logic for space travel between planets.
11. Implementation of basic ships:

-   Small Cargo
-   Light Fighter

This will most likely keep me busy for a while. The rest of the roadmap is yet to be decided.

## Game Deployment Workflow

1. Deploy minter contract:

```sh
nile deploy erc721_minter --network goerli [owner.contract_address]
```

2. Deploy ERC721:

```sh
nile deploy --network goerli ERC721 0x4e6f47616d6520 0x4f474d302e31 [minter.contract_address] 54 105 112 102 115 58 47 47 81 109 102 88 118 50 72 116 67 114 106 56 66 70 98 56 87 122 55 82 101 56 76 106 49 88 99 87 114 78 71 57 81 115 119 115 87 119 66 122 82 77 76 122 101 53 47
```

3. On minter contract invoke setNftAddress with ERC721 as parameter.

4. Deploy main game contract:

```sh
nile deploy Ogame --network goerli [erc721.contract_address] [owner]
```

5. On minter invoke setNftApproval with Ogame.contract_address as operator.

6. Invoke mint_all function on erc721_minter contract with parameters n = 150 and token_id.low starting from 1. Minting more >= 200 planets in a single transaction triggers MAX NUMBER OF STEPS error from Starknet.

7. Deploy metal token:

```sh
nile deploy ERC20_Mintable --network goerli 0x6f67616d65206d6574616c2076302e31 0x4f674d455476302e31 18 0 0 [game.contract_address] [game.contract_addres]
```

8. Deploy crystal token:

```sh
nile deploy ERC20_Mintable --network goerli 0x6f67616d65206372797374616c2076302e31 0x4f6743525976302e31 18 0 0 [game.contract_address] [game.contract_addres]
```

9. Deploy deuterium token

```sh
nile deploy ERC20_Mintable --network goerli 0x6f67616d652064657574657269756d2076302e31 0x4f6744455576302e31 18 0 0 [game.contract_address] [game.contract_addres]
```

10. Invoke erc20_addresses on Ogame contract with resources token addresses as params.
