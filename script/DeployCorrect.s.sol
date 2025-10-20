// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "../src/Dev3PackNFT.sol";

contract DeployCorrectScript {
    function run() public {
        // Deploy using the first account from Hardhat
        Dev3PackNFT nft = new Dev3PackNFT();
        
        console.log("Dev3PackNFT deployed at:", address(nft));
        console.log("Owner:", nft.owner());
        console.log("Max Supply:", nft.maxSupply());
        console.log("Mint Price:", nft.mintPrice());
        console.log("Minting Active:", nft.mintingActive());
    }
}
