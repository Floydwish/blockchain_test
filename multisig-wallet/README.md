# 一、部署
## 1. 命令
 forge create --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --broadcast --verify \
  src/MyNFT.sol:labubuNFT

  forge create --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY  \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --broadcast --verify \
  src/MultiSigWallet.sol:MultiSigWallet \
  --constructor-args '[0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3,0x7E02b21eFed09a6B14EDb17602510bF9FC8178e5, 0x9904700Fb68003E8c48BF746156Fb51B559C1A77]' 2
 

## 2.部署返回：
Deployer: 0x25f0e8D1f862a28Ed75d09C0aA27014b173d83f3
Deployed to: 0xEF47A33493Ad05a9c65086600CB661e4E881250c
Transaction hash: 0x457dbe2af46dda781ad837eb90de06ac881e0910694ddbd4d1f918ebb0223379
Starting contract verification...
Waiting for sourcify to detect contract deployment...
Start verifying contract `0xEF47A33493Ad05a9c65086600CB661e4E881250c` deployed on sepolia
Compiler version: 0.8.30
Constructor args: 00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000300000000000000000000000025f0e8d1f862a28ed75d09c0aa27014b173d83f30000000000000000000000007e02b21efed09a6b14edb17602510bf9fc8178e50000000000000000000000009904700fb68003e8c48bf746156fb51b559c1a77

Submitting verification for [src/MultiSigWallet.sol:MultiSigWallet] 0xEF47A33493Ad05a9c65086600CB661e4E881250c.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (4 tries remaining)

Submitting verification for [src/MultiSigWallet.sol:MultiSigWallet] 0xEF47A33493Ad05a9c65086600CB661e4E881250c.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (3 tries remaining)

Submitting verification for [src/MultiSigWallet.sol:MultiSigWallet] 0xEF47A33493Ad05a9c65086600CB661e4E881250c.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (2 tries remaining)

Submitting verification for [src/MultiSigWallet.sol:MultiSigWallet] 0xEF47A33493Ad05a9c65086600CB661e4E881250c.
Submitted contract for verification:
        Response: `OK`
        GUID: `7cvp4stjfpiqfe1m6r4vstc7hphbyqkx4ij6zgytudasz2nqfy`
        URL: https://sepolia.etherscan.io/address/0xef47a33493ad05a9c65086600cb661e4e881250c
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified


# 二、测试
## 1.查看合约基本信息
在 Etherscan 合约页面 → “Contract” → “Read Contract”：
a.调用 getOwners()：确认返回部署时传入的 3 个地址。
b.调用 threshold()：确认返回签名门槛（如 2）。
c.调用 getBalance()：查看合约当前 ETH 余额（初始应为 0，需先转账）。

## 2. 向合约转入 ETH
a.用小狐狸钱包，向合约地址转账少量 Sepolia ETH（如 0.03 ETH），用于测试提案转账功能。
b.转账后通过 getBalance() 确认合约余额已更新。

## 3. 创建提案
a. 在 Etherscan 合约页面 → “Contract” → “Write Contract”;
b. 连接一个多签持有人的钱包（用MetaMask，切换到 Sepolia 网络）：
c. 调用 createProposal 函数，参数示例：
    to：任意测试地址（如另一个钱包地址）。
    value：转账金额（如 100000000000000000 即 0.1 ETH）。
    data：留空（0x）。
    description：输入提案描述（如 “Test transfer”）。
d.提交交易并等待上链，记录返回的 proposalId（从 0 开始）。

## 4. 确认提案
a. 切换到另一个多签持有人的钱包（需 2 个及以上确认，达到门槛）：
b.调用 confirmProposal 函数，传入上述 proposalId。
c.确认后通过 getProposal(proposalId) 查看 confirmations 计数是否增加。

## 5. 执行提案
a.检查确认数，当确认数达到门槛（如 2 个）后，任何人可执行提案：
b.调用 executeProposal 函数，传入 proposalId。
c.执行成功后，通过以下方式验证：
    i.查看提案的 executed 字段是否为 true。
    ii.检查目标地址的余额是否增加了提案中指定的 ETH 数量。
    iii.检查合约余额是否相应减少。

6. 测试添加 / 移除持有人（待后续添加）