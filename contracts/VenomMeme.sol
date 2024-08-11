// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";

contract VenomMeme is
    Ownable,
    ReentrancyGuard,
    ERC721Royalty,
    ERC721Enumerable
{
    using Strings for uint256;
    /**
     * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`.
     */
    string _baseTokenURI;
    //  _price is the price of one Satoshi NFT
    uint256 public _price = 0.005 ether;
    // _paused is used to pause the contract in case of an emergency
    bool public _paused;
    // Variable to store the total number of NFTs
    uint256 private _totalNFTs;
    // total number of tokenIds minted
    uint256 public tokenIds;

    // Royalty variables
    uint8 public royaltyFee;
    address public royaltyReceiver;
    // Mapping to store mint timestamps

    mapping(uint256 => uint256) public mintTimestamps;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }
    event NFTMinted(
        uint256 indexed tokenId,
        address indexed recipient,
        uint256 salePrice
    );

    /**
     * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
     * name in our case is `Satoshis` and symbol is `CD`.
     * Constructor for Satoshis takes in the baseURI to set _baseTokenURI for the collection.
     */

    constructor(
        string memory baseURI,
        address _receiver,
        uint8 royaltyFeePercentage,
        uint256 totalNFTs
    ) ERC721("MX Satoshi", "MPS") {
        _baseTokenURI = baseURI;
        royaltyReceiver = _receiver;
        royaltyFee = royaltyFeePercentage;
        _totalNFTs = totalNFTs;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // needs to be unlocked for the `_mint()` function in constructor
    bool locked = false;

    function mint(
        uint256 quantity
    ) public payable onlyWhenNotPaused nonReentrant {
        require(quantity > 0, "Quantity must be greater than 0");
        require(msg.value >= _price * quantity, "Ether sent is not correct");

        uint256 totalPayment = msg.value;
        uint256 totalRoyalty = (totalPayment * royaltyFee) / 100;

        for (uint256 i = 0; i < quantity; i++) {
            tokenIds += 1;
            require(tokenIds <= _totalNFTs, "Exceeds maximum NFTs available");

            mintTimestamps[tokenIds] = block.timestamp;
            _safeMint(msg.sender, tokenIds);
            _setTokenRoyalty(tokenIds, royaltyReceiver, royaltyFee);

            emit NFTMinted(tokenIds, msg.sender, _price);
        }

        payable(royaltyReceiver).transfer(totalRoyalty);
        payable(owner()).transfer(totalPayment - totalRoyalty);
    }

    function getTotalMinted() external view returns (uint256) {
        return tokenIds;
    }

    function getTotalNFTs() external view returns (uint256) {
        return _totalNFTs;
    }

    function setTotalNFTs(uint256 totalNFTs) external onlyOwner {
        require(
            totalNFTs >= tokenIds,
            "Cannot set total NFTs less than minted count"
        );
        _totalNFTs = totalNFTs;
    }

    // Royalty functions

    function setRoyaltyFee(uint8 _royaltyFee) external onlyOwner {
        royaltyFee = _royaltyFee;
    }

    function setRoyaltyReceiver(address _royaltyReceiver) external onlyOwner {
        royaltyReceiver = _royaltyReceiver;
    }

    /**
     * @dev _baseURI overrides the Openzeppelin's ERC721 implementation which by default
     * returned an empty string for the baseURI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function getBaseURI() external view returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev tokenURI overrides the Openzeppelin's ERC721 implementation for tokenURI function
     * This function returns the URI from where we can extract the metadata for a given tokenId
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            ownerOf(tokenId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        // Here it checks if the length of the baseURI is greater than 0, if it is return the baseURI and attach
        // the tokenId and `.json` to it so that it knows the location of the metadata json file for a given
        // tokenId stored on IPFS
        // If baseURI is empty return an empty string
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    /**
     * @dev setPaused makes the contract paused or unpaused
     */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    // Price-related functions
    function setPrice(uint256 newPrice) external onlyOwner {
        _price = newPrice;
    }

    function getPrice() external view returns (uint256) {
        return _price;
    }

    function getMintingInfo(
        address wallet
    ) external view returns (uint256[] memory mintedTokens) {
        uint256 mintedCount = 0;
        for (uint256 i = 1; i <= tokenIds; i++) {
            if (_exists(i) && ownerOf(i) == wallet) {
                mintedCount++;
            }
        }

        mintedTokens = new uint256[](mintedCount);
        uint256 index = 0;
        for (uint256 i = 1; i <= tokenIds; i++) {
            if (_exists(i) && ownerOf(i) == wallet) {
                mintedTokens[index] = i;
                index++;
            }
        }
    }

    // Transfer ownership function with override specifier
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        _transferOwnership(newOwner);
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) public view override returns (address, uint256) {
        uint256 royaltyFeeAmount = (salePrice * royaltyFee) / 100; // Calculate royalty amount
        return (royaltyReceiver, royaltyFeeAmount);
    }

    // Getter function to retrieve mint timestamp for a given token ID
    function getMintTimestamp(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Token ID does not exist");
        return mintTimestamps[tokenId];
    }
}
