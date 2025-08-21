// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";



/**
 * @title Bank
 * @dev 简单银行合约，支持存款、提款、查询余额，只有管理员可执行提款
 */
contract Bank {    
    // 管理员地址（拥有提款权限）
    address public admin;


    mapping(address => uint256) public erc20Balances; // erc20代币余额

    constructor(){
        admin = msg.sender;
    }

    // 仅管理员可调用
    modifier onlyAdmin(){
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    // 设置新管理员
    function setNewAdmin(address newAdmin) external onlyAdmin{
        admin = newAdmin;
    }

    // 存款：存入ERC20代币
    // 条件：需调用者先授权
    // amount: 存入数量 wei
    function depositERC20(address token, uint256 amount) external{
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than 0");

        // 从用户地址转账到合约地址
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);

        require(success, "Transfer failed");

        // 更新余额
        erc20Balances[token] += amount;
    }

    // 接收ETH
    receive() external payable{}

    // 提款: 仅管理员
    function withdraw(address token, address to, uint256 amount) external onlyAdmin{
        require(erc20Balances[token] >= amount, "Insufficient balance");

        // 从合约地址转账到用户地址
        bool success = IERC20(token).transfer(to, amount);
        require(success, "Transfer failed");

        // 更新余额
        erc20Balances[token] -= amount;
    }

    // 查询ERC20代币余额
    function getERC20Balance(address token) external view returns(uint256){
        return erc20Balances[token];
    }
}