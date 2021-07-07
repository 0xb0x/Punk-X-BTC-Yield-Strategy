# Punk-X-BTC-Yield-Strategy
Yield strategy for ERC20 based BTC on [punk.finance](https://punk.finance) protocol

## Strategy

This strategy deposits WBTC into Farm WBTC vault and recieves fWBTC tokens which is then staked in the WBTC reward pool in [harvest-finance](https://harvest.finance) to earn yield in the form of farm tokens. The farm tokens earned are periodically swapped for WBTC and re-invested. :notes: *put it on repeat aan aan*

## Setup

- Install dependencies - `npm i`

- Create `.env` in root directory

- Add env variables 
```
MNEMONIC=
ALCHEMY_API_KEY=

```

## Deployment

```

# To deploy `HarvestModel.sol` to forked mainnet.
run - npx hardhat run --network hardhat scripts/deploy.js

```

### Mainnet Contracts

WBTC Reward pool - `0x917d6480Ec60cBddd6CbD0C8EA317Bcc709EA77B`
Harvest WBTC Vault - `0xc07EB91961662D275E2D285BdC21885A4Db136B0`
Farm Token - `0xa0246c9032bC3A600820415aE600c6388619A14D`
WBTC - `0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599`
#Deposit reciept of WBTC token
fWBTC - `0x5d9d25c7C457dD82fc8668FFC6B9746b674d4EcB`
UniswapV2Router02 - `0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D`


## Note

Deployed Harvest contract addresses can be found here - [Harvest-Contracts](https://farm.chainwiki.dev/en/contracts)

## Todo
