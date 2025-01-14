// contracts/ArtNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 

contract ArtNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Art NFT", "ART") {}

    // Optional: Store additional art metadata
    struct ArtMetadata {
        string name;
        string description;
        string imageURL; 
    }

    mapping (uint256 => ArtMetadata) public tokenMetadata; 

    // Mapping from token ID to approved address for marketplace
    mapping (uint256 => address) public marketplaceApprovals;

    function safeMint(address to, string memory uri, string memory _name, string memory _description, string memory _imageURL) public onlyOwner { 
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        tokenMetadata[tokenId] = ArtMetadata(_name, _description, _imageURL); 
    }

    // Approve the marketplace to transfer a specific token
    function approveMarketplace(address marketplace, uint256 tokenId) public {
        require(msg.sender == ownerOf(tokenId), "Only the owner can approve");
        marketplaceApprovals[tokenId] = marketplace;
    }

    // Allow the approved marketplace to transfer the token from the seller to the buyer
    function transferFrom(address from, address to, uint256 tokenId) public override { 
        require(_isApprovedOrOperator(from, msg.sender) || 
                msg.sender == marketplaceApprovals[tokenId], "Not authorized to transfer"); 
        
        super.transferFrom(from, to, tokenId); // Call the original transferFrom function

        // Reset marketplace approval after transfer
        delete marketplaceApprovals[tokenId]; 
    }
}


contract FractionalArtNFT is ERC721, Ownable {
    // ... (Your existing ArtNFT code)

    struct FractionalNFT {
        uint256 tokenId;
        address owner;
        ERC20 fractionalToken;
        uint256 totalFractions; // Total fractional tokens minted for this NFT
    }

    mapping(uint256 => FractionalNFT) public fractionalNFTs;

    // Event emitted when an NFT is fractionalized
    event NFTFractionalized(uint256 tokenId, address fractionalToken);

    function fractionalize(uint256 _tokenId, string memory _tokenName, string memory _tokenSymbol, uint256 _totalFractions) public {
        require(msg.sender == ownerOf(_tokenId), "Only the NFT owner can fractionalize");
        require(fractionalNFTs[_tokenId].fractionalToken == address(0), "NFT is already fractionalized");

        // Create an ERC20 contract to represent fractional ownership
        ERC20 fractionalToken = new ERC20(_tokenName, _tokenSymbol);
        // Mint initial supply to the NFT owner (can be adjusted based on your needs)
        fractionalToken.mint(msg.sender, _totalFractions);

        // Store the fractional NFT details
        fractionalNFTs[_tokenId] = FractionalNFT(_tokenId, msg.sender, fractionalToken, _totalFractions);

        // Emit the event
        emit NFTFractionalized(_tokenId, address(fractionalToken));
    }
}
