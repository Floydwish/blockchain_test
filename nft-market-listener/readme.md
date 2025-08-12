
# 一、事件监控结果
## 1. 上架事件
接收到新日志（NFT 上架成功）：

```json
[
  {
    "eventName": "NFTListed",
    "args": {
      "nftContract": "0x5B085c2D090556aEA54D595Fe7a70CE98B3CA9e4",
      "tokenId": "2n",
      "price": "1000000000000000000n",
      "paymentToken": "0x237cE762AA51FceF340222B64282B11015Dfe5E5"
    },
    "address": "0x6da6a7f35aac2abe018eadd9d80ecc7c125deb17",
    "topics": [
      "0x5ba0ddd8e72e3c5c274414bd1ef0dec9ae5220e0f6f534d859043e2a52f0319f",
      "0x0000000000000000000000005b085c2d090556aea54d595fe7a70ce98b3ca9e4",
      "0x0000000000000000000000000000000000000000000000000000000000000002"
    ],
    "data": "0x0000000000000000000000000000000000000000000000000de0b6b3a7640000000000000000000000000000237ce762aa51fcef340222b64282b11015dfe5e5",
    "blockHash": "0x227fbac8687763552032d5279bd5da8eca5e8ba279f4ffd68472dfb72b85d62e",
    "blockNumber": "8967362n",
    "blockTimestamp": "0x689b0968",
    "transactionHash": "0x3461ed7adfbc46b9477ea8ae2d659f5ce7f425af9df682f90079fcd558af1ceb",
    "transactionIndex": 119,
    "logIndex": 252,
    "removed": false
  }
]
```

- **事件名**：NFTListed  
- **核心参数**：  
  - NFT 合约地址：`0x5B085c2D090556aEA54D595Fe7a70CE98B3CA9e4`  
  - 代币 ID：`2`  
  - 上架价格：`1000000000000000000`（1 个 ERC20 代币，单位：wei）  
  - 支付代币地址：`0x237cE762AA51FceF340222B64282B11015Dfe5E5`  


## 2. 购买事件
接收到新日志（NFT 购买成功）：

```json
[
  {
    "eventName": "NFTSold",
    "args": {
      "nftContract": "0x5B085c2D090556aEA54D595Fe7a70CE98B3CA9e4",
      "tokenId": "2n",
      "price": "1000000000000000000n",
      "paymentToken": "0x237cE762AA51FceF340222B64282B11015Dfe5E5"
    },
    "address": "0x6da6a7f35aac2abe018eadd9d80ecc7c125deb17",
    "topics": [
      "0x77c3ced349b08a2af4e9d443fb697437c3197b3095d43fcbdc2cdc97b1a60e0c",
      "0x0000000000000000000000005b085c2d090556aea54d595fe7a70ce98b3ca9e4",
      "0x0000000000000000000000000000000000000000000000000000000000000002"
    ],
    "data": "0x0000000000000000000000000000000000000000000000000de0b6b3a7640000000000000000000000000000237ce762aa51fcef340222b64282b11015dfe5e5",
    "blockHash": "0x3873a905c2e28b6f59ca8944d259bd68ffc78982af2d26d2a09113e04856dbe3",
    "blockNumber": "8967366n",
    "blockTimestamp": "0x689b0998",
    "transactionHash": "0x46a2c10047272e88e88b6d418c975c65af7f954e5b247fc59942f8ab082e6142",
    "transactionIndex": 143,
    "logIndex": 294,
    "removed": false
  }
]
```

- **事件名**：NFTSold  
- **核心参数**：  
  - NFT 合约地址：`0x5B085c2D090556aEA54D595Fe7a70CE98B3CA9e4`  
  - 代币 ID：`2`  
  - 成交价格：`1000000000000000000`（1 个 ERC20 代币，单位：wei）  
  - 支付代币地址：`0x237cE762AA51FceF340222B64282B11015Dfe5E5`  


# 二、NFTMarket 事件监听完整测试记录

