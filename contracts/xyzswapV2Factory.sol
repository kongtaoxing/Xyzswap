//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./libraries/Math.sol";
import "./libraries/SafeMath.sol";

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

contract XyzswapV2 is ERC20 {

    address owner;
    uint256 lpAmount;
    uint256 public fee;
    address tokenA;
    address tokenB;

    error notApproved();
    error notOwner();
    error insufficientBalance();
    error mustBiggerThanZero();
    error invalidSigLen();
    error sigAlreadyUsed();
    error invalidAmount();

    //event for LP
    event AddLiquid(address indexed tokenA, uint256 _amountA, address indexed tokenB, uint256 _amountB);
    event RemoveLiquid(uint256 indexed _amount);
    event Swap(address indexed _token, uint256 indexed _amount);

    // events for owner
    event ChangeOwner(address indexed newOwner);

    constructor(address _tokenA, address _tokenB) ERC20("Xyzswap Liquid Pair", "XYZLP") {
        owner = msg.sender;
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    /******************************************************************************************************
    *                                                                                                     *
    *                                       User's Function                                               *
    *                                                                                                     *
    *******************************************************************************************************/

 
    
    /******************************************************************************************************
    *                                                                                                     *
    *                                      Owner's Function                                               *
    *                                                                                                     *
    *******************************************************************************************************/

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function getFees() public view returns (uint256) {
        return fee;
    }

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