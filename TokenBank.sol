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

3.处理合规的 ERC-20 合约 的返回值
原因：ERC-20 标准未规定失败后要回退交易
可能情况：失败后返回false但不回退
应对方式：require 检查 token.transferFrom 的返回值，返回失败时 revert
实际案例：ZRX 代币合约：https://etherscan.io/address/0xe41d2489571d322189246dafa5ebde1f4699f498#readContract
常见于：比较老的代币合约

4.针对2种版本的 ERC20 合约进行处理：1.try/catch:处理会触发异常的；2.检查返回值：处理返回true/fase的

5.支持所有token
问题：有些token 并非标准 ERC-20标准token(比如，缺少返回值，注：早期的 OpenZeppelin)
Uniswap的解决方式：检查返回值，同时检查返回的data；实例：https://github.com/Uniswap/solidity-lib/blob/9642a0705fdaf36b477354a4167a8cd765250860/contracts/libraries/TransferHelper.sol#L13-L17

function safeTransferNoRevert(address token, address to, uint value) internal returns (bool) {

  (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

  return success && (data.length == 0 || abi.decode(data, (bool));

  检查逻辑：
  如果success为false，则整个表达式立即返回false，因为&&运算符具有短路效应。
    
  如果success为true，则检查返回数据的长度。
  如果长度为0，则认为转账成功，返回true。
  如果长度不为0，则尝试将返回数据解码为bool值。如果解码后的值为true，则认为转账成功，返回true；否则返回false。

}

最佳方式：使用 OpenZeppelin 的 SafeERC20 实现
// 已更改，import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/SafeERC20.sol";
当前最新链接：
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol"

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
//1.SafeERC20.sol: 提供一套安全的 ERC20 代币交互函数
//2.IERC20.sol: 定义了 ERC20代币的标砖接口

contract TestContract {
    //using关键字将SafeERC20库中的函数与IERC20接口关联起来
    //可以对IERC20类型的变量使用SafeERC20库中的函数
    using SafeERC20 for IERC20; 

    function safeInteractWithToken(uint256 sendAmount) external {
        //传入 ERC20 代币合约地址
        IERC20 token = IERC20(address(this));

        //使用IERC20 关联的 SafeERC20 函数
        token.safeTransferFrom(msg.sender, address(this), sendAmount);
    }
}

*/