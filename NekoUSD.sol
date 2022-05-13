// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.13;
import "./Nekofi.sol";

contract NekoUSD {
    mapping (address => uint256) public balanceOf;

    string public name = "NekoUSD";
    string public symbol = "NEKOUSD";
    uint8 public decimals = 18;
    address public owner;
    address public motherContract;
    Nekofi public fi = motherContract;

    uint256 public totalSupply = 1000000 * (uint256(10) ** decimals);

    constructor(address _contract) { 
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        owner = msg.sender;
        motherContract = _contract;
    }

    struct usdPool {
        uint256 nekoSide;
        uint256 nekoUSDSide;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 value)
        public
        returns (bool success)
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    event Redemption(address indexed sender, uint256 value);

    function redemption(address sender, uint256 value) public returns (bool success) {
        balanceOf[sender] += value;
        emit Redemption(sender, value);
        return true;
    }

    function getPoolData() public returns (usdPool) {
        return motherContract.returnPool;
    }

    function redeem(uint256 amount) public returns (bool success) {
        balanceOf[msg.sender] -= amount;
        amount.nekoUSDSide += amount;
        emit Transfer(msg.sender, address(motherContract), amount);
        fi.redemption(msg.sender, amount);
        return true;
    }

}