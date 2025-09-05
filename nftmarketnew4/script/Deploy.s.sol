// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {myERC20Token} from "../src/myERC20Token.sol";
import {myNFT} from "../src/myNFT.sol";
import {myNFTMarket} from "../src/myNFTMarket.sol";


contract Deploy is Script {
    // 1.合约实例
    myERC20Token public erc20;
    myNFT public nft;
    myNFTMarket public nftMarket;

    // 2.部署者地址
    address public deployer;

    // 3.初始化
    function setUp() public {
        deployer = msg.sender; // 部署者地址为 msg.sender
    }

    // 4.执行
    function run() public {
        // 0.开始记录交易
        vm.startBroadcast();

        // 1.部署 ERC20 合约
        console.log("Deploying ERC20 contract...");
        erc20 = new myERC20Token();
        console.log("ERC20 contract deployed at:", address(erc20));

        // 2.部署 NFT 合约
        console.log("Deploying NFT contract...");
        nft = new myNFT();
        console.log("NFT contract deployed at:", address(nft));

        // 3.部署 NFTMarket 合约
        console.log("Deploying NFTMarket contract...");
        nftMarket = new myNFTMarket();
        console.log("NFTMarket contract deployed at:", address(nftMarket));

        // 4.初始化设置（可选）
        // 4.1铸造 ERC20 代币 给部署者（ 可选：myERC20Token 合约中已经有铸造代币给部署者）
        //console.log("Minting ERC20 tokens to owner...");
        //erc20.mint(owner, 1000000000000000000000000);
        //console.log("ERC20 tokens minted to owner");

        // 4.2 铸造 NFT 给部署者 (可选：myNFT 合约中没有铸造 NFT 给部署者）
        console.log("Minting NFT to owner...");
        nft.mint(deployer, "http://localhost:5173/sample-metadata.json");
        console.log("NFT minted to owner");
        
        // 5.停止记录交易
        vm.stopBroadcast();

        // 6.验证部署结构
        console.log("\n===== Deployment Summary =====\n");
        console.log("Deployer:", deployer);
        console.log("ERC20 contract:", address(erc20));
        console.log("NFT contract:", address(nft));
        console.log("NFTMarket contract:", address(nftMarket));
        console.log("Deployer NFT balance:", nft.balanceOf(deployer));
        console.log("Deployer ERC20 balance:", erc20.balanceOf(deployer));
        console.log("======================================\n");

    }

    // 5. 添加验证部署结果的函数（可选）
    function verifyDeployment() public view{
        // 1.ERC20 合约验证
        require(address(erc20) != address(0), "ERC20 contract not deployed");

        // 2.NFT 合约验证
        require(address(nft) != address(0), "NFT contract not deployed");

        // 3.NFTMarket 合约验证
        require(address(nftMarket) != address(0), "NFTMarket contract not deployed");

        // 4.部署者 代币 余额验证
        require(erc20.balanceOf(deployer) > 1000 * 10 ** 18, "ERC20 balance not enough");

        // 5.部署者 NFT 余额验证
        require(nft.balanceOf(deployer) > 0, "NFT balance not enough");

        console.log("Deployment verified successfully");
    }

}


