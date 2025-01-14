// scripts/deploy-marketplace.js
const hre = require("hardhat");

async function main() {
  const ART_NFT_CONTRACT_ADDRESS = "YOUR_DEPLOYED_ARTNFT_CONTRACT_ADDRESS";

  const NFTMarketplace = await hre.ethers.getContractFactory("NFTMarketplace");
  const nftMarketplace = await NFTMarketplace.deploy(ART_NFT_CONTRACT_ADDRESS);

  await nftMarketplace.deployed();

  console.log("NFTMarketplace deployed to:", nftMarketplace.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