## 1. 部署
### 1.1 NFT 合约
```bash
forge create --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --broadcast --verify \
  src/MyNFT.sol:labubuNFT
```

### 1.2 ERC20 合约
```bash
forge create --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --broadcast --verify \
  src/BaseERC20.sol:BaseERC20
```

### 1.3 NFTMarket 合约
```bash
forge create --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --broadcast --verify \
  src/NFTMarket.sol:NFTMarket
```

## 2. Mint NFT
传入2个参数，to(address), url("ipfs://bafybeicvadz4g6scctvqyier6ep4usyji57lz2raonh7f2sxohrvghg5za/dog1.json")
```bash
cast send \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  0x5B085c2D090556aEA54D595Fe7a70CE98B3CA9e4 \
  -- \
  "safeMint(address,string)" \
  $DEPLOY_ADDRESS \  
  "ipfs://bafybeicvadz4g6scctvqyier6ep4usyji57lz2raonh7f2sxohrvghg5za/dog1.json"
```

### 2.1 查询 NFT 是否到账
```bash
cast call \
  --rpc-url $SEPOLIA_RPC_URL \
  0x5B085c2D090556aEA54D595Fe7a70CE98B3CA9e4 \
  "ownerOf(uint256)" 0
```

已到账  
return: 0x00000000000000000000000025f0e8d1f862a28ed75d09c0aa27014b173d83f3

## 3. 授权 NFT 给市场合约
传入to(address), tokenid(0)
```bash
cast send \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  0x5B085c2D090556aEA54D595Fe7a70CE98B3CA9e4 \
  "approve(address,uint256)" \
  $MARKET_ADDRESS 0
```

检查是否授权成功：
```bash
cast call \
  --rpc-url $SEPOLIA_RPC_URL \
  0x5B085c2D090556aEA54D595Fe7a70CE98B3CA9e4 \
  "getApproved(uint256)" 0
```

## 4. 启动后台事件监控（先更新 nftMarket 合约地址）
node listenEvents.js (nft-market-listener project)

## 5. 上架
```bash
cast send --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY $MARKET_ADDRESS "listNFT(address,uint256,uint256,address)" $NFT_ADDRESS 0 1000000000000000000 $ERC20_ADDRESS
```
```bash
cast send --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY $MARKET_ADDRESS "listNFT(address,uint256,uint256,address)" $NFT_ADDRESS 1 1000000000000000000 $ERC20_ADDRESS
```
```bash
cast send --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY $MARKET_ADDRESS "listNFT(address,uint256,uint256,address)" $NFT_ADDRESS 2 1000000000000000000 $ERC20_ADDRESS
```

## 6. 充值 ERC20 到买家地址
```bash
cast send \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \ 
  $ERC20_ADDRESS \
  -- \
  "transfer(address,uint256)" \  
  $BUYER_ADDRESS \  
  10000000000000000000
```

```bash
cast send --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY $ERC20_ADDRESS "transfer(address,uint256)" $BUYER_ADDRESS 10000000000000000000
```

查询充值结果：
```bash
# 查询买家地址（$BUYER_ADDRESS）的 ERC20 代币余额
cast call \
  --rpc-url $SEPOLIA_RPC_URL \
  $ERC20_ADDRESS \
  "balanceOf(address)" \
  $BUYER_ADDRESS
```

## 7. 买家授权 nftMarket 使用 ERC20 代币 (先给买家充值 sepolia 的 eth )
```bash
cast send --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY2 $ERC20_ADDRESS "approve(address,uint256)" $MARKET_ADDRESS 1000000000000000000
```

## 8. 买家购买 NFT
```bash
cast send --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY2 $MARKET_ADDRESS "buyNFT(address,uint256,address)" $NFT_ADDRESS 1 $ERC20_ADDRESS
```
```bash
cast send --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY2 $MARKET_ADDRESS "buyNFT(address,uint256,address)" $NFT_ADDRESS 2 $ERC20_ADDRESS
```

## 9. 监控到的上架事件
见 一：1.上架事件

## 10. 监控到的购买事件
见 一：2.购买事件

