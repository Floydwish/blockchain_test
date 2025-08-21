
import { parseEther, formatEther } from "viem";
import {publicClient, walletClient1} from "./config.js";
import {signSafeTransaction, executeSafeTransaction} from "./safeManager.js";
import { ERC20_ABI } from "./erc20Manager.js";

// Bank 合约 ABI
export const BANK_ABI = [
    "constructor()",
    "function admin() view returns (address)",
    "function setNewAdmin(address newAdmin) external",
    "function depositERC20(address token, uint256 amount) external",
    "function withdraw(address token, address to, uint256 amount) external",
    "function getERC20Balance(address token) view returns (uint256)"
];

// 部署 Bank 合约
export async function deployBank(){
    console.log("[bankManager] 模拟部署Bank合约...");
    
    // 模拟部署过程
    const mockBankAddress = "0xabcdef1234567890abcdef1234567890abcdef12";
    console.log(`[bankManager] Bank合约地址: ${mockBankAddress}`);
    
    return mockBankAddress;
}

// 向Bank合约存入ERC20代币
export async function depositERC20ToBank(bankAddress, tokenAddress, amount){
    console.log(`[bankManager] 模拟向Bank存入ERC20代币...`);
    console.log(`[bankManager] Bank地址: ${bankAddress}`);
    console.log(`[bankManager] 代币地址: ${tokenAddress}`);
    console.log(`[bankManager] 存入金额: ${amount}`);
    
    // 模拟存入成功
    console.log(`[bankManager] 存入成功!`);
    
    return {
        hash: "0xabcdef1234567890",
        status: 1
    };
}

// 从Bank合约提取ERC20代币
export async function withdrawERC20FromBank(bankAddress, tokenAddress, to, amount){
    console.log(`[bankManager] 模拟从Bank提取ERC20代币...`);
    console.log(`[bankManager] Bank地址: ${bankAddress}`);
    console.log(`[bankManager] 代币地址: ${tokenAddress}`);
    console.log(`[bankManager] 提取地址: ${to}`);
    console.log(`[bankManager] 提取金额: ${amount}`);
    
    // 模拟提取成功
    console.log(`[bankManager] 提取成功!`);
    
    return {
        hash: "0xabcdef1234567890",
        status: 1
    };
}

// 查询Bank合约中的ERC20代币余额
export async function getBankERC20Balance(bankAddress, tokenAddress){
    console.log(`[bankManager] 查询Bank中的ERC20代币余额...`);
    console.log(`[bankManager] Bank地址: ${bankAddress}`);
    console.log(`[bankManager] 代币地址: ${tokenAddress}`);
    
    // 模拟余额查询
    const mockBalance = "500000000000000000000"; // 500 tokens
    console.log(`[bankManager] Bank中的代币余额: ${mockBalance} wei`);
    
    return mockBalance;
}

