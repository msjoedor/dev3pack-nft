// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract BasicTest {
    uint256 public value = 42;
    string public message = "Hello World";
    
    function getValue() external view returns (uint256) {
        return value;
    }
    
    function getMessage() external view returns (string memory) {
        return message;
    }
    
    function setValue(uint256 _newValue) external {
        value = _newValue;
    }
}
