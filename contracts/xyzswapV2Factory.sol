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
        // ??????token0?????????0??????
        // ????????????token0????????????????????????token0???token1,??????tokenA???tokenB???????????????????????????,token0?????????????????????????????????
        if (token0 == address(0)) revert zeroAddress();
        // ??????token0?????????token1?????????????????????,?????????????????????mapping??????0??????,?????????0??????????????????????????????
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        // ?????????type(x)?????????????????????x???????????????(x??????????????????????????????)
        // type(x).creationCode ????????????x????????????bytecode,???bytes??????(????????????????????????????????????????????????,???????????????????????????)
        bytes memory bytecode = type(xyzswapV2Pair).creationCode;
        // ???????????????token????????????????????????keccak256??????hash???
        // ?????????????????????????????????,??????salt?????????????????????????????????
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