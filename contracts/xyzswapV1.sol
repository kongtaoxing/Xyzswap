//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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

contract Xyzswap is ERC20 {

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

    function addLiquid(uint256 _amountA, uint256 _amountB) public {
        if(Erc20Func(tokenA).allowance(msg.sender, address(this)) < _amountA || Erc20Func(tokenB).allowance(msg.sender, address(this)) < _amountB){
            revert notApproved();
        }
        // lpAmount += _amountA * _amountB / (10 ** 18);
        lpAmount = SafeMath.add(lpAmount, SafeMath.mul(_amountA, _amountB) / (10 ** 18));
        Erc20Func(tokenA).transferFrom(msg.sender, address(this), _amountA);
        Erc20Func(tokenB).transferFrom(msg.sender, address(this), _amountB);
        _mint(msg.sender, _amountA * _amountB / (10 ** 18));

        emit AddLiquid(tokenA, _amountA, tokenB, _amountB);
    }

    function removeLiquid(uint256 _amount) public {
        if(allowance(msg.sender, address(this)) < _amount) {
            revert notApproved();
        }
        _burn(msg.sender, _amount);
        // $(valA-A)*(valB-B)=lpAmount-\_amount$
        // $\frac{A}{B}=\frac{valA}{valB}$
        uint256 _balA = Erc20Func(tokenA).balanceOf(address(this));
        uint256 _balB = Erc20Func(tokenB).balanceOf(address(this));
        // uint256 _valB = _balB - Math.sqrt((_balB * (lpAmount - _amount) * 10 ** 18) / _balA);
        uint256 _valB = SafeMath.sub(_balB, Math.sqrt((SafeMath.div(SafeMath.mul(_balB, (SafeMath.sub(lpAmount, _amount)) * 10 ** 18), _balA))));
        // uint256 _valA = (_balA * _valB) / _balB;
        uint256 _valA = SafeMath.div(SafeMath.mul(_balA, _valB), _balB);
        Erc20Func(tokenA).transfer(msg.sender, _valA);
        Erc20Func(tokenB).transfer(msg.sender, _valB);
        // lpAmount -= _amount;
        lpAmount = SafeMath.sub(lpAmount, _amount);

        emit RemoveLiquid(_amount);
    }

    function swap(address _token, uint256 _amount) public {
        if(Erc20Func(_token).balanceOf(msg.sender) < _amount) {
            revert insufficientBalance();
        }
        if(Erc20Func(_token).allowance(msg.sender, address(this)) < _amount) {
            revert notApproved();
        }
        address _other = (_token == tokenA ? tokenB : tokenA);
        Erc20Func(_token).transferFrom(msg.sender, address(this), _amount);
        // uint256 _val = Erc20Func(_token).balanceOf(address(this)) + _amount;
        uint256 _val = SafeMath.add(Erc20Func(_token).balanceOf(address(this)), _amount);
        // uint256 _valOther = Erc20Func(_other).balanceOf(address(this)) - (lpAmount * 10 ** 18) / _val;
        uint256 _valOther = SafeMath.sub(Erc20Func(_other).balanceOf(address(this)), SafeMath.div(lpAmount * 10 ** 18, _val));
        Erc20Func(_other).transfer(msg.sender, _valOther * (100 - fee) / 100);
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