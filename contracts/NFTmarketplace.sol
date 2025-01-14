// contracts/NFTMarketplace.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; 

contract NFTMarketplace {
    // Listing struct to store information about each listed NFT
    struct Listing {
        uint256 tokenId;
        address seller;
        uint256 price;
        bool isActive; // Indicates if the listing is active or not
    }

    // Event emitted when a new listing is created
    event ListingCreated(uint256 tokenId, address seller, uint256 price);
    // Event emitted when a listing is updated
    event ListingUpdated(uint256 tokenId, address seller, uint256 price);
    // Event emitted when a listing is canceled
    event ListingCanceled(uint256 tokenId, address seller);
    // Event emitted when a sale is executed
    event SaleExecuted(uint256 tokenId, address seller, address buyer, uint256 price);

    // Mapping from token ID to Listing
    mapping(uint256 => Listing) public listings; 

    // Reference to the deployed ArtNFT contract
    ERC721 public nftContract;

    // Constructor to initialize the marketplace with the ArtNFT contract address
    constructor(address _nftContractAddress) {
        nftContract = ERC721(_nftContractAddress);
    }

    // Allow an NFT owner to list their NFT for sale
    function listNFT(uint256 _tokenId, uint256 _price) public {
        require(nftContract.ownerOf(_tokenId) == msg.sender, "Only the NFT owner can list");
        require(_price > 0, "Price must be greater than zero");

        // Create a new listing and store it in the mapping
        listings[_tokenId] = Listing(_tokenId, msg.sender, _price, true);

        // Emit an event to signal the creation of a new listing
        emit ListingCreated(_tokenId, msg.sender, _price);
    }

    // Allow a seller to update the listing price
    function updateListingPrice(uint256 _tokenId, uint256 _newPrice) public {
        Listing storage listing = listings[_tokenId];

        // Ensure the listing exists and the caller is the seller
        require(listing.seller == msg.sender, "Only the seller can update the listing");
        // Ensure the new price is valid
        require(_newPrice > 0, "Price must be greater than zero");

        // Update the listing price
        listing.price = _newPrice;

        // Emit an event for listing update
        emit ListingUpdated(_tokenId, listing.seller, _newPrice);
    }

    // Allow a seller to cancel their listing
    function cancelListing(uint256 _tokenId) public {
        Listing storage listing = listings[_tokenId];

        // Ensure the listing exists and the caller is the seller
        require(listing.seller == msg.sender, "Only the seller can cancel the listing");

        // Mark the listing as inactive
        listing.isActive = false;

        // Emit an event for listing cancellation
        emit ListingCanceled(_tokenId, msg.sender);
    }

    // Allow a buyer to purchase a listed NFT
    function buyNFT(uint256 _tokenId) public payable {
        Listing storage listing = listings[_tokenId];

        // Ensure the listing exists and is active
        require(listing.isActive, "Listing is not active");

        // Ensure the buyer sends enough ETH
        require(msg.value == listing.price, "Incorrect ETH amount sent");

        // Transfer the NFT from the seller to the buyer
        nftContract.transferFrom(listing.seller, msg.sender, _tokenId); 

        // Transfer the ETH payment to the seller
        payable(listing.seller).transfer(msg.value);

        // Mark the listing as inactive after the sale
        listing.isActive = false;

        // Emit an event for successful sale
        emit SaleExecuted(_tokenId, listing.seller, msg.sender, msg.value);
    }
}
