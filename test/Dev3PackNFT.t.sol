// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Dev3PackNFT.sol";

contract Dev3PackNFTTest is Test {
    Dev3PackNFT public nft;
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    
    string public constant SAMPLE_URI = "https://dev3pack.com/nft/1";
    string public constant SAMPLE_URI_2 = "https://dev3pack.com/nft/2";
    
    function setUp() public {
        vm.prank(owner);
        nft = new Dev3PackNFT();
    }
    
    function testInitialState() public {
        assertEq(nft.owner(), owner);
        assertEq(nft.totalSupply(), 0);
        assertEq(nft.maxSupply(), 1000);
        assertEq(nft.mintPrice(), 0.01 ether);
        assertTrue(nft.mintingActive());
    }
    
    function testMintNFT() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        nft.mintNFT{value: 0.01 ether}(SAMPLE_URI);
        
        assertEq(nft.totalSupply(), 1);
        
        Dev3PackNFT.NFTData memory nftData = nft.getNFT(1);
        assertEq(nftData.tokenId, 1);
        assertEq(nftData.owner, user1);
        assertEq(nftData.tokenURI, SAMPLE_URI);
        assertEq(nftData.mintedAt, block.timestamp);
    }
    
    function testMintMultipleNFTs() public {
        vm.deal(user1, 1 ether);
        
        vm.startPrank(user1);
        nft.mintNFT{value: 0.01 ether}(SAMPLE_URI);
        nft.mintNFT{value: 0.01 ether}(SAMPLE_URI_2);
        vm.stopPrank();
        
        assertEq(nft.totalSupply(), 2);
        
        uint256[] memory userTokens = nft.getTokensByOwner(user1);
        assertEq(userTokens.length, 2);
        if (userTokens.length >= 1) assertEq(userTokens[0], 1);
        if (userTokens.length >= 2) assertEq(userTokens[1], 2);
    }
    
    function testMintInsufficientPayment() public {
        vm.deal(user1, 0.005 ether);
        vm.prank(user1);
        
        vm.expectRevert("Insufficient payment");
        nft.mintNFT{value: 0.005 ether}(SAMPLE_URI);
    }
    
    function testMintDuplicateURI() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        nft.mintNFT{value: 0.01 ether}(SAMPLE_URI);
        
        vm.expectRevert("URI already used");
        nft.mintNFT{value: 0.01 ether}(SAMPLE_URI);
    }
    
    function testMintEmptyURI() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        vm.expectRevert("URI cannot be empty");
        nft.mintNFT{value: 0.01 ether}("");
    }
    
    function testToggleMinting() public {
        vm.prank(owner);
        nft.toggleMinting();
        
        assertTrue(!nft.mintingActive());
        
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        vm.expectRevert("Minting is not active");
        nft.mintNFT{value: 0.01 ether}(SAMPLE_URI);
    }
    
    function testUpdateMintPrice() public {
        vm.prank(owner);
        nft.updateMintPrice(0.02 ether);
        
        assertEq(nft.mintPrice(), 0.02 ether);
    }
    
    function testUpdateMintPriceZero() public {
        vm.prank(owner);
        
        vm.expectRevert("Price must be greater than 0");
        nft.updateMintPrice(0);
    }
    
    function testWithdraw() public {
        // First mint an NFT to add funds
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        nft.mintNFT{value: 0.01 ether}(SAMPLE_URI);
        
        uint256 initialBalance = owner.balance;
        uint256 contractBalance = address(nft).balance;
        
        vm.prank(owner);
        nft.withdraw();
        
        assertEq(owner.balance, initialBalance + contractBalance);
        assertEq(address(nft).balance, 0);
    }
    
    function testTransferOwnership() public {
        vm.prank(owner);
        nft.transferOwnership(user1);
        
        assertEq(nft.owner(), user1);
    }
    
    function testTransferOwnershipInvalid() public {
        vm.prank(owner);
        
        vm.expectRevert("Invalid new owner");
        nft.transferOwnership(address(0));
    }
    
    function testEmergencyPause() public {
        vm.prank(owner);
        nft.emergencyPause();
        
        assertTrue(!nft.mintingActive());
    }
    
    function testOnlyOwnerModifiers() public {
        vm.prank(user1);
        
        vm.expectRevert("Only owner can call this function");
        nft.toggleMinting();
        
        vm.expectRevert("Only owner can call this function");
        nft.updateMintPrice(0.02 ether);
        
        vm.expectRevert("Only owner can call this function");
        nft.withdraw();
        
        vm.expectRevert("Only owner can call this function");
        nft.transferOwnership(user2);
        
        vm.expectRevert("Only owner can call this function");
        nft.emergencyPause();
    }
    
    function testGetStats() public {
        (uint256 totalSupply, uint256 maxSupply, uint256 mintPrice, bool mintingActive) = nft.getStats();
        
        assertEq(totalSupply, 0);
        assertEq(maxSupply, 1000);
        assertEq(mintPrice, 0.01 ether);
        assertTrue(mintingActive);
    }
    
    function testReceiveETH() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        (bool success,) = address(nft).call{value: 0.5 ether}("");
        assertTrue(success);
        assertEq(address(nft).balance, 0.5 ether);
    }
    
    function testFuzzMint(uint256 value, string memory uri) public {
        vm.assume(value >= 0.01 ether);
        vm.assume(bytes(uri).length > 0);
        vm.assume(!nft.usedURIs(uri));
        
        vm.deal(user1, value);
        vm.prank(user1);
        
        nft.mintNFT{value: value}(uri);
        
        assertEq(nft.totalSupply(), 1);
        assertTrue(nft.usedURIs(uri));
    }
}
