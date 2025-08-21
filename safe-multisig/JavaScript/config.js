
import {createPublicClient, createWalletClient, http } from "viem";
import {sepolia} from "viem/chains";
import {privateKeyToAccount } from "viem/accounts";
import {ethers} from "ethers"; // Safe库依赖
import dotenv from "dotenv";   // 环境变量

import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

dotenv.config({ path: path.resolve(__dirname, "../.env") }); // 关键：加载 .env 文件

// 1. 创建公链客户端: 支持读取区块数据
export const publicClient = createPublicClient({
    chain: sepolia,
    transport: http(process.env.SEPOLIA_RPC_URL)
});

// 2. 创建多签账户
export const owner1 = privateKeyToAccount(process.env.OWNER1_PRIVATE_KEY);
export const owner2 = privateKeyToAccount(process.env.OWNER2_PRIVATE_KEY);
export const owner3 = privateKeyToAccount(process.env.OWNER3_PRIVATE_KEY);

// 3. 创建钱包客户端
export const walletClient1 = createWalletClient({
    account: owner1,
    chain: sepolia,
    transport: http(process.env.SEPOLIA_RPC_URL)
});

export const walletClient2 = createWalletClient({
    account: owner2,
    chain: sepolia,
    transport: http(process.env.SEPOLIA_RPC_URL)
});

// 4. Ethers 提供者 (Safe 库需要 ethers 格式的提供者)
export const etherProvider = new ethers.providers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);

// 5. 为 Safe Protocol Kit 创建兼容的 provider
export const safeProvider = {
    request: async (request) => {
        if (request.method === 'eth_chainId') {
            return '0xaa36a7'; // Sepolia chain ID
        }
        if (request.method === 'eth_getBalance') {
            const balance = await etherProvider.getBalance(request.params[0]);
            return balance.toHexString();
        }
        if (request.method === 'eth_getTransactionCount') {
            const nonce = await etherProvider.getTransactionCount(request.params[0]);
            return nonce.toString(16);
        }
        if (request.method === 'eth_call') {
            const result = await etherProvider.call(request.params[0]);
            return result;
        }
        if (request.method === 'eth_estimateGas') {
            const gas = await etherProvider.estimateGas(request.params[0]);
            return gas.toHexString();
        }
        if (request.method === 'eth_sendRawTransaction') {
            const tx = await etherProvider.sendTransaction(request.params[0]);
            return tx.hash;
        }
        if (request.method === 'eth_getCode') {
            const code = await etherProvider.getCode(request.params[0]);
            return code;
        }
        if (request.method === 'eth_getStorageAt') {
            const storage = await etherProvider.getStorageAt(request.params[0], request.params[1]);
            return storage;
        }
        if (request.method === 'eth_getTransactionByHash') {
            const tx = await etherProvider.getTransaction(request.params[0]);
            if (!tx) return null;
            return {
                hash: tx.hash,
                nonce: tx.nonce.toString(16),
                blockHash: tx.blockHash,
                blockNumber: tx.blockNumber ? tx.blockNumber.toString(16) : null,
                transactionIndex: tx.transactionIndex ? tx.transactionIndex.toString(16) : null,
                from: tx.from,
                to: tx.to,
                value: tx.value.toHexString(),
                gas: tx.gasLimit.toHexString(),
                gasPrice: tx.gasPrice.toHexString(),
                input: tx.data
            };
        }
        throw new Error(`Method ${request.method} not implemented`);
    }
};
