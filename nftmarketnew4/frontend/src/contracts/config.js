/*
###### 阶段3：获取智能合约信息 #####：

一、说明
1. 是什么
- 从部署记录中获取已经部署的合约地址

2. 为什么
- 前端需要知道合约在哪个地址，才能调用正确的合约

3. 怎么做
 3.1 查找部署记录：得到合约部署地址
    - 查看 broadcast 目录下的记录文件，找到每个合约的 deployedAddress
    - 路径：broadcast/Deploy.s.sol/111555111/run-lineaTestnet.json
3.2 获取合约 ABI
    - forge inspect myERC20Token abi --format-json > frontend/src/contracts/myERC20Token.json
    - forge inspect myNFT abi --format-json > frontend/src/contracts/myNFT.json
    - forge inspect myNFTMarket abi --format-json > frontend/src/contracts/myNFTMarket.json

*/

/*
###### 阶段4：创建合约配置 #####：

一、说明
1. 是什么
- 创建统一的合约配置文件，集中管理所有合约的地址和 ABI

2. 为什么
- 避免在多个文件中重复定义合约信息，便于维护和修改

3. 怎么做
- 定义常亮存储合约地址（从部署记录中获取）
- 导入生成的 ABI 文件
- 导出所有配置，供其他文件使用

*/

// 1.导入 ABI
import myERC20TokenAbi from './myERC20Token.json'
import myNFTAbi from './myNFT.json'
import myNFTMarketAbi from './myNFTMarket.json'

// 2.导出合约地址
export const TOKEN_CONTRACT_ADDRESS = '0x7e937916c0cf01f08ef815e449b1ce9f82f2aa2e';      // myERC20Token 部署地址
export const NFT_CONTRACT_ADDRESS = '0xee71072fdd05e2e6a8c513637353a3d6fb21e02b';        // myNFT 部署地址
export const NFT_MARKET_CONTRACT_ADDRESS = '0x165637f2355f45ec25201b0becb24f10808d36c3'; // myNFTMarket 部署地址

// 3.导出合约 ABI
export const TOKEN_ABI = myERC20TokenAbi;
export const NFT_ABI = myNFTAbi;
export const NFT_MARKET_ABI = myNFTMarketAbi;