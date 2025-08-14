import { createPublicClient, // 创建只读客户端
         createWalletClient, // 创建钱包客户端（用于做签名交易）   
         http,               // 使用 http 方式连接到 RPC 节点
         parseAbiItem,       // 将函数解析为 ABI 格式
         parseEther,         // 将 ETH 字符串 解析 为 wei 数值
         parseUnits,         // 将 string 类型的金额 转换 为 wei 数值
         formatEther,        // 将 wei 数值 转换 为 ETH 字符串
         encodeFunctionData  // 编码合约调用数据
        } from "viem";  // 导入 viem 库中的函数

import { sepolia } from "viem/chains";               // 导入sepolia 测试网
import { privateKeyToAccount } from "viem/accounts"; // 导入账户处理接口

// 创建 ERC20 代币转账交易
export async function createERC20Transfer(
    senderAddress,          // 发送者地址
    tokenContractAddress,   // 代币合约地址
    recipientAddress,       // 接收者地址
    amount,                 // 转账金额（string 类型，可读格式）
    rpcUrl                  // RPC 节点 URL
) 
{
    // 1. 创建公共客户端 (连接到 sepolia 测试网的 rpcUrl 节点)
    const client = createPublicClient({
        chain: sepolia,
        transport: http(rpcUrl)
    });

    // 2.读取代币小数位数，用来计算实际的转账金额
    const decimalsAbi = [parseAbiItem("function decimals() view returns (uint8)")];
    const decimals = await client.readContract({
        address: tokenContractAddress,
        abi: decimalsAbi,
        functionName: "decimals",
        args: []
    });

    // 3. 计算实际转账金额：将 amount(易读格式) 转为 wei 数值（传输格式）
    const amountWei = parseUnits(amount, decimals);
    console.log("原金额:", amount, "转换后金额:", amountWei);

    // 4. 编码 ERC20 转账函数调用数据
    // 格式：function transfer(address _to, uint256 _value) public returns (bool) 

    console.log("recipientAddress:", recipientAddress);
    console.log("amountWei:", amountWei);
    const transferAbi = [parseAbiItem("function transfer(address, uint256) returns (bool)")];
    console.log("transferAbi:", transferAbi);

    const data = encodeFunctionData({
        abi: transferAbi,
        functionName: "transfer",
        args: [recipientAddress, amountWei]
    });
    console.log("data:", data);

    // 5. 获取当前 gas 建议价格 （EIP-1559 参数）
    //console.log("客户端可用方法:", Object.keys(client).filter(key => typeof client[key] === 'function'));
    const feeData = await client.estimateFeesPerGas(); 
    const maxFeePerGas = feeData.maxFeePerGas;
    const maxPriorityFeePerGas = await client.estimateMaxPriorityFeePerGas();
    
    console.log("maxFeePerGas:", maxFeePerGas, "maxPriorityFeePerGas:", maxPriorityFeePerGas);

    // 6. 估算交易所需 Gas 数量
    const gasEstimate = await client.estimateContractGas({
        to: tokenContractAddress,
        abi: transferAbi,
        functionName: "transfer",
        args: [recipientAddress, amountWei],
        account: senderAddress
    });
    console.log("gasEstimate:", gasEstimate);

    // 7. 获取当前区块号，用于设置交易有效期（防止交易长期有效）
    const blockNumber = await client.getBlockNumber();
    console.log("blockNumber:", blockNumber);

    // 8. 组装 EIP-1559 交易结构
    const nonce = await client.getTransactionCount({ address: senderAddress }); // 交易序号，作为交易nonce (防止重放攻击)
    console.log("nonce:", nonce);
    return {
        from: senderAddress,            // 发送者地址
        to: tokenContractAddress,       // 代币合约地址
        data: data,                     // 编码后的transfer 函数调用数据
        type: "eip1559",                // 指定 EIP-1559 交易
        chainId: sepolia.id,            // 指定 为 Sepolia 测试网 ID
        gas: gasEstimate,                    // 估算的 GAS 数量
        maxFeePerGas: maxFeePerGas, // 最大总单价（基础费 + 优先费）
        maxPriorityFeePerGas: maxPriorityFeePerGas, // 最大优先费（单价）
        nonce: nonce,                   // 交易唯一序号
        deadLine: blockNumber + 100n    // 交易有效期 （100个区块后失效）
    };
}   

// 签名交易
export async function signTransaction(transaction, privateKey){
    // 1. 用私钥创建钱包账户
    const account = privateKeyToAccount(privateKey);
    //console.log("account:", account);

    // 2. 创建钱包客户端
    const walletClient = createWalletClient({
        account: account,  // 使用了 account 
        chain: sepolia,
        transport: http()  // 不需要 RPC, 因为本地签名
    });
    console.log("transaction:", transaction);

    // 3. 签名交易（返回原始交易字符串，包含了签名信息）
    return await walletClient.signTransaction(transaction);
}

// 发送交易到链上
export async function sendTransaction(transaction, rpcUrl){
    // 1. 创建公共客户端
    const pubClient = createPublicClient({
        chain: sepolia,
        transport: http(rpcUrl)
    });

    // 2. 发送原始交易到网络
    const hash = await pubClient.sendRawTransaction({
        serializedTransaction: transaction});
    console.log("hash: ", hash);

    // 3. 等待交易被打包确认（默认等待一个确认）
    const receipt = await pubClient.waitForTransactionReceipt({hash});
    console.log("receipt: ", receipt);

    // 4. 返回交易结果
    return {
        hash: hash,
        receipt: receipt,
        explorerUrl: `https://sepolia.etherscan.io/tx/${hash}` // 交易在 sepolia 测试网上的链接
    };
}