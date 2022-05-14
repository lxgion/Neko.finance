// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.13;
import "./NekoUSD.sol";

contract Nekofi {
    mapping (address => uint256) public balanceOf;

    string public name = "Nekomimi";
    string public symbol = "NEKO";
    uint8 public decimals = 18;
    uint256 public nekoUSDSide;
    uint256 public nekoSide;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public NULL = 0x0000000000000000000000000000000000000000;
    address public NekoGuard = 0x0000000000000000000000000000000000000001;
    address public owner;
    NekoUSD public nekousd;

    uint256 public totalSupply = 1000000 * (uint256(10) ** decimals);

    constructor() { 
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        owner = msg.sender;
        nekousd = new NekoUSD();
    }

    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

    modifier nekoUSDOnly {
        require(msg.sender == address(nekousd));
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

    function mint(uint256 amount) public ownerOnly returns (bool success) {
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
        return true;
    }

    function exchange(uint256 amount) public returns (bool success) {
        require(balanceOf[msg.sender] >= amount);
        require(nekoUSDSide >= amount);
        balanceOf[msg.sender] -= amount;
        balanceOf[NekoGuard] += amount;
        nekoSide += amount;
        nekoUSDSide -= amount;
        emit Transfer(msg.sender, NekoGuard, amount);
        return nekousd.exchangeMint(msg.sender, amount);
    }

    function exchangeMint(address to, uint256 value) public nekoUSDOnly returns (bool success) {
        require(nekoSide >= value);
        balanceOf[to] += value;
        emit Transfer(NULL, to, value);
        nekoUSDSide += value;
        nekoSide -= value;
        return true;
    }
}