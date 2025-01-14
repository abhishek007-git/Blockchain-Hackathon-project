// scripts/mint-nft.js 
// ... (other imports and code)

const MARKETPLACE_ADDRESS = "YOUR_DEPLOYED_MARKETPLACE_ADDRESS";

// ... (inside the main function)

const tx = await artNFT.safeMint(
  deployer.address, 
  tokenURI, 
  name, 
  description, 
  imageURL
);
await tx.wait();

// Approve marketplace to transfer this token
await artNFT.approveMarketplace(MARKETPLACE_ADDRESS, tokenId); 

console.log("NFT minted to:", deployer.address);
// ... 
