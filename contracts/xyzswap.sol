//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface Erc20Func {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract Xyzswap is ERC20 {

    address owner;
    uint256 lpAmount;

    error notApproved();
    error notOwner();
    error insufficientBalance();
    error mustBiggerThanZero();
    error invalidSigLen();
    error sigAlreadyUsed();
    error invalidAmount();

    // events for owner
    event ChangeOwner(address indexed newOwner);

    constructor() ERC20("Xyzswap Liquid Pair", "XYZLP") {
        owner = msg.sender;
        console.log("LP has been deployed!");
    }

    function initPool(address _token1, uint256 _amount1, address _token2, uint256 _amount2) public {
        if(Erc20Func(_token1).allowance(msg.sender, address(this)) < _amount1 || Erc20Func(_token2).allowance(msg.sender, address(this)) < _amount2){
            revert notApproved();
        }
        lpAmount = _amount1 * _amount2;
        _mint(msg.sender, lpAmount);
    }

    /******************************************************************************************************
    *                                                                                                     *
    *                                      Owner's Function                                               *
    *                                                                                                     *
    *******************************************************************************************************/

    function withdraw() onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getContractOwner() public view returns (address) {
        return owner;
    }

    function changeOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;

        emit ChangeOwner(_newOwner);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert notOwner();
        }
        _;
    }
}