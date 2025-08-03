// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


//导入BaseERC20 合约接口，让TokenBank 与之交互
interface IERC20{
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function transfer(address to, uint256 amount) external returns(bool);
    function balanceOf(address owner) external view returns(uint256);
}

contract TokenBank{
    address owner;  //合约所有者
    mapping(address => uint256) private balances;

    IERC20 public token; // 声明一个 ERC20 接口的变量，用于存储代币合约的地址

    // 传入已部署的 BaseERC20 地址
    constructor(address _tokenAddress){
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    function deposit(uint256 amount) public{

        //此处不应检查如下：因为在本银行中还没有余额（后续会在 BaseERC20 合约中检查）
        //require(balances[msg.sender] >= amount, "Insufficient balance.");

        require(amount > 0);

        // 使用 transferFrom 从用户账户转移代币到本合约账户
        // 调用前，用户必须先调用 BaseERC20 的 approve()函数，授权 TokenBank 合约提取代币
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed.");

        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        //先更新合约内部余额，防止重入攻击
        balances[msg.sender] -= amount;

        //再将代币转给用户
        bool success = token.transfer(msg.sender, amount);
        require(success, "Token withdraw failed.");

        emit Withdraw(msg.sender, amount);
    }

    function checkBalance(address somebody) public view returns(uint256){
        require(somebody != address(0), "Address is empty.");
        return token.balanceOf(somebody);

    }
    

}


/*
题目#1
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

TokenBank 有两个方法：

deposit() : 需要记录每个地址的存入数量；
withdraw（）: 用户可以提取自己的之前存入的 token。


注意点：
1.这里要求是 Token ，而不是 ETH，二者有显著差别。(msg.value 指的是 eth)
2.本合约需要与 BaseERC20 合约交互。
BaseERC20: 就像中央银行（有铸币权，维护 用户 和 商业银行的 账户）
TokenBank: 就像商业银行（仅存取款，维护 用户 的在本行的资金）
*/