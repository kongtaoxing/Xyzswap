//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./xyzswapV2Pair.sol";
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

contract XyzswapV2Factory is ERC20 {

    address owner;
    uint256 lpAmount;
    uint256 public fee;
    address[] public allPairs;

    error notApproved();
    error notOwner();
    error insufficientBalance();
    error mustBiggerThanZero();
    error invalidSigLen();
    error sigAlreadyUsed();
    error invalidAmount();
    error zeroAddress();

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    // events for owner
    event ChangeOwner(address indexed newOwner);

    mapping(address => mapping(address => address)) public getPair;  // get pair address

    constructor() ERC20("Xyzswap Liquid Pair", "XYZLP") {
        owner = msg.sender;
    }

    /******************************************************************************************************
    *                                                                                                     *
    *                                       User's Function                                               *
    *                                                                                                     *
    *******************************************************************************************************/

     function allPairsLength() external view returns (uint) {   // got pair amount
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address) {
        require(tokenA != tokenB, "Same token!");
         (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        // 判断token0不能为0地址
        // 此时判断token0就等于同时判断了token0和token1,因为tokenA和tokenB已经进行过大小判断,token0地址是绝对小于任何地址
        if (token0 == address(0)) revert zeroAddress();
        // 判断token0是否和token1有产生过交易对,如果没配对那么mapping就是0地址,如果非0地址代表已经配对过了
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        // 表达式type(x)可用于检索参数x的类型信息(x仅能是合约或整型常量)
        // type(x).creationCode 获得包含x的合约的bytecode,是bytes类型(不能在合约本身或继承的合约中使用,因为会引起循环引用)
        bytes memory bytecode = type(xyzswapV2Pair).creationCode;
        // 将排序好的token对进行打包后通过keccak256得到hash值
        // 因为两个地址是为确定值,所以salt是可以通过链下计算出来
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        
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