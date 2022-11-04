//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken1 is ERC20{
    constructor() ERC20("Test Token1", "TT1") {
        console.log('TestToken 1 has been deployed.');
        _mint(msg.sender, 10000);
        console.log("10000 TT1 has been minted to", msg.sender);
    }
}

contract TestToken2 is ERC20{
    constructor() ERC20("Test Token2", "TT2") {
        console.log('TestToken 2 has been deployed.');
        _mint(msg.sender, 10000);
        console.log("10000 TT2 has been minted to", msg.sender);
    }
}