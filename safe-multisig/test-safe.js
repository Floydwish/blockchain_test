import SafeProtocolKit from "@safe-global/protocol-kit";
import { ethers } from "ethers";
import dotenv from "dotenv";

dotenv.config();

async function testSafeProtocolKit() {
    console.log("=== 测试 Safe Protocol Kit 基本功能 ===");
    
    try {
        // 1. 测试导入
        console.log("1. 测试导入...");
        console.log("SafeProtocolKit 类型:", typeof SafeProtocolKit);
        console.log("SafeProtocolKit.default 类型:", typeof SafeProtocolKit.default);
        
        // 2. 测试可用的函数
        console.log("\n2. 测试可用函数...");
        const availableFunctions = Object.keys(SafeProtocolKit).filter(key => 
            typeof SafeProtocolKit[key] === 'function' && !key.startsWith('_')
        );
        console.log("可用函数:", availableFunctions.slice(0, 10));
        
        // 3. 测试网络配置
        console.log("\n3. 测试网络配置...");
        const provider = new ethers.providers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
        const network = await provider.getNetwork();
        console.log("网络信息:", {
            chainId: network.chainId,
            name: network.name
        });
        
        console.log("\n=== 测试完成 ===");
        
    } catch (error) {
        console.error("测试失败:", error.message);
        console.error("错误详情:", error);
    }
}

testSafeProtocolKit();
