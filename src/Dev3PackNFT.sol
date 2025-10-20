// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

/**
 * @title Dev3PackNFT
 * @author Your Name
 * @notice A cool NFT contract for the Dev3pack Bootcamp
 * @dev This contract demonstrates advanced Solidity features
 */
contract Dev3PackNFT {
    // State variables
    uint256 public totalSupply;
    uint256 public maxSupply = 1000;
    uint256 public mintPrice = 0.01 ether;
    
    address public owner;
    bool public mintingActive = true;
    
    // Events
    event NFTMinted(address indexed to, uint256 indexed tokenId, string tokenURI);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MintingToggled(bool active);
    
    // Structs
    struct NFTData {
        uint256 tokenId;
        string tokenURI;
        address owner;
        uint256 mintedAt;
    }
    
    // Mappings
    mapping(uint256 => NFTData) public nfts;
    mapping(address => uint256[]) public ownerTokens;
    mapping(string => bool) public usedURIs;
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier mintingIsActive() {
        require(mintingActive, "Minting is not active");
        _;
    }
    
    modifier validTokenId(uint256 _tokenId) {
        require(_tokenId > 0 && _tokenId <= totalSupply, "Invalid token ID");
        _;
    }
    
    // Constructor
    constructor() {
        owner = msg.sender;
        console.log("Dev3PackNFT contract deployed by:", msg.sender);
    }
    
    /**
     * @notice Mint a new NFT
     * @param _tokenURI The metadata URI for the NFT
     */
    function mintNFT(string memory _tokenURI) external payable mintingIsActive {
        require(totalSupply < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment");
        require(!usedURIs[_tokenURI], "URI already used");
        require(bytes(_tokenURI).length > 0, "URI cannot be empty");
        
        totalSupply++;
        uint256 tokenId = totalSupply;
        
        nfts[tokenId] = NFTData({
            tokenId: tokenId,
            tokenURI: _tokenURI,
            owner: msg.sender,
            mintedAt: block.timestamp
        });
        
        ownerTokens[msg.sender].push(tokenId);
        usedURIs[_tokenURI] = true;
        
        emit NFTMinted(msg.sender, tokenId, _tokenURI);
        console.log("NFT minted:", tokenId, "to:", msg.sender);
    }
    
    /**
     * @notice Get NFT data by token ID
     * @param _tokenId The token ID to query
     * @return NFTData The NFT data struct
     */
    function getNFT(uint256 _tokenId) external view validTokenId(_tokenId) returns (NFTData memory) {
        return nfts[_tokenId];
    }
    
    /**
     * @notice Get all tokens owned by an address
     * @param _owner The address to query
     * @return Array of token IDs owned by the address
     */
    function getTokensByOwner(address _owner) external view returns (uint256[] memory) {
        return ownerTokens[_owner];
    }
    
    /**
     * @notice Get contract statistics
     * @return _totalSupply Current total supply
     * @return _maxSupply Maximum supply
     * @return _mintPrice Current mint price
     * @return _mintingActive Whether minting is active
     */
    function getStats() external view returns (
        uint256 _totalSupply,
        uint256 _maxSupply,
        uint256 _mintPrice,
        bool _mintingActive
    ) {
        return (totalSupply, maxSupply, mintPrice, mintingActive);
    }
    
    /**
     * @notice Toggle minting on/off (owner only)
     */
    function toggleMinting() external onlyOwner {
        mintingActive = !mintingActive;
        emit MintingToggled(mintingActive);
        console.log("Minting toggled to:", mintingActive);
    }
    
    /**
     * @notice Update mint price (owner only)
     * @param _newPrice The new mint price in wei
     */
    function updateMintPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "Price must be greater than 0");
        mintPrice = _newPrice;
        console.log("Mint price updated to:", _newPrice);
    }
    
    /**
     * @notice Withdraw contract balance (owner only)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdrawal failed");
        console.log("Withdrawn:", balance, "wei to owner");
    }
    
    /**
     * @notice Transfer ownership (owner only)
     * @param _newOwner The new owner address
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid new owner");
        address previousOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
        console.log("Ownership transferred from:", previousOwner, "to:", _newOwner);
    }
    
    /**
     * @notice Emergency function to pause contract
     */
    function emergencyPause() external onlyOwner {
        mintingActive = false;
        emit MintingToggled(false);
        console.log("Emergency pause activated");
    }
    
    // Fallback function to receive ETH
    receive() external payable {
        console.log("Received ETH:", msg.value);
    }
}
