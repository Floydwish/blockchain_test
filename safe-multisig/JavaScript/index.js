/*
safe-multisig-demo/
├── src/                    # Solidity合约文件
│   ├── MyERC20.sol         # 自定义ERC20代币合约
│   └── Bank.sol            # Bank合约
├── JavaScript/
│   ├── config.js           # 配置模块（网络、账户）
│   ├── safeManager.js      # 多签钱包管理模块
│   ├── erc20Manager.js     # ERC20代币管理模块
│   ├── bankManager.js      # Bank合约管理模块
│   └── index.js            # 主入口文件
└── package.json            # 项目依赖

*/

import { create2of3Safe } from "./safeManager.js";
import { deployERC20 } from "./erc20Manager.js";
import { deployBank, depositERC20ToBank, withdrawERC20FromBank, getBankERC20Balance } from "./bankManager.js";

async function main() {
    try {
        console.log("=== Safe 多签钱包演示 ===");
        
        // 1. 部署2/3多签钱包
        const { safe, safeAddress } = await create2of3Safe();
        
        // 2. 部署ERC20代币
        const tokenAddress = await deployERC20("MyToken", "MTK", "1000");
        
        // 3. 部署Bank合约
        const bankAddress = await deployBank();
        
        // 4. 向Bank存入ERC20代币
        await depositERC20ToBank(bankAddress, tokenAddress, "100");
        
        // 5. 查询Bank中的代币余额
        await getBankERC20Balance(bankAddress, tokenAddress);
        
        // 6. 从Bank提取ERC20代币
        await withdrawERC20FromBank(bankAddress, tokenAddress, safeAddress, "50");
        
        console.log("=== 演示完成 ===");
        
    } catch (error) {
        console.error("[index] 操作失败:", error);
    }
}

main();