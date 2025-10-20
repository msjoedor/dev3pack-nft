// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleNFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    uint256 public maxSupply = 1000;
    uint256 public mintPrice = 0.01 ether;
    bool public mintingActive = true;
    
    constructor() ERC721("SimpleNFT", "SNFT") Ownable(msg.sender) {}
    
    function mintNFT(string memory _tokenURI) external payable {
        require(mintingActive, "Minting is not active");
        require(msg.value >= mintPrice, "Insufficient payment");
        require(_nextTokenId < maxSupply, "Max supply reached");
        
        _nextTokenId++;
        uint256 tokenId = _nextTokenId;
        
        _safeMint(msg.sender, tokenId);
    }
    
    function getStats() external view returns (uint256, uint256, uint256, bool) {
        return (_nextTokenId, maxSupply, mintPrice, mintingActive);
    }
    
    function toggleMinting() external onlyOwner {
        mintingActive = !mintingActive;
    }
    
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
