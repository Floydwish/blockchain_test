# 基于 Viem 的 CLI 钱包实现

## 一、核心成果
### 1. 交易链接
[Sepolia 测试网交易详情](https://sepolia.etherscan.io/tx/0x0f602356f50cc07cd1eb6598d3afc640174bcd994deda4a67e5fd6b08422d5c1)


## 二、核心功能
- 生成以太坊私钥与地址（基于 secp256k1 加密算法）
- 支持 ETH 原生币与 ERC20 代币余额查询
- 构建并签名符合 EIP-1559 标准的 ERC20 转账交易
- 适配 Sepolia 测试网，支持交易发送与链上验证


## 三、关键技术点
- **Viem 库应用**：通过公共客户端（Public Client）处理区块链查询，钱包客户端（Wallet Client）完成本地签名，职责分离更安全
- **EIP-1559 合规**：严格使用 `maxFeePerGas` 和 `maxPriorityFeePerGas` 动态计算 Gas 费用，优化交易确认效率
- **模块化设计**：拆分钱包（账户生成）、余额（查询）、交易（构建/签名/发送）三大模块，代码结构清晰


## 四、测试过程记录

### 1. 生成钱包
**执行命令**：
```bash
node index.js generate
```

**执行结果**：
```
新钱包生成成功
地址: 0xCD20497dC1472f9705d3853dfbCF04C73421F693
```


### 2. 查询 ETH 余额
#### 2.1 准备工作：转入 Sepolia ETH
- 接收地址：`0xCD20497dC1472f9705d3853dfbCF04C73421F693`
- 操作方式：通过 MetaMask 钱包转账

#### 2.2 执行查询
```bash
node index.js balance 0xCD20497dC1472f9705d3853dfbCF04C73421F693
```

**查询结果**：
```
余额: 0.001200 (手动转账后查询)
代币符号: ETH
代币小数位数: 18
```


### 3. 查询 ERC20 余额
#### 3.1 部署 ERC20 合约（或使用已有合约）
```bash
forge create --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --broadcast --verify \
  src/BaseERC20.sol:BaseERC20
```

**合约地址**：
`0x237cE762AA51FceF340222B64282B11015Dfe5E5`

#### 3.2 转入 ERC20 代币（部署者 → 新账户）
```bash
cast send --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  $ERC20_ADDRESS \
  "transfer(address,uint256)" \
  0xCD20497dC1472f9705d3853dfbCF04C73421F693 \
  10000000000000000000
```

#### 3.3 查询 ERC20 余额
**方式一：通过 cast 工具查询**
```bash
cast call --rpc-url https://eth-sepolia.g.alchemy.com/v2/zZujy05fSniLXYHDozs6s \
  0x237cE762AA51FceF340222B64282B11015Dfe5E5 \
  "balanceOf(address)" \
  0xCD20497dC1472f9705d3853dfbCF04C73421F693
```

**方式二：通过本工具查询**
```bash
node index.js balance 0xCD20497dC1472f9705d3853dfbCF04C73421F693 \
  -t 0x237cE762AA51FceF340222B64282B11015Dfe5E5
```

**查询结果**：
```
查询成功:
余额: 40.000000
代币符号: BERC20
代币小数位数: 18
```


### 4. 执行 ERC20 转账
#### 4.1 创建接收账户
```
新钱包生成成功:
地址: 0x2Fc03FCEd2e0f46f0e5755E5bba4e06906B8933D
```

#### 4.2 执行转账（账号1 → 账号2）
```bash
# 命令格式
node index.js transfer -k <private_key> -t <token_contract_address> -r <recipient_address> -a <amount>

# 实际执行
node index.js transfer -k <private_key> \
  -t 0x237cE762AA51FceF340222B64282B11015Dfe5E5 \
  -r 0x2Fc03FCEd2e0f46f0e5755E5bba4e06906B8933D \
  -a 1
```

#### 4.3 验证到账情况
**方式一：通过 cast 工具查询**
```bash
cast call --rpc-url https://eth-sepolia.g.alchemy.com/v2/zZujy05fSniLXYHDozs6s \
  0x237cE762AA51FceF340222B64282B11015Dfe5E5 \
  "balanceOf(address)" \
  0xCD20497dC1472f9705d3853dfbCF04C73421F693
```

**方式二：通过本工具查询**
```bash
node index.js balance 0x2Fc03FCEd2e0f46f0e5755E5bba4e06906B8933D \
  -t 0x237cE762AA51FceF340222B64282B11015Dfe5E5
```

**到账结果**：
```
查询成功:
余额: 3.000000
代币符号: BERC20
代币小数位数: 18
```