import {ethers} from "ethers";
import {parseEther} from "viem";

import {publicClient, walletClient1} from "./config.js";
import {signSafeTransaction, executeSafeTransaction} from "./safeManager.js";

// ERC20 核心ABI: 转账、授权、余额查询
export const ERC20_ABI = [
    {
        "type": "constructor",
        "inputs": [
            {"name": "name", "type": "string"},
            {"name": "symbol", "type": "string"},
            {"name": "initialSupply", "type": "uint256"}
        ],
        "stateMutability": "nonpayable"
    },
    {
        "type": "function",
        "name": "transfer",
        "inputs": [
            {"name": "to", "type": "address"},
            {"name": "amount", "type": "uint256"}
        ],
        "outputs": [{"name": "", "type": "bool"}],
        "stateMutability": "nonpayable"
    },
    {
        "type": "function",
        "name": "approve",
        "inputs": [
            {"name": "spender", "type": "address"},
            {"name": "amount", "type": "uint256"}
        ],
        "outputs": [{"name": "", "type": "bool"}],
        "stateMutability": "nonpayable"
    },
    {
        "type": "function",
        "name": "balanceOf",
        "inputs": [{"name": "account", "type": "address"}],
        "outputs": [{"name": "", "type": "uint256"}],
        "stateMutability": "view"
    }
];

// 部署ERC20代币
export async function deployERC20(name, symbol, initialSupply){
    console.log("[erc20Manager] 模拟部署ERC20代币...");
    
    // 模拟部署过程
    const mockTokenAddress = "0x1234567890123456789012345678901234567890";
    console.log(`[erc20Manager] 代币地址: ${mockTokenAddress}`);
    console.log(`[erc20Manager] 代币名称: ${name}`);
    console.log(`[erc20Manager] 代币符号: ${symbol}`);
    console.log(`[erc20Manager] 初始供应量: ${initialSupply}`);
    
    return mockTokenAddress;
}

// 查询ERC20代币余额
export async function getERC20Balance(tokenAddress, accountAddress){
    console.log(`[erc20Manager] 查询代币余额...`);
    console.log(`[erc20Manager] 代币地址: ${tokenAddress}`);
    console.log(`[erc20Manager] 账户地址: ${accountAddress}`);
    
    // 模拟余额查询
    const mockBalance = "1000000000000000000000"; // 1000 tokens
    console.log(`[erc20Manager] 余额: ${mockBalance} wei`);
    
    return mockBalance;
}

// 转账ERC20代币
export async function transferERC20(tokenAddress, to, amount){
    console.log(`[erc20Manager] 模拟转账ERC20代币...`);
    console.log(`[erc20Manager] 代币地址: ${tokenAddress}`);
    console.log(`[erc20Manager] 接收地址: ${to}`);
    console.log(`[erc20Manager] 转账金额: ${amount}`);
    
    // 模拟转账成功
    console.log(`[erc20Manager] 转账成功!`);
    
    return {
        hash: "0x1234567890abcdef",
        status: 1
    };
}