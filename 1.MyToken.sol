// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MyToken {
    //mapping 类型的变量，用于存储每个地址对应的余额
    mapping (address => uint256) private balances;
    //uint256 类型的变量，用于存储 Token 的总发行量。定义为 public，可以被任何人查询。
    uint256 public totalSupply;
    //address 类型的变量，用于存储此 Token 的发行者。用于一些权限控制
    address private owner;

    constructor() {
        owner = msg.sender;
    }
    //用于铸造 Token 的函数
    function mint(address recipient, uint256 amount) public {
        //权限控制
        require(msg.sender == owner,"Only the owner can perform this action");
        balances[recipient] += amount;
        totalSupply += amount;
    }
    //用于查询某个地址对应的 Token 余额
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    //用于转账的函数
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender], "Not enough balance.");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        return true;
    }
    
}