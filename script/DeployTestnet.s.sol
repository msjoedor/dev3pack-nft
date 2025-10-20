// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "../src/SimpleNFT.sol";

contract DeployTestnetScript {
    function run() public {
        SimpleNFT nft = new SimpleNFT();
        
        console.log("SimpleNFT deployed at:", address(nft));
        console.log("Owner:", nft.owner());
        console.log("Max Supply:", nft.maxSupply());
        console.log("Mint Price:", nft.mintPrice());
        console.log("Minting Active:", nft.mintingActive());
    }
}
