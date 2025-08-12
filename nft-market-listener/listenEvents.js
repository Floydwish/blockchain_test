import { createPublicClient, http, parseAbi, parseAbiItem } from "viem"
import { sepolia } from "viem/chains"
import dotenv from "dotenv"

// 加载环境变量（从.env文件中读取 RPC 地址）
dotenv.config()

// 创建区块链客户端
const client = createPublicClient({
    chain: sepolia,
    transport: http(process.env.RPC_URL)
})


//event NFTListed(address indexed nftContract, uint256 indexed tokenId, uint256 price, address paymentToken);
//event NFTSold(address indexed nftContract, uint256 indexed tokenId, uint256 price, address paymentToken);


// 定义合约地址和事件
const nftMarketAddress ="0x6da6A7F35aaC2AbE018eAdd9D80eCC7C125DEB17";

/*
const nftMarketEvents = [
    parseAbiItem("NFTListed(address indexed nftContract, uint256 indexed tokenId, uint256 price, address paymentToken)"), 
    parseAbiItem("NFTSold(address indexed nftContract, uint256 indexed tokenId, uint256 price, address paymentToken)")
]*/

// events 定义
const events = [
    // 用 ABI 数组格式定义 NFTListed 事件
    {
      name: 'NFTListed',
      type: 'event',
      inputs: [
        { name: 'nftContract', type: 'address', indexed: true },
        { name: 'tokenId', type: 'uint256', indexed: true },
        { name: 'price', type: 'uint256', indexed: false },
        { name: 'paymentToken', type: 'address', indexed: false }
      ]
    },
    // 用 ABI 数组格式定义 NFTSold 事件
    {
      name: 'NFTSold',
      type: 'event',
      inputs: [
        { name: 'nftContract', type: 'address', indexed: true },
        { name: 'tokenId', type: 'uint256', indexed: true },
        { name: 'price', type: 'uint256', indexed: false },
        { name: 'paymentToken', type: 'address', indexed: false }
      ]
    }
  ];

// 事件处理
function handleListedEvent(event) {
    const { nftContract, tokenId, price, paymentToken } = event.args
    console.log("=== 监听到 NFT 上架 ===");
    console.log("NFT 合约地址:", nftContract);
    console.log("NFT 代币ID:", tokenId);
    console.log("NFT 价格:", price);
    console.log("支付代币地址:", paymentToken);
}

function handleSoldEvent(event) {
    const { nftContract, tokenId, price, paymentToken } = event.args
    console.log("=== 监听到 NFT 售出 ===");
    console.log("NFT 合约地址:", nftContract);
    console.log("NFT 代币ID:", tokenId);
    console.log("NFT 价格:", price);
    console.log("支付代币地址:", paymentToken);
}


client.watchBlocks({
    onBlock: (block) => {
      console.log("新区块:", block.number);
    }
  });
  
  client.watchEvent({
    address: nftMarketAddress, // 只监听该地址的合约事件
    events: events,
    onLogs: (logs) => {
      console.log("接收到新日志:", logs);
      // 解析日志
      logs.forEach(log => {
        if(log.eventName != undefined)
            {
                console.log("事件名:", log.eventName);
                console.log("事件参数:", log.args);
            }

      });
    }
  });


async function checkRpc() {
    try {
      const blockNumber = await client.getBlockNumber();
      console.log(`RPC 连接成功！当前区块号：${blockNumber}`);
    } catch (error) {
      console.error("RPC 连接失败！请检查你的 RPC 地址。");
      console.error(error); 
    }
  }
  
  checkRpc();
  
  console.log("正在监听 Sepolia 链上的 NFT 事件...");
