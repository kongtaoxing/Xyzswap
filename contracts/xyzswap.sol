//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Xyzswap is ERC20 {
    constructor() ERC20("Xyzswap Liquid Pair", "XYZLP") {
        console.log("LP has been deployed!");
    }
}