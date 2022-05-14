// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.13;
import "./Nekofi.sol";

contract NekoUSD {
    mapping (address => uint256) public balanceOf;

    string public name = "NekoUSD";
    string public symbol = "NEKOUSD";
    uint8 public decimals = 18;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public NULL = 0x0000000000000000000000000000000000000000;
    address public owner;
    Nekofi public ownerContract;

    uint256 public totalSupply = 1000000 * (uint256(10) ** decimals);

    constructor() { 
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        owner = msg.sender;
        ownerContract = Nekofi(owner);
    }

    modifier NekoOnly {
        require(msg.sender == owner);
        _;
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

    function exchange(uint256 amount) public returns (bool success) {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        balanceOf[DEAD] += amount;
        emit Transfer(msg.sender, DEAD, amount);
        return ownerContract.exchangeMint(msg.sender, amount);
    }

    function exchangeMint(address to, uint256 value) public NekoOnly returns (bool success) {
        balanceOf[to] += value;
        emit Transfer(NULL, to, value);
        return true;
    }

    function fundPool(uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] -= value;
        emit Transfer(msg.sender, owner, value);
        return true;
    }
}