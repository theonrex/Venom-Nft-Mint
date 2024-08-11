# VenomMeme NFT Contract

## Overview

The **VenomMeme** smart contract is an ERC721-based non-fungible token (NFT) collection with royalty support, built on Solidity using OpenZeppelin libraries. This contract includes features like pausable minting, royalty distribution, and minting tracking.

## Features

- **ERC721 Compliance:** The contract implements `ERC721Enumerable`, providing standard NFT functionality with enumeration support.
- **Royalty Support:** Implements the `ERC721Royalty` extension and `IERC2981` interface, allowing automatic royalty distribution to a designated receiver.
- **Pausable Minting:** The contract owner can pause or resume minting in case of an emergency.
- **Minting Tracking:** Minting timestamps are recorded for each token to track when they were created.
- **Customizable Supply:** The total supply of NFTs can be set and adjusted by the contract owner, within certain constraints.

## Constructor Parameters

- `string memory baseURI`: The base URI for the NFT metadata.
- `address _receiver`: The address that will receive the royalties.
- `uint8 royaltyFeePercentage`: The percentage of each sale that will be distributed as a royalty.
- `uint256 totalNFTs`: The total supply of NFTs that can be minted.

## Key Functions

- **`mint(uint256 quantity)`**: Mints a specified number of NFTs to the caller's address. Requires payment of a fixed price per NFT.
- **`setPaused(bool val)`**: Allows the owner to pause or unpause the contract.
- **`setPrice(uint256 newPrice)`**: Allows the owner to change the price of minting an NFT.
- **`setTotalNFTs(uint256 totalNFTs)`**: Allows the owner to adjust the total supply of NFTs, as long as it does not drop below the current number of minted NFTs.
- **`getMintTimestamp(uint256 tokenId)`**: Retrieves the timestamp when the specified token was minted.
- **`royaltyInfo(uint256 tokenId, uint256 salePrice)`**: Returns the royalty receiver address and the royalty amount for a given sale price.

## Deployment

- **Solidity Version:** 0.8.17
- **Dependencies:** OpenZeppelin Contracts

## Installation

To deploy and interact with this contract, you'll need to install the following dependencies:

```bash
npm install @openzeppelin/contracts
