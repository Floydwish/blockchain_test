// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract labubuNFT is ERC721,Ownable,ERC721URIStorage{
    // 定义计数器，生成 NFT 的 唯一ID
    uint256 private _labubuId;

    constructor() ERC721("labubuNFT", "LABUBU") Ownable(msg.sender){
        _labubuId = 0;
    }

    // 函数修改器：只允许合约所有者调用
    /*
    modifier onlyOwner override()
    {
        require(msg.sender == owner(), "Only the owner can call");
        _;
    }*/


    // 铸造NFT
    // 仅管理者可调用
    function safeMint(address to, string memory uri) public onlyOwner {
        // 获取可用的 NFT ID
        uint256 currentLabubuId = _labubuId++;
        
        // 铸造 NFT 并发给目标地址
        _safeMint(to, currentLabubuId);

        // 设置 NFT 的 URI
        _setTokenURI(currentLabubuId, uri);

    }

    // ERC721 标准的一部分，返回 NFT 的 元数据 URI
    // 重写该函数，返回自己设置的 URI
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns(string memory){
        return super.tokenURI(tokenId); //直接调用 ERC721URIStorage中的接口
    }

    // 继承时处理 URI
    function _baseURI() internal pure override returns (string memory)
    {
      //继承 ERC721URIStorage 后可以返回空，因为 tokenURI 会返回完整 URI
        return "";
    }
    

    // ERC721 标准，必须实现
    // 作用：其他合约、平台调用，查询是否支持了 ERC721接口（支持返回 ture)
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage) 
    returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}

/*

{
  "name": "Labubu",
  "description": "lovely labubu！",
  "image": "ipfs://bafkreieowgfk7iy5ol6iah3hbezrp6df2rskmcdje2d2rhqt35i3egmh74/dog1.jpg",
  "attributes": [
    {
      "trait_type": "color",
      "value": "yellow/white"
    }
  ]
}

{
  "name": "Labubu",
  "description": "lovely labubu！",
  "image": "ipfs://bafybeidi2ieyxg263s5bfdgdijl74clglshktmdahg3pppblgt5dafy374/dog2.jpg",
  "attributes": [
    {
      "trait_type": "color",
      "value": "yellow"
    }
  ]
}

{
  "name": "Labubu",
  "description": "lovely labubu！",
  "image": "ipfs://bafybeiasut7ppxwg45h3tia6wcwwh2dauzzstuhl6yxtwl3pwqveye77ri/dog3.jpg",
  "attributes": [
    {
      "trait_type": "color",
      "value": "white"
    }
  ]
}
测试：
ipfs://bafybeicvadz4g6scctvqyier6ep4usyji57lz2raonh7f2sxohrvghg5za/dog1.json
ipfs://bafybeicvadz4g6scctvqyier6ep4usyji57lz2raonh7f2sxohrvghg5za/dog2.json
ipfs://bafybeicvadz4g6scctvqyier6ep4usyji57lz2raonh7f2sxohrvghg5za/dog3.json

https://testnets.opensea.io/assets/sepolia/YOUR_CONTRACT_ADDRESS/YOUR_TOKEN_ID
https://testnets.opensea.io/assets/sepolia/0x2344C218A492a20a6381318591ce2dd2852657AA/0

实现步骤：
一.核心概念和模块
1.ERC721: 以太坊 NFT 标准
2.OpenZeppelin: 标准库，继承，简化开发，安全

二.代码部分
1.引入库
    a.ERC721：提供基本 NFT 功能，如所有权、转账
    b.ERC721URIStorage：扩展库，为每个NFT单独存储元数据的URI
    c.Ownable:提供所有者功能，确保只有合约所有者可以执行特定操作

2.constructor:
    a.命名 NFT、设置符号、指定所有者

3.safeMint:
    a.铸造 NFT
    b.接收参数：目标地址，元数据 URI
    c.实现：为 NFT 生成唯一 ID, 调用 OpenZeppelin 接口完成铸造和URI设置

4.tokenURI
    a.第三方展示NFT 时，调用该函数获取元数据链接

三、图片数据
1.图片：dog1.jpg、dog2.jpg
2.元数据文件: dog1.json, 如下：

{
  "name": "Labubu",
  "description": "lovely labubu！",
  "image": "ipfs://bafkreieowgfk7iy5ol6iah3hbezrp6df2rskmcdje2d2rhqt35i3egmh74/dog1.jpg",
  "attributes": [
    {
      "trait_type": "color",
      "value": "yellow/white"
    }
  ]
}

四、文件上传 去中心化存储
1.IPFS 服务商：Pinata
2.操作：上传图片；上传元数据文件夹
3.使用：元数据文件夹、图片的 CID, 生成 URI


五、部署
1.平台：Remix, Sepolia测试网
2.铸造：调用 safeMint, 传入 接收地址、元数据完整 IPFS 地址
    a.地址示例：ipfs://bafybeicvadz4g6scctvqyier6ep4usyji57lz2raonh7f2sxohrvghg5za/dog1.json
3.查看
    a.metamask: 看到name、symbol、合约地址、代币ID、代币标准等
    b.opensea: 测试网已停止支持

*/