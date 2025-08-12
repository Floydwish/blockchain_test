// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract BaseERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    /*
    1.设置 Token 名称（name）："BaseERC20"
    2.设置 Token 符号（symbol）："BERC20"
    3.设置 Token 小数位decimals：18
    4.设置 Token 总量（totalSupply）:100,000,000
    */

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        totalSupply = 100000000;
        decimals = 18;

        // 总量 = 100,000,000 个代币（包含 18 位小数）
        totalSupply = 100000000 * 10 ** decimals;  

        balances[msg.sender] = totalSupply;  
    }

    //5.允许任何人查看任何地址的 Token 余额（balanceOf）
    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        require(_owner != address(0), "Empty address");

        return balances[_owner];

    }

    //6.允许 Token 的所有者将他们的 Token 发送给任何人（transfer）；转帐超出余额时抛出异常(require),并显示错误消息 “ERC20: transfer amount exceeds balance”。
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here

        require(_value <= balances[msg.sender], "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }
    /*
    9.允许被授权的地址消费他们被授权的 Token 数量（transferFrom）；
      转帐超出余额时抛出异常(require)，异常信息：“ERC20: transfer amount exceeds balance”
      转帐超出授权数量时抛出异常(require)，异常消息：“ERC20: transfer amount exceeds allowance”。
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here

        //require(allowances[_from][msg.sender], 这里注意transferFrom 是由被授权者调用即msg.sender
        //被授权者 和 转账目标地址 通常不是一个地址
        //因此，对 被授权地址 的金额操作，只能用 msg.sender(被授权者地址), 而不是 _to(转账目标地址)
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");

        allowances[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;

        
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    //7.允许 Token 的所有者批准某个地址消费他们的一部分Token（approve）
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here
        // 按照官方EIP-20标准，第2次授权时，覆盖第1次授权的金额
        // 该检查不是必要的，因为授权金额可以大于余额，只要在 transferFrom 时余额足够即可
        //require(balances[msg.sender] >= _value, "Insufficient allowance");

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }
    

    //8.允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here     
        return allowances[_owner][_spender];
    }
}


/*
题目#1
编写 ERC20 token 合约
  
介绍
ERC20 是以太坊区块链上最常用的 Token 合约标准。通过这个挑战，你不仅可以熟悉 Solidity 编程，而且可以了解 ERC20 Token 合约的工作原理。

目标
完善合约，实现以下功能：

1.设置 Token 名称（name）："BaseERC20"
2.设置 Token 符号（symbol）："BERC20"
3.设置 Token 小数位decimals：18
4.设置 Token 总量（totalSupply）:100,000,000
5.允许任何人查看任何地址的 Token 余额（balanceOf）
6.允许 Token 的所有者将他们的 Token 发送给任何人（transfer）；转帐超出余额时抛出异常(require),并显示错误消息 “ERC20: transfer amount exceeds balance”。
7.允许 Token 的所有者批准某个地址消费他们的一部分Token（approve）
8.允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）
9.允许被授权的地址消费他们被授权的 Token 数量（transferFrom）；
转帐超出余额时抛出异常(require)，异常信息：“ERC20: transfer amount exceeds balance”
转帐超出授权数量时抛出异常(require)，异常消息：“ERC20: transfer amount exceeds allowance”。

注意：
在编写合约时，需要遵循 ERC20 标准，此外也需要考虑到安全性，确保转账和授权功能在任何时候都能正常运行无误。
代码模板中已包含基础框架，只需要在标记为“Write your code here”的地方编写你的代码。不要去修改已有内容！

希望你能用一段优雅、高效和安全的代码，完成这个挑战。
*/