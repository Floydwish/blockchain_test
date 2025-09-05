/*
############阶段1：配置文件设置############
一、说明
1. 是什么：
- 配置 wagmi 客户端，定义支持的区块链网络和连接参数

2. 为什么
 - wagmi 需要指导连接哪个网络，使用哪个 RPC 节点

 3. 怎么做
- getDefaultConfig: 使用 RainbowKit 的默认配置作为基础
- customSepolia: 自定义 Sepolia 测试网配置，主要配置 RPC 节点地址
- projectId: WalletConnect 项目标识，用于连接手机钱包
- ssr:true: 启用服务器端渲染，提升首屏加载速度（用户体验）

二、获取配置
1. 申请 Alchemy API Key
- url: https://www.alchemy.com
- 得到 key: zZujy05fSniLXYHDozs6s
- 用于：拼接 RPC 节点地址： https://eth-sepolia.g.alchemy.com/v2/zZujy05fSniLXYHDozs6s

2. 申请 WalletConnect 项目标识
- url: https://cloud.walletconnect.com/（注意：会跳转到 https://dashboard.reown.com）
- 得到 projectId: dec1749a6c096aafd32766f398e6343e
- 用于：连接手机钱包

*/

// 用到 RainbowKit 的 getDefaultConfig 函数
import { getDefaultConfig } from "@rainbow-me/rainbowkit"

// 用到 wagmi 的 sepolia 测试网配置
import {sepolia} from "wagmi/chains"

// 自定义 Sepolia 测试网配置
const customSepolia = {
    ...sepolia,             // 展开 sepolia 的默认配置
    rpcUrls: {
        ...sepolia.rpcUrls, // 展开默认 RPC 配置 （只修改 RPC URL)
        default: { //主要 RPC 节点，用于所有需要 API 秘钥的操作
            http: ["https://eth-sepolia.g.alchemy.com/v2/zZujy05fSniLXYHDozs6s"]
        },
        public: { // 备用 RPC 节点，用于公共访问
            http: ["https://eth-sepolia.g.alchemy.com/v2/zZujy05fSniLXYHDozs6s"]
        }
    }
};

// 导出 Wagmi 配置
export const config = getDefaultConfig({
    appName: "Marvin NFT Market",                  // 配置应用名称（ 主界面显示的标题）
    projectId: "dec1749a6c096aafd32766f398e6343e", // 配置 WalletConnect 项目标识, 用于手机钱包连接
    chains: [customSepolia],                       // 配置支持的区块链网络（暂时只有 Sepolia 测试网）
    ssr: true,                                     // 启用服务器端渲染，提升首屏加载速度（用户体验）
});