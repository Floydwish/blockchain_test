import { createPublicClient, http, formatEther, parseAbiItem } from "viem";
import { sepolia } from "viem/chains";


/* JavaScript 背景知识
1.export
a.以 ES6 模块语法导出函数，可以在其他文件中 import 使用
b.类似的：函数、类、常量等都可以导出
c.ES6 模块系统中：每个文件是一个独立的模块，通过 export 导出内容，通过 import 导入内容

2.async/await
a.async: 说明函数内部有异步操作（如链上查询）
b.await: 等待异步操作完成
*/

// 查询余额 (原生币 ETH)
export async function getEthBalance(address, rpcUrl) {
    // 1.创建公共客户端
    const client = createPublicClient({
        chain: sepolia, // 使用 Sepolia 测试网
        transport: http(rpcUrl) // 使用 http 方式 连接 到 rpcUrl
    });

    // 2. 查询余额（异步）
    const balance = await client.getBalance({  // 返回值单位：wei
        address: address // 钱包地址
    })

    // 3. 转换格式：转换为 ETH 并保留6位小数
    // formatEther 将 wei 转换为 ETH 字符串
    // parseFloat 将字符串转换为浮点数
    // toFixed(6) 保留6位小数
    return {
        balance: parseFloat(formatEther(balance)).toFixed(6),  
        tokenSymbol: "ETH", // 代币符号
        decimals: 18        // 代币小数位数
    }

}

// 查询余额（ERC20 代币）
export async function getERC20Balance(address, rpcUrl, tokenAddress){

    console.log("tokenAddress: ", tokenAddress);
    // 1. 创建公共客户端(只读)
    const client = createPublicClient({
        chain: sepolia,
        transport: http(rpcUrl)
    });

    // 2. 获取 代币小数位数
    // 先获取 decimals 函数的ABI （来源：ERC20 标准方法）
    const decimalsAbi = [parseAbiItem("function decimals() view returns (uint8)")];

    //console.log("decimalsAbi: ", decimalsAbi);
    const decimals = await client.readContract({
        address: tokenAddress,
        abi: decimalsAbi,
        functionName: "decimals",
        args: []
    });
    console.log("代币小数位数:", decimals);


    // 3.获取代币余额
    // 先获取 balanceOf 函数的 ABI
    const balanceOfAbi = [parseAbiItem("function balanceOf(address) view returns (uint256)")];
    console.log("balanceOfAbi: ",balanceOfAbi);
    console.log("tokenAddress:",tokenAddress);
    console.log("address:",address);
    const balance = await client.readContract({
        address: tokenAddress,
        abi: balanceOfAbi,
        functionName: "balanceOf",
        args: [address]   // 待查询钱包地址
    });
    console.log("代币余额:", balance);

    // 4. 格式转换
    const formatBalance = (Number(balance) / 10 ** decimals).toFixed(6); // 根据精度转换
    console.log("formatBalance: ", formatBalance);
    //const formatBalance = formatUnits(balance, decimals); // 返回字符串格式的余额

    // 5. 获取代币符号
    const symbolsAbi = [parseAbiItem("function symbol() view returns (string)")];
    const symbol = await client.readContract({
        address: tokenAddress,
        abi: symbolsAbi,
        functionName: "symbol",
        args: []
    });
    console.log("代币符号:", symbol);

    return { // 返回：余额、符号、精度
        balance: formatBalance,
        tokenSymbol: symbol,
        decimals: decimals
    }
    

}