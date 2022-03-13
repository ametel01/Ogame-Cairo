# Ogame-Cairo

_Ogame logic implementation written in Cairo for Starknet._

## What is ogame

OGame is a browser-based, money-management and space-war themed massively multiplayer online browser game with over two million accounts. OGame was created in 2002 and is produced and maintained by Gameforge. Players can have multiple planet, a fleet and attack each other to steal resources.

[Game Docs](https://www.notion.so/Ogame-Cairo-POC-spec-c11b0b44cb2e437889702b10a70b093a)


## Roadmap

1. Account can create a planet and upgrade mines. Only mines are available. :heavy_check_mark:
2. Integration of ERC721: planets will be NFTs. :heavy_check_mark:
3. Integration of ERC20: resources will be tokenized. :heavy_check_mark:
4. Add energy production requirements for mines.
5. Add time constraints for buildings upgrades.
6. Add energy requirements for energy production.
6. Add research lab.
7. Add technologies.
8. Implementation of basic facilities:
   - Shipyard
   - Robot Factory
9. Allow creation of colonies.
10. Implement logic for space travel between planets.
11. Implementation of basic ships:
   - Small Cargo
   - Light Fighter

This will most likely keep me busy for a while. The rest of the roadmap is yet to be decided.

## Game Deployment Workflow

1. Deploy minter contract:
```sh
nile deploy erc721_minter --network goerli
```

2. Deploy ERC721:
```sh
nile deploy --network goerli ERC721 791039710910145679710511411110 79717710 [minter.contract_address] 3 2816098579549735819157383278158273522421215323109110700804876579202095 727713669677773499424935395146774672965422722660995087308605307047208038 167058432561934416655812751101829711222203357542195
```

3. On minter contract invoke setNftAddress with ERC721 as parameter.

4. Deploy main game contract: 
```sh
nile deploy PlanetFactory --network goerli [erc721.contract_address] [owner]
```

5. On minter invoke setNftApproval with PlanetFactory as operator.

6. Invoke mint_all function on erc721_minter contract with parameters n = 150 and token_id.low starting from 1. Minting more >= 200 planets in a single transaction triggers MAX NUMBER OF STEPS error from Starknet.

7. Deploy metal token:
```sh
nile deploy ERC20_Mintable --network goerli 469853561196 22314920797099084 0 340282366920938463463374607431768211455 0 [game.contract_address] [owner.contract_address]
```

8. Deploy crystal token:
```sh
nile deploy ERC20_Mintable --network goerli 27991888647971180 5712619723889529932 0 340282366920938463463374607431768211455 0 [game.contract_address] [owner.contract_address]
```

9. Deploy deuterium token
```sh
nile deploy ERC20_Mintable --network goerli 1851985284920121062765 22314920796505429 0 340282366920938463463374607431768211455 0 [game.contract_address] [owner.contract_address]
```

10. Invoke erc20_addresses on PlanetFactory with resources token addresses as params.

