// src/config.ts

import { http } from 'viem';
import { localhost } from 'viem/chains';
import { createConfig } from 'wagmi';

// 你的 TokenBank 合约地址
export const TOKEN_BANK_CONTRACT_ADDRESS = '0x057ef64E23666F000b34aE31332854aCBd1c8544'; 

// 你的 TokenBank 合约 ABI
/*
export const TOKEN_BANK_CONTRACT_ABI = [
  // ... 存款函数 ABI
  // ... 取款函数 ABI
  // ... 余额查询函数 ABI
  // ... 其他相关函数
] as const;
*/

export const TOKEN_BANK_CONTRACT_ABI  = [
    {
      "type": "constructor",
      "inputs": [],
      "stateMutability": "nonpayable"
    },
    {
      "type": "receive",
      "stateMutability": "payable"
    },
    {
      "type": "function",
      "name": "balances",
      "inputs": [
        {
          "name": "",
          "type": "address",
          "internalType": "address"
        }
      ],
      "outputs": [
        {
          "name": "",
          "type": "uint256",
          "internalType": "uint256"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "deposit",
      "inputs": [],
      "outputs": [],
      "stateMutability": "payable"
    },
    {
      "type": "function",
      "name": "top3Depositors",
      "inputs": [
        {
          "name": "",
          "type": "uint256",
          "internalType": "uint256"
        }
      ],
      "outputs": [
        {
          "name": "",
          "type": "address",
          "internalType": "address"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "totalDeposits",
      "inputs": [],
      "outputs": [
        {
          "name": "",
          "type": "uint256",
          "internalType": "uint256"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "withdraw",
      "inputs": [
        {
          "name": "_amount",
          "type": "uint256",
          "internalType": "uint256"
        }
      ],
      "outputs": [],
      "stateMutability": "nonpayable"
    }
  ] as const;
  

export const config = createConfig({
  chains: [localhost], // 在开发时使用 localhost 链，你可以根据需要更改
  transports: {
    [localhost.id]: http(),
  },
});