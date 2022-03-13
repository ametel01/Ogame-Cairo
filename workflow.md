# Game Deployment Workflow

1. Deploy minter contract:
```nile deploy erc721_minter --network goerli```

2. Deploy ERC721:
```nile deploy --network goerli ERC721 791039710910145679710511411110 79717710 [minter.contract_address] 3 2816098579549735819157383278158273522421215323109110700804876579202095 727713669677773499424935395146774672965422722660995087308605307047208038 167058432561934416655812751101829711222203357542195```

3. On minter contract invoke setNftAddress with ERC721 as parameter.

4. Deploy main game contract: 
```nile deploy PlanetFactory --network goerli [erc721.contract_address] [owner]```

5. On minter invoke setNftApproval with PlanetFactory as operator.

6. Invoke mint_all function on erc721_minter contract with parameters n = 150 and token_id.low starting from 1. Minting more >= 200 planets in a single transaction triggers MAX NUMBER OF STEPS error from Starknet.

7. Deploy metal token:
```nile deploy ERC20_Mintable --network goerli 469853561196 22314920797099084 0 340282366920938463463374607431768211455 0 [game.contract_address] [owner.contract_address]```

8. Deploy crystal token:
```nile deploy ERC20_Mintable --network goerli 27991888647971180 5712619723889529932 0 340282366920938463463374607431768211455 0 [game.contract_address] [owner.contract_address]```

9. Deploy deuterium token
```nile deploy ERC20_Mintable --network goerli 1851985284920121062765 22314920796505429 0 340282366920938463463374607431768211455 0 [game.contract_address] [owner.contract_address]```

10. Invoke erc20_addresses on PlanetFactory with resources token addresses as params.
