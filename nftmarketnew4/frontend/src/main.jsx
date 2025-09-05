/*
############ 阶段2：应用入口配置 ############
一、说明
1. 是什么：
- 设置 React 应用的入口点
- 配置所有必要的 Provider

2. 为什么
- Provider 为整个应用提供上下文，让所有组件都能访问 Web3 功能

3. 怎么做
- WagmiProvider: 最外层，提供以太坊客户端和区块链交互能力
- QueryClientProvider: 中间层，提供数据查询、缓存、状态管理
- RainbowKitProvider: 最外层，提供钱包连接的 UI 组件
- 嵌套顺序很重要：外层为内层提供上下文，数据流从外到内
*/

import React from 'react'
import ReactDOM from 'react-dom/client'
import './index.css'
import App from './App.jsx'
import {RainbowKitProvider} from '@rainbow-me/rainbowkit'
import {QueryClient, QueryClientProvider } from '@tanstack/react-query'
import {WagmiProvider} from 'wagmi'
import {config} from './config/wagmi.js'
import '@rainbow-me/rainbowkit/styles.css'

const queryClient = new QueryClient();

// 最外层：wagmi, 区块链交互功能
// 中间层：react query, 数据层
// 最内层：rainbowkit, 钱包连接 UI 组件
// APP: 应用

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <WagmiProvider config={config}>               
      <QueryClientProvider client={queryClient}>  
        <RainbowKitProvider>                      
          <App />     
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  </React.StrictMode>
)
