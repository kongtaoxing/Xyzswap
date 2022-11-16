//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

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
    uint256  public lpAmount;
    uint256 fee;
    address token1;
    address token2;

    error notApproved();
    error notOwner();
    error insufficientBalance();
    error mustBiggerThanZero();
    error invalidSigLen();
    error sigAlreadyUsed();
    error invalidAmount();

    //event for LP
    event AddLiquid(address indexed token1, uint256 _amount1, address indexed token2, uint256 _amount2);
    event RemoveLiquid(uint256 indexed _amount);
    event Swap(address indexed _token, uint256 indexed _amount);

    // events for owner
    event ChangeOwner(address indexed newOwner);

    constructor(address _token1, address _token2) ERC20("Xyzswap Liquid Pair", "XYZLP") {
        owner = msg.sender;
        token1 = _token1;
        token2 = _token2;
        console.log("LP has been deployed!");
    }

    /******************************************************************************************************
    *                                                                                                     *
    *                                       User's Function                                               *
    *                                                                                                     *
    *******************************************************************************************************/

    function addLiquid(uint256 _amount1, uint256 _amount2) public {
        if(Erc20Func(token1).allowance(msg.sender, address(this)) < _amount1 || Erc20Func(token2).allowance(msg.sender, address(this)) < _amount2){
            revert notApproved();
        }
        lpAmount += _amount1 * _amount2 / (10 ** 18);
        Erc20Func(token1).transferFrom(msg.sender, address(this), _amount1);
        Erc20Func(token2).transferFrom(msg.sender, address(this), _amount2);
        _mint(msg.sender, lpAmount);

        emit AddLiquid(token1, _amount1, token2, _amount2);
    }

    function removeLiquid(uint256 _amount) public {
        if(allowance(msg.sender, address(this)) < _amount) {
            revert notApproved();
        }
        _burn(msg.sender, _amount);
        // $(valA-A)*(valB-B)=lpAmount-\_amount$
        // $\frac{A}{B}=\frac{valA}{valB}$
        uint256 _bal1 = Erc20Func(token1).balanceOf(address(this));
        uint256 _bal2 = Erc20Func(token2).balanceOf(address(this));
        uint256 _valB = _bal2 - Math.sqrt((_bal2 * (lpAmount - _amount) * 10 ** 18) / _bal1);
        uint256 _valA = (_bal1 * _valB) / _bal2;
        Erc20Func(token1).transfer(msg.sender, _valA);
        Erc20Func(token2).transfer(msg.sender, _valB);
        lpAmount -= _amount;

        emit RemoveLiquid(_amount);
    }

    function swap(address _token, uint256 _amount) public {
        if(Erc20Func(_token).balanceOf(msg.sender) < _amount) {
            revert insufficientBalance();
        }
        if(Erc20Func(_token).allowance(msg.sender, address(this)) < _amount) {
            revert notApproved();
        }
        address _other = (_token == token1 ? token2 : token1);
        Erc20Func(_token).transferFrom(msg.sender, address(this), _amount);
        uint256 _val = Erc20Func(_token).balanceOf(address(this)) + _amount;
        uint256 _valOther = Erc20Func(_other).balanceOf(address(this)) - (lpAmount * 10 ** 18) / _val;
        Erc20Func(_other).transfer(msg.sender, _valOther);
        lpAmount = _val * ((lpAmount * 10 ** 18) / _val) /(10 ** 18);  // Update lpAmount if slip point is high

        emit Swap(_token, _amount);
    }
    
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