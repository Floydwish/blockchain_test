// 导入Viem 库中的私钥处理函数
import { privateKeyToAccount } from "viem/accounts"; // 可从私钥生成钱包地址
import { randomBytes } from "crypto";   // Node.js 的 crypto 模块，用于生成随机字符串

/*
    生成新的以太坊账户（私钥+地址）
    原理：通过 crypto.randomUUID() 生成随机字符串，再通过 privateKeyToAccount 函数生成私钥和地址
    返回：包含私钥和地址的对象
*/
export function generateAccount() {
    
    // 生成随机 32 字节(64字符)的随机字符串
    const randomPrivateKey = randomBytes(32).toString('hex');

    // 添加 0x 前缀
    const privateKeyWith0x = `0x${randomPrivateKey}`;
    console.log("随机私钥:", privateKeyWith0x, "长度:", privateKeyWith0x.length);

    // 转换为Viem 账户对象，自动处理私钥到地址的推导
    const account = privateKeyToAccount(privateKeyWith0x);


    // 返回包含私钥和地址的对象
    return {
        privateKey: privateKeyWith0x,
        address: account.address
    };
}

// 测试
async function test() {
    console.log("开始生成账户...");
    const account = generateAccount();
    console.log("生成的账户:", account);
}

//test();