/*
一、测试须知
1. 本地测试
1.1 主要目的
- 验证部署脚本，合约部署是否成功
- 验证基本功能是否正常

1.2 一般做什么
- 脚本部署合约：验证合约部署是否成功
- 验证基本功能（一般不做复杂功能测试）

2. 测试网测试
2.1 主要目的
- 验证合约在真实网络中的功能是否正常
- 检查 gas 费用、网络延迟
- 发现潜在问题（是否符合预期：权限、事件触发、状态变化）

2.2 一般做什么
- 脚本部署合约：验证合约部署是否成功
- 验证基本功能，业务流程测试

3. 主网测试（待定）

二、环境变量设置
# 在 .env 文件中设置
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_project_id
MAINNET_RPC_URL=https://mainnet.infura.io/v3/your_project_id
ETHERSCAN_API_KEY=your_etherscan_api_key

三、部署命令
1.本地测试部署
forge script script/Deploy.s.sol --rpc-url $LOCAL_RPC_URL --broadcast

# 指定本地测试部署者私钥：
forge script script/Deploy.s.sol --rpc-url $LOCAL_RPC_URL --broadcast --private-key $LOCAL_TEST_PRIVATE_KEY



2.测试网部署（如 Sepolia）
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify

# 指定测试网部署者私钥：
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify --private-key $PRIVATE_KEY

3.主网部署
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC_URL --broadcast --verify





四、Sepolia 测试网测试

1. 完整测试：必要性

1.1验证真实环境
- 本地测试和测试网环境可能有差异
- 验证合约在真实网络中的表现
- 检查 gas 费用和网络延迟

1.2发现潜在问题
- 权限设置是否正确
- 事件是否正确触发
- 状态变化是否符合预期

2. 测试方式选择

1. 方式1：使用 cast 命令行测试（推荐）
 1.1 测试基本查询功能
    cast call 0x7e937916C0cf01f08ef815E449B1Ce9f82F2aA2E "name()" --rpc-url $SEPOLIA_RPC_URL
    cast call 0x7e937916C0cf01f08ef815E449B1Ce9f82F2aA2E "symbol()" --rpc-url $SEPOLIA_RPC_URL

    // 转码后的结果
    cast call 0x7e937916c0cf01f08ef815e449b1ce9f82f2aa2e "symbol()" --rpc-url $SEPOLIA_RPC_URL | cast to-ascii

1.2 测试铸造功能

    // 检查部署者 sepolia 的 ETH 余额
    cast balance 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 --rpc-url $SEPOLIA_RPC_URL
    
    // 估算 gas 费用
    cast estimate 0x8B42610395a7aD44a64CEbb7FaD629df5bdBc029 "publicMint(address,uint256,string)" 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 3 "http://localhost:3000/sample-metadata.json" --rpc-url $SEPOLIA_RPC_URL

    // 发送交易(铸造 NFT)
    cast send --private-key $PRIVATE_KEY --gas-limit 150000 0x8B42610395a7aD44a64CEbb7FaD629df5bdBc029 "publicMint(address,uint256,string)" 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 3 "http://localhost:3000/sample-metadata.json" --rpc-url $SEPOLIA_RPC_URL

    // 查询 NFT 是否到账
    cast call 0x8B42610395a7aD44a64CEbb7FaD629df5bdBc029 "ownerOf(uint256)" 3 --rpc-url $SEPOLIA_RPC_URL


    // 估算 gas 费用
    失败：cast estimate 0x7e937916c0cf01f08ef815e449b1ce9f82f2aa2e "mint(address,uint256)" 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 1000000000000000000000 --rpc-url $SEPOLIA_RPC_URL

    失败原因：在 cast estimate 命令中，没有指定 --from 参数，所以默认使用零地址作为调用者。

    修正后：cast estimate 0x7e937916c0cf01f08ef815e449b1ce9f82f2aa2e "mint(address,uint256)" 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 1000000000000000000000 --from 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 --rpc-url $SEPOLIA_RPC_URL
    cast estimate 0x7e937916c0cf01f08ef815e449b1ce9f82f2aa2e "mint(address,uint256)" $BUYER1_ADDRESS 10000000000000000000000 --from 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 --rpc-url $SEPOLIA_RPC_URL

    // 发送交易（mint 代币: 先查 gas， 再发送）
    cast send --private-key $PRIVATE_KEY --gas-limit 50000 0x7e937916c0cf01f08ef815e449b1ce9f82f2aa2e "mint(address,uint256)" 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 1000000000000000000000 --rpc-url $SEPOLIA_RPC_URL
    cast send --private-key $PRIVATE_KEY --gas-limit 70000 0x7e937916c0cf01f08ef815e449b1ce9f82f2aa2e "mint(address,uint256)" $BUYER1_ADDRESS 10000000000000000000000 --rpc-url $SEPOLIA_RPC_URL


    // 查询代币余额
    cast call 0x7e937916c0cf01f08ef815e449b1ce9f82f2aa2e "balanceOf(address)" 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 --rpc-url $SEPOLIA_RPC_URL
    cast call 0x7e937916c0cf01f08ef815e449b1ce9f82f2aa2e "balanceOf(address)" BUYER1_ADDRESS --rpc-url $SEPOLIA_RPC_URL

    // 授权（将代币授权给市场合约）
    cast send --private-key $BUYER1_PRIVATE_KEY --gas-limit 80000 $MY_TOKEN_ADDRESS "approve(address,uint256)" $NFT_MARKET_ADDRESS 10000000000000000000000 --rpc-url $SEPOLIA_RPC_URL


    11000,000,000,000,000,000,000

    // 信息解码
    cast to-dec 0x118cdaa70000000000000000000000000000000000000000000000000000000000000000
    cast to-ascii 0x118cdaa70000000000000000000000000000000000000000000000000000000000000000
    cast decode-error 0x118cdaa70000000000000000000000000000000000000000000000000000000000000000


1.3 测试市场功能 (9.3号 测试)
    // 1.估算 gas 费用
    cast estimate 0x8B42610395a7aD44a64CEbb7FaD629df5bdBc029 "approve(address,uint256)" 0x165637F2355f45EC25201B0BECB24f10808D36c3 1 --from 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3 --rpc-url $SEPOLIA_RPC_URL
    return: 51638

    // 2.查询 NFT 是否存在
    cast call 0x8B42610395a7aD44a64CEbb7FaD629df5bdBc029 "ownerOf(uint256)" 1 --rpc-url $SEPOLIA_RPC_URL

    // 3.授权（将nft授权给市场合约， id:1,2）
    cast send --private-key $PRIVATE_KEY 0x8B42610395a7aD44a64CEbb7FaD629df5bdBc029 "approve(address,uint256)" 0x165637F2355f45EC25201B0BECB24f10808D36c3 1 --rpc-url $SEPOLIA_RPC_URL
    cast send --private-key $PRIVATE_KEY 0x8B42610395a7aD44a64CEbb7FaD629df5bdBc029 "approve(address,uint256)" 0x165637F2355f45EC25201B0BECB24f10808D36c3 1 --rpc-url $SEPOLIA_RPC_URL


    # 多次重试
    for i in {1..3}; do
        echo "尝试 $i/3"
        cast send --private-key $PRIVATE_KEY 0x8B42610395a7aD44a64CEbb7FaD629df5bdBc029 "approve(address,uint256)" 0x165637F2355f45EC25201B0BECB24f10808D36c3 1 --rpc-url $SEPOLIA_RPC_URL
        sleep 10
    done

    4.上架（将nft上架， id:1,2）
    // 1.估算 gas 费用
    cast estimate $NFT_MARKET_ADDRESS "listNFT(address,uint256,uint256,address)" $NFT_ADDRESS 1 1000000000000000000 $MY_TOKEN_ADDRESS --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
    return: 202983

    // 2.发送交易
    cast send $NFT_MARKET_ADDRESS "listNFT(address,uint256,uint256,address)" $NFT_ADDRESS 1 1000000000000000000 $MY_TOKEN_ADDRESS --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --gas-limit 220000

    // 3.查询上架是否成功
    cast call $NFT_MARKET_ADDRESS "getListedNft(address,uint256)" $NFT_ADDRESS 1 --rpc-url $SEPOLIA_RPC_URL

    // 3.1 查询并解析
    # 获取数据
    raw_data=$(cast call $NFT_MARKET_ADDRESS "getListedNft(address,uint256)" $NFT_ADDRESS 1 --rpc-url $SEPOLIA_RPC_URL)

    # 解析并显示
    echo "=== NFT 上架信息 ==="
    echo "NFT 合约地址: 0x$(echo $raw_data | cut -c3-66)"
    echo "卖家地址: 0x$(echo $raw_data | cut -c67-130)"
    echo "NFT ID: $(echo "0x$(echo $raw_data | cut -c131-194)" | cast --to-dec)"
    echo "价格: $(echo "0x$(echo $raw_data | cut -c195-258)" | cast --to-dec) wei"
    echo "ERC20 合约地址: 0x$(echo $raw_data | cut -c259-322)"
    
    5. 购买（购买nft， id:1,2）
    // 1.估算 gas 费用 
    cast estimate $NFT_MARKET_ADDRESS "buyNFT(address,uint256,uint256,address)" $NFT_ADDRESS 1 1000000000000000000000 $MY_TOKEN_ADDRESS --rpc-url $SEPOLIA_RPC_URL --private-key $BUYER1_PRIVATE_KEY

    return :
    122583
    
    // 2.发送交易
    // 模拟发送
    cast call $NFT_MARKET_ADDRESS "buyNFT(address,uint256,uint256,address)" $NFT_ADDRESS 1 1000000000000000000000 $MY_TOKEN_ADDRESS --rpc-url $SEPOLIA_RPC_URL --from $BUYER1_ADDRESS

    // 正式发送
    cast send --private-key $BUYER1_PRIVATE_KEY --gas-limit 150000 $NFT_MARKET_ADDRESS "buyNFT(address,uint256,uint256,address)" $NFT_ADDRESS 1 1000000000000000000000 $MY_TOKEN_ADDRESS --rpc-url $SEPOLIA_RPC_URL
    
    // 3.查询购买是否成功

    // 3.1查询上架信息是否已经删除
    cast call $NFT_MARKET_ADDRESS "getListedNft(address,uint256)" $NFT_ADDRESS 1 --rpc-url $SEPOLIA_RPC_URL
    return : 0(表示已经从NFT市场中删除)

    // 3.2查询NFT是否已经转移到买家地址
    cast call $NFT_ADDRESS "ownerOf(uint256)" 1 --rpc-url $SEPOLIA_RPC_URL
    return：
    0x7e02b21efed09a6b14edb17602510bf9fc8178e5（已经是买家地址了）

    // 3.3查询买家代币余额
    cast call $MY_TOKEN_ADDRESS "balanceOf(address)" $BUYER1_ADDRESS --rpc-url $SEPOLIA_RPC_URL
    return: 
    0x000000000000000000000000000000000000000000000405fdf7e5af85e00000
    转换后：19000000000000000000000

    // 3.4查询卖家代币余额
    cast call $MY_TOKEN_ADDRESS "balanceOf(address)" $SELLER_ADDRESS --rpc-url $SEPOLIA_RPC_URL
    return:
    0x0000000000000000000000000000000000000000000002c0bb3dd30c4e200000
    转换后：13000000000000000000000


    
    
    



2. 方式2：使用 Etherscan 界面测试
- 直接在 Etherscan 上调用合约函数
- 可视化界面，便于操作
- 实时查看交易状态

3. 方式3：编写简单的测试脚本
// 创建专门的测试脚本
function testSepoliaDeployment() public {
    // 测试关键功能
    // 验证合约状态
    // 检查事件触发
}


3. 一般测试流程

**第一步：基本功能验证**
# 验证合约基本信息
cast call <ERC20_ADDRESS> "name()"
cast call <ERC20_ADDRESS> "symbol()"
cast call <ERC20_ADDRESS> "totalSupply()"
```

**第二步：核心功能测试**

# 测试 NFT 铸造
cast send --private-key $PRIVATE_KEY <NFT_ADDRESS> "mint(address,uint256,string)" <RECIPIENT> <TOKEN_ID> <URI>

# 测试 NFT 授权
cast send --private-key $PRIVATE_KEY <NFT_ADDRESS> "approve(address,uint256)" <MARKET_ADDRESS> <TOKEN_ID>

# 测试 NFT 上架
cast send --private-key $PRIVATE_KEY <MARKET_ADDRESS> "listNFT(address,uint256,uint256,address)" <NFT_ADDRESS> <TOKEN_ID> <PRICE> <ERC20_ADDRESS>

**第三步：集成测试**
# 测试完整的 NFT 交易流程
# 1. 铸造 NFT
# 2. 授权市场
# 3. 上架 NFT
# 4. 购买 NFT
# 5. 验证状态变化
```

### 4. **测试的重要性**

**发现环境差异**：
- Gas 费用可能不同
- 网络延迟影响用户体验
- 错误处理在真实环境中的表现

**验证用户体验**：
- 交易确认时间
- 错误信息是否清晰
- 操作流程是否顺畅

**确保生产就绪**：
- 验证所有功能正常工作
- 检查安全设置
- 确认事件和状态正确

### 5. **总结建议**

**必须测试**：
- ✅ 核心功能（铸造、上架、购买）
- ✅ 权限控制
- ✅ 事件触发
- ✅ 状态变化

**推荐测试**：
- ✅ 错误处理
- ✅ Gas 费用优化
- ✅ 用户体验验证

**测试方式**：
- 优先使用 `cast` 命令行测试
- 配合 Etherscan 界面验证
- 记录测试结果和发现的问题

注：本地测试通过后， Sepolia 测试网的验证是确保合约生产就绪的关键步骤，必须进行完整的接口测试。

*/