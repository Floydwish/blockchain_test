/*
############ 阶段5：实现基础 App.jsx ############
一、说明
1. 是什么
- 创建主应用组件，实现基本的钱包连接和状态显示

2. 为什么
- 整个应用的核心，用户通过这个界面与区块链交互

3. 怎么做
- ConnectButton: RainbowKit 提供的钱包连接按钮
- useAccount: Wagmi 提供的获取钱包地址的 hook
- useChainId: Wagmi 提供的获取当前链 ID 的 hook
- 条件渲染：根据连接状态显示不同内容

*/


/*
####### 阶段7：实现代币余额显示 #########
一、说明
1. 是什么
- 读取用户钱包中的代币余额并显示

2. 为什么
- 用户需要知道自己的代币余额，才能决定是否购买 NFT

3. 怎么做
- useReadContract: wagmi hook, 用于读取合约数据
- balanceOf: 代币合约函数，用于返回指定地址的代币余额
- formatEther: viem 函数，用于将 wei 转换为 ether 单位，便于显示
- enabled: isConnected ： 只有钱包连接后才读取余额

*/

/*
####### 阶段8：实现 NFT 铸造功能 #########
一、说明
1. 是什么
- 实现用户铸造 NFT 的功能

2. 为什么
- 用户需要先有 NFT, 才能上架销售

3. 怎么做
- useState: 管理输入框的值和铸造状态
- useWriteContract: wagmi hook, 用于调用合约函数进行写入
- publicMint: NFT 合约函数，用于铸造新的 NFT
- 状态管理：铸造过程中禁用按钮，防止重复操作
- 错误处理：捕获并显示铸造失败的原因
*/

/*
####### 阶段9：实现 NFT 上架功能 #########
一、说明
1. 是什么
- 实现用户将 NFT 上架销售的功能

2. 为什么
- 用户需要将 NFT 上架销售，才能让其他人购买

3. 怎么做
- listNFT: NFTMarket 合约函数，将 NFT 上架销售
- BigInt(tokenId): 将字符串转换为大整数，符合 Solidity 的 uint256 类型
- parseEther(price): 将价格转换为 wei 单位
- 参数顺序：NFT 合约地址、NFT ID、价格、支付代币地址
- 状态重置：成功后清空输入框，重置状态
*/

/*

####### 阶段10：实现 NFT 购买功能 #########
一、说明
1. 是什么
- 实现用户购买已上架 NFT 的功能

2. 为什么
- NFT 市场核心功能，让用户能够交易 NFT

3. 怎么做
- buyNFT: NFTMarket 合约函数，执行 NFT 购买
- 参数：NFT 合约地址、NFT ID、支付代币地址
- 状态管理：购买过程中禁用按钮，防止重复操作
- 成功处理：购买成功后清空输入框，显示成功消息
*/

/*

####### 阶段11：授权功能 #########
一、说明
1. 是什么
- 实现用户授权市场合约使用其代币的功能

2. 为什么
- ERC20 代币的安全机制，用户需要授权代币给市场合约，市场合约才能转移代币

3. 怎么做
- approve: 代币合约的函数，用于授权市场合约使用其代币
- 参数：被授权地址（市场合约）、授权金额
- 授权金额：通常设置为要购买的 NFT 的价格
- 安全考虑：用户主动点击授权才会执行
*/

/*
####### 阶段12：功能完善 #########

一、添加网络检查
1. 目的
- 确保用户连接到正确的网络（这里是 Sepolia 网络）

2. 实现
- chainId === 11155111 时，显示 Sepolia 网络
- 条件渲染：网络不匹配是显示警告
- 用户指导：明确告知需要切换到 Sepolia 网络


二、添加 NFT 余额显示
1. 目的
- 显示用户钱包中的 NFT 余额
- 用户需要知道自己有多少 NFT，才能决定是否上架

2. 实现
- balanceOf: NFT 合约函数，用于返回指定地址的 NFT 数量
- toString: 将 BigInt 转换为字符串，便于显示
- 条件显示：有余额时显示数字，没有余额时显示0

*/

/*
todo:
1. 对比检查：还差什么功能
2. 对比检查：细节
3. 功能调试
4. 完整测试
*/


import { useState, useEffect} from 'react'
import {ConnectButton} from '@rainbow-me/rainbowkit';
import {useAccount, useChainId, useReadContract, useWriteContract} from 'wagmi';
import './App.css'

import { parseEther,formatEther } from 'viem';
import { TOKEN_CONTRACT_ADDRESS, NFT_CONTRACT_ADDRESS, NFT_MARKET_CONTRACT_ADDRESS, TOKEN_ABI, NFT_ABI, NFT_MARKET_ABI } from './contracts/config';


function App() {

  // 一、状态设置与初始化
  // 1. 操作相关的状态
  const {address, isConnected} = useAccount(); // 获取钱包地址和连接状态
  const chainId = useChainId();                // 获取当前链 ID

  // 铸造 NFT 相关状态
  const [nftUri, setNftUri] = useState('');
  const [isMinting, setIsMinting] = useState(false);
  const [mintHash, setMintHash] = useState('');

  // 上架 NFT 相关状态
  const [tokenId, setTokenId] = useState('');
  const [price, setPrice] = useState('');
  const [isListingLoading, setIsListingLoading] = useState(false);

  // 购买 NFT 相关状态
  const [buyTokenId, setBuyTokenId] = useState('');
  const [isBuying, setIsBuying] = useState(false);

  // 2. 加载相关的状态
  const [isListLoading, setIsListLoading] = useState(false);
  const [isBuyingLoading, setIsBuyingLoading] = useState(false);
  const [isApprovingLoading, setIsApprovingLoading] = useState(false);
  const [isApprovingERC20Loading, setIsApprovingERC20Loading] = useState(false);
  const [isMintingLoading, setIsMintingLoading] = useState(false);
  const [isTransferLoading, setIsTransferLoading] = useState(false);
  const [transferAmount, setTransferAmount] = useState('');
  const [transferTo, setTransferTo] = useState('');


  // 二、读取合约数据
  // 1.读取用户钱包中的ERC20代币余额
  const { data: tokenBalance } = useReadContract({
    address: TOKEN_CONTRACT_ADDRESS,
    abi: TOKEN_ABI,
    functionName: 'balanceOf',
    args: [address],
    enabled: isConnected,
  });

  // 2. 读取用户钱包中的 NFT 余额
  const { data: nftBalance } = useReadContract({
    address: NFT_CONTRACT_ADDRESS,
    abi: NFT_ABI,
    functionName: 'balanceOf',
    args: [address],
    enabled: isConnected,
  });

  // 三、写入合约数据

  // 铸造 NFT函数
  const {data: mintData,writeContract: mintNFT, isSuccess: isMintSuccess, isError: isMintError, error: mintError, isPending: isMintPending } = useWriteContract();

  // 授权 NFT 函数
  const {data: approveNFTData, writeContract: approveNFT, isSuccess: isApproveNFTSuccess, isError: isApproveError, error: approveError, isPending: isApproveNFTPending} = useWriteContract();

  // 上架 NFT 函数
  const {data: listData,writeContract: listNFT, isSuccess: isListSuccess, isError: isListError, error: listError, isPending: isListPending } = useWriteContract();

  // 购买 NFT 函数
  const {data: buyData,writeContract: buyNFT, isSuccess: isBuySuccess, isError: isBuyError, error: buyError, isPending: isBuyPending } = useWriteContract();

  // 转账 ERC20 代币函数
  const {data: transferData, writeContract: transferToken, isSuccess: isTransferSuccess, isError: isTransferError, error: transferError, isPending: isTransferPending} = useWriteContract();

  // 授权代币函数
  const {data: approveData,writeContract: approveToken, isSuccess: isApproveTokenSuccess, isError: isApproveTokenError, error: approveTokenError, isPending: isApproveTokenPending } = useWriteContract();

  // 铸造 NFT 功能
  const handleMintNFT = () => {
    // 1.检查输入 nftUri 是否为空
    if (!nftUri) return;

    // 2. 检查 NFT 合约的铸造函数是否可用
    if(!mintNFT){
      console.error('mintNFT 函数未定义，可能的原因：');
      console.error('1. 合约地址无效');
      console.error('2. 合约 ABI 无效');
      console.error('3. 网络不匹配');
      console.error('4. 钱包未正确连接');
      return;
    }

    // 3. 设置状态：正在铸造
    setIsMintingLoading(true);

    // 4. 调用铸造函数
    mintNFT({
      address: NFT_CONTRACT_ADDRESS,
      abi: NFT_ABI,
      functionName: 'publicMint',
      args: [nftUri],
    })
  };

  // 授权 NFT 功能
  const handleApproveNFT = () => {
    // 检查输入 tokenId 是否为空
    if(!tokenId) return;

    // 检查 NFT 合约的授权函数是否可用
    if(!approveNFT){
      console.error('approveNFT 函数未定义');
      alert('授权功能不可用');
      return;
    }

    // 设置状态：正在授权
    setIsApprovingLoading(true);

    // 调用授权函数
    approveNFT({
      address: NFT_CONTRACT_ADDRESS,
      abi: NFT_ABI,
      functionName: 'approve',
      args: [NFT_MARKET_CONTRACT_ADDRESS, tokenId],
    });
  }

  // 上架 NFT 功能
  const handleListNFT = () => {
    // 检查输入 tokenId 和 price 是否为空
    if (!tokenId || !price) return;

    // 设置状态：正在上架
    setIsListingLoading(true);

    // 检查 NFT 合约的授权函数是否可用
    if(!listNFT){
      console.error('listNFT 函数未定义');
      alert('上架功能不可用');
      return;
    }

    // 调用上架函数
    listNFT({
      address: NFT_MARKET_CONTRACT_ADDRESS,
      abi: NFT_MARKET_ABI,
      functionName: 'listNFT',
      args: [NFT_CONTRACT_ADDRESS, tokenId, parseEther(price), TOKEN_CONTRACT_ADDRESS],
    });
  }

  // 授权代币功能
  const handleApproveToken = () => {
    // 检查输入 price 是否为空
    if(!price) return;

    approveToken({
      address: TOKEN_CONTRACT_ADDRESS,
      abi: TOKEN_ABI,
      functionName: 'approve',
      args: [
        NFT_MARKET_CONTRACT_ADDRESS,
        parseEther(price)
      ],
    });
  }

  // 购买 NFT 功能
  const handleBuyNFT = () => {
    // 检查输入 buyTokenId 是否为空
    if(!buyTokenId) return;

    // 设置状态：正在购买
    setIsBuying(true);

    // 检查 NFT 合约的购买函数是否可用
    if(!buyNFT){
      console.error('buyNFT 函数未定义');
      alert('购买功能不可用');
      return;
    }

    // 调用购买函数
    buyNFT({
      address: NFT_MARKET_CONTRACT_ADDRESS,
      abi: NFT_MARKET_ABI,
      functionName: 'buyNFT',
      args: [
        NFT_CONTRACT_ADDRESS,
        BigInt(buyTokenId),
        parseEther(price),
        TOKEN_CONTRACT_ADDRESS
      ]
    });
  }

  // 转账 ERC20 代币功能
  const handleTransferToken = () => {
    // 检查输入价格是否为空
    if(!transferTo || !transferAmount) return;

    alert('transferTo: ' + transferTo + ' transferAmount: ' + transferAmount);

    // 检查 NFT 合约的转账函数是否可用
    if(!transferToken){
      console.error('transferToken 函数未定义');
      alert('转账功能不可用');
      return;
    }

    // 设置状态：正在转账
    setIsTransferLoading(true);

    // 调用转账函数
    transferToken({
      address: TOKEN_CONTRACT_ADDRESS,
      abi: TOKEN_ABI,
      functionName: 'transfer',
      args: [transferTo, parseEther(transferAmount)],
    });
  }

  // 授权代币功能
  const handleApproveERC20Token = () => {
    // 检查输入价格是否为空
    if(!price) return;
    
    // 检查 NFT 合约的授权函数是否可用
    if(!approveToken){
      console.error('approveToken 函数未定义');
      alert('授权功能不可用');
      return;
    }

    // 设置状态：正在授权
    setIsApprovingERC20Loading(true);

    // 调用授权函数
    approveToken({
      address: TOKEN_CONTRACT_ADDRESS,
      abi: TOKEN_ABI,
      functionName: 'approve',
      args: [NFT_MARKET_CONTRACT_ADDRESS, parseEther(price)],
    });
  }

    // 四、事件监听
  // 1. 监听铸造状态变化
  // 1.1 铸造成功
  useEffect(() => {
    if(isMintSuccess){
      console.log('NFT 铸造成功: ', mintData);
      const hash = mintHash || mintData?.hash || '交易已提交, 请查看钱包确认';

      alert('NFT 交易已提交, 请查看钱包确认');
      
      setIsMintingLoading(false);  // 设置正在铸造状态为 false
      setMintHash('');             // 清空交易哈希
      setNftUri('');               // 清空输入框
    }
  },[isMintSuccess, mintData, mintHash]);

  // 1.2 铸造失败
  useEffect(() => {
    if(isMintError && mintError){
      console.error('NFT 铸造失败: ', mintError);
      alert('NFT 铸造失败: ' + mintError.message);

      setIsMintingLoading(false);  // 设置正在铸造状态为 false

    }
  },[isMintError, mintError]);

  // 2. 监听授权状态变化
  // 2.1 授权成功
  useEffect(() => {
    if(isApproveNFTSuccess){
      console.log('NFT 授权已提交, 请查看钱包确认: ', approveData);
      alert('NFT 授权已提交, 请查看钱包确认');
      setIsApprovingLoading(false);
    }
  },[isApproveNFTSuccess, approveData]);

  // 2.2 授权失败
  useEffect(() => {
    if(isApproveError && approveError){
      console.error('NFT 授权失败: ', approveError);
      alert('NFT 授权失败: ' + approveError.message);
      setIsApprovingLoading(false);
    }
  })

  // 3. 监听上架状态变化
  // 3.1 上架成功
  useEffect(() => {
    if(isListSuccess){
      console.log('NFT 上架交易已提交, 请查看钱包确认: ', listData);
      alert('NFT 上架交易已提交, 请查看钱包确认');
      setIsListingLoading(false);
    }
  },[isListSuccess, listData]);

  // 3.2 上架失败
  useEffect(() => {
    if(isListError && listError){
      console.error('NFT 上架失败: ', listError);
      alert('NFT 上架失败: ' + listError.message);
      setIsListingLoading(false);
    }
  },[isListError, listError]);

  // 4. 监听购买状态变化
  // 4.1 购买成功
  useEffect(() => {
    if(isBuySuccess){
      console.log('NFT 购买已提交, 请查看钱包确认: ', buyData);
      alert('NFT 购买已提交, 请查看钱包确认');
      setIsBuyingLoading(false);
    }
  },[isBuySuccess, buyData]);

  // 4.2 购买失败
  useEffect(() => {
    if(isBuyError && buyError){
      console.error('NFT 购买失败: ', buyError);
      alert('NFT 购买失败: ' + buyError.message);
      setIsBuyingLoading(false);
    }
  },[isBuyError, buyError]);

  // 5. 监听 Token 转账状态变化
  // 5.1 转账成功
  useEffect(() => {
    if(isTransferSuccess){
      console.log('ERC20 转账已提交, 请查看钱包确认:', transferData);
      alert('ERC20 转账已提交, 请查看钱包确认');
      setIsTransferLoading(false);
    }
  },[isTransferSuccess, transferData]);
  // 5.2 转账失败
  useEffect(() => {
    if(isTransferError && transferError){
      console.error('ERC20 转账失败: ', transferError);
      alert('ERC20 转账失败：' + transferError.message);
      setIsTransferLoading(false);
    }
  },[isTransferError, transferError]);


  // 6. 监听代币授权状态变化
  // 6.1 授权成功
  useEffect(() => {
    if(isApproveTokenSuccess){
      console.log('ERC20 授权已提交, 请查看钱包确认: ', approveData);
      alert('ERC20 授权已提交, 请查看钱包确认');
      setIsApprovingERC20Loading(false);
    }
  },[isApproveTokenSuccess, approveData]);
  // 6.2 授权失败
  useEffect(() => {
    if(isApproveTokenError && approveTokenError){
      console.error('ERC20 授权失败: ', approveTokenError);
      alert('ERC20 授权失败: ' + approveTokenError.message);
      setIsApprovingERC20Loading(false);
    }
  },[isApproveTokenError, approveTokenError]);

  return (
    <div className="App">
      <header className="App-header">
        <h1>Marvin's NFT Market DApp</h1>
        <ConnectButton />
      </header>
      <main className="App-main">
        {isConnected ? (   // 钱包已连接
          <div className="market-container">
            <div className="user-info">
              <h2>用户信息</h2>
              <p>地址: {address}</p>
              <p>当前网络: {chainId === 11155111 ? 'Sepolia' : `Chain ID: ${chainId}`}</p>
              <p>代币余额: {tokenBalance ? formatEther(tokenBalance) : '0'} MTK</p>
              <p>NFT余额: {nftBalance ? nftBalance.toString() : '0'} 个</p>
            
              {chainId !== 11155111 && ( // 网络不匹配时显示警告
                <div style={{ marginTop: '15px', padding: '10px', backgroundColor: 'rgba(255, 215, 0, 0.2)', borderRadius: '8px', border: '1px solid #ffd700' }}>
                  <h4 style={{ margin: '0 0 10px 0', color: '#ffd700' }}>⚠️ 网络不匹配</h4>
                  <p style={{ margin: '0', fontSize: '0.9rem', color: '#ffd700' }}>
                    当前连接到 Chain ID: {chainId}，但此 DApp 需要 Sepolia 测试网 (Chain ID: 11155111)
                  </p>
                  <p style={{ margin: '10px 0 0 0', fontSize: '0.8rem', color: '#ffd700' }}>
                    💡 请在您的钱包中切换到 Sepolia 测试网
                  </p>
                </div>
              )}
            </div>
            <div className="market-actions">
              <div className="action-section">
                <h3>铸造 NFT</h3>
                <div className="form-group">
                  <lable> NFT URI (元数据连接) </lable>
                  <input 
                    type="text"
                    value={nftUri}
                    onChange={(e) => setNftUri(e.target.value)}
                    placeholder="请输入 NFT 元数据 URI (如： https://example.com/metadata.json)"
                    />
                </div>
                <button 
                  onClick={handleMintNFT} 
                  disabled={isMintingLoading || !nftUri} > 
                  {isMintingLoading ? '铸造中...' : '铸造 NFT'}
                  </button>
              </div>
              <div className="action-section">
                <h3>上架 NFT</h3>
                <div className="form-group">
                  <lable> NFT ID  </lable>
                  <input 
                    type="number"
                    value={tokenId}
                    onChange={(e) => setTokenId(e.target.value)}
                    placeholder="请输入 NFT ID"
                    />
                </div>
                <div className="form-group">
                  <lable> 价格 (MTK)  </lable>
                  <input 
                    type="number"
                    value={price}
                    onChange={(e) => setPrice(e.target.value)}
                    placeholder="请输入价格"
                    />
                </div>
                <button 
                  onClick={handleApproveNFT}
                  disabled={isApprovingLoading || !tokenId}
                  style={{ marginRight: '10px'}}
                  >
                    {isApprovingLoading ? '授权中...' : '授权 NFT'}
                  </button>
                <button 
                onClick={handleListNFT} disabled={isListingLoading || !tokenId || !price} 
                >
                  {isListingLoading ? '上架中...' : '上架 NFT'}
                  </button>
              </div>
              <div className="action-section">
                <h3>购买 NFT</h3>
                <div className="form-group">
                  <lable> NFT ID  </lable>
                  <input 
                    type="number"
                    value={buyTokenId}
                    onChange={(e) => setBuyTokenId(e.target.value)}
                    placeholder="请输入要购买的 NFT ID"
                    />
                </div>
                <div className="form-group">
                  <lable> 价格 (MTK)  </lable>
                  <input 
                    type="number"
                    value={price}
                    onChange={(e) => setPrice(e.target.value)}
                    placeholder="请输入价格"
                    />
                </div>
                <button 
                onClick={handleApproveToken}
                disabled={isApprovingERC20Loading || !price}
                >
                  {isApprovingERC20Loading ? '授权中...' : '授权代币'}
                </button>
                <button 
                onClick={handleBuyNFT} 
                disabled={isBuyingLoading || !buyTokenId} 
                >
                  {isBuyingLoading ? '购买中...' : '购买 NFT'}
                </button>
              </div>

              <div className="action-section">
                <h3>转账 ERC20 代币</h3>
                <div className="form-group">
                  <lable> 接收地址  </lable>
                  <input 
                    type="text"
                    value={transferTo}
                    onChange={(e) => setTransferTo(e.target.value)}
                    placeholder="请输入接收地址"
                    />
                </div>
                <div className="form-group">
                  <lable> 转账数量 (MTK)  </lable>
                  <input 
                    type="number"
                    value={transferAmount}
                    onChange={(e) => setTransferAmount(e.target.value)}
                    placeholder="请输入转账数量"
                    />
                    <button
                    onClick={handleTransferToken}
                    disabled={isTransferLoading || !transferTo || !transferAmount}
                    >
                      {isTransferLoading ? '转账中...' : '转账 ERC20 代币'}
                    </button>
                    <div style={{ marginTop: '10px', fontSize: '0.8rem', color: '#ffd700' }}>
                      💡 提示：转账后切换到另一个钱包进行购买
                    </div>
                </div>
              </div>
            </div>

          </div>
        ) : (              // 钱包未连接
          <div>
            <h2>🎉 NFT 市场已部署！🎉</h2>
            <p>连接钱包后，您可以上架和购买 NFT</p>
          </div>

        )}
      </main>
    </div>
  )
}

