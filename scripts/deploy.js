
const hre = require("hardhat");

async function main() {

  // mainnet contracts for harvest finance
  WBTC_Reward_pool = '0x917d6480Ec60cBddd6CbD0C8EA317Bcc709EA77B'
  Harvest_WBTC_Vault = '0xc07EB91961662D275E2D285BdC21885A4Db136B0'
  Farm_Token = '0xa0246c9032bC3A600820415aE600c6388619A14D'
  WBTC = '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599'
  fWBTC = '0x5d9d25c7C457dD82fc8668FFC6B9746b674d4EcB'
  UniswapV2Router02 = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'

  const [forge] = await ethers.getSigners();

  // We get the contract to deploy
  const HarvestModel = await hre.ethers.getContractFactory("HarvestModel");
  const harvestModel = await HarvestModel.deploy();

  await harvestModel.deployed();

  console.log("Harvest Model deployed to:", harvestModel.address);

  await harvestModel.initialize(
    forge.address,
    WBTC,
    fWBTC,
    Farm_Token,
    Harvest_WBTC_Vault,
    WBTC_Reward_pool,
    UniswapV2Router02
  )

  console.log(await harvestModel.invest())

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