export default App

/*
####### 1. 理解：状态管理（声明式编程） #########
一、我需要做的
1. 声明状态：useState
2. 更新状态：setState(newState)
3. 描述界面：根据状态描述界面

二、React 会做的
1. 监听状态变化
2. 重新渲染组件
3. 界面更新
*/

/*
####### 2. 理解：合约写入 #########
一、writeContract 理解
1. 返回对象：
- 包含：data, writeContract, isPending, isSuccess, isError, error
- 其中方法是：writeContract
- 我的处理：将 writeContract 设置别名（如 mintNFT)，用于后续调用

2. 主要功能
1. 事实是：每个合约写入函数都是调用的 writeContract（只是用了不同的别名）

2. 不同的合约写入功能如何实现？
- 答案：通过传入不同的参数实现不同功能：合约地址、合约 ABI、函数名、参数
- 总结：useWriteContract 返回同样的对象，差异只在调用时传入的参数不同，从而实现不同的合约写入功能
- 原理：Hook 提供统一的接口，通过不同参数调用不同的合约函数
*/

/*
####### 3. 理解：交易监听 #########
一、核心接口
1. useEffect
2. useWriteContract

二、核心原理
1. 数组值变化 => useEffect 被调用

三、简单过程
1. 声明状态：useWriteContract => 返回对象
2. 用户触发事件 => 调用写入函数 => 触发状态变化 
2. 监听状态变化：[isMintSuccess, mintData, mintHash]);
4. 触发对应 useEffect 执行 => 不同的状态对应不同的处理

四、useEffect 对比 .then()/.catch()
1. 推荐方式：useEffect
2. 原因
- a. 异常处理：useEffect 能捕获异常或错误，替代.catch()
- b. 状态处理：统一处理状态变化，避免分散在 .then()/.catch() 中
- c. 简洁清晰：useEffect 更简洁，更易读

*/

/*
一、已完成：
1. 铸造、授权NFT、上架、授权代币、购买（主流程）

TODO:
一、各子项功能的单独测试
1. 钱包连接
  a. v手机钱包
  b. v插件钱包
  c. v网络切换
  d. v连接后显示信息
  
2. ERC20 代币
  a. v铸造
  b. v授权 : 注意单位
  c. v转账
  d. v查询余额
3. NFT
  a. v铸造
  b. v授权
  d. v查询余额
4. NFT Market
  a. v上架
  b. v购买(这里是以授权金额和 NFT 价格为准，与界面输入的价格无关)
  d. v查询上架列表中的某个 NFT 是否上架

2. 测试过程中遇到的问题的解决，优化（部分界面优化，NFT 合约优化）

3. 复盘项目
*/
