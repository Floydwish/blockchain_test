//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 
合约设计说明：

一、项目所需功能
1. 给指定地址铸造 NFT
2. 授权指定地址可以转移 NFT（NFT市场合约）

二、权限
1. 合约拥有者可以铸造 NFT
2. 任何人可以铸造 NFT (测试用)

三、实现
1. 铸造 NFT: 继承 ERC721 合约
2. 授权指定地址可以转移 NFT：使用 ERC721 合约中的 approve 函数
3. 权限控制：使用 Ownable 合约实现合约拥有者管理
*/

// 导入 openzeppelin 的 ERC721 合约，用于实现 ERC721 代币的标准功能
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

// 导入 openzeppelin 的 Ownable 合约
import "openzeppelin-contracts/contracts/access/Ownable.sol";

// 导入 openzeppelin 的 ERC721URIStorage 合约，用于实现 ERC721 代币的 URI 存储功能
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


import {console} from "forge-std/console.sol";

// 继承顺序影响后续的父合约功能调用
contract myNFT is ERC721, Ownable, ERC721URIStorage { 

    // 下一个可用的 token ID
    uint256 private _tokenId = 0;

    constructor() ERC721("MyNFT", "NFT") Ownable(msg.sender) {}

    // 铸造 NFT
    function mint(address to, string memory uri) public onlyOwner {

        require(to != address(0), "Invalid address");
        require(bytes(uri).length > 0, "Invalid URI");

        // 铸造 NFT : ERC721 合约中的 _safeMint 函数
        _safeMint(to, _tokenId); // 自动递增，确保每次铸造的 tokenId 都是唯一的

        // 设置 NFT 的 URI : ERC721URIStorage 合约中的 _setTokenURI 函数
        _setTokenURI(_tokenId, uri);

        _tokenId++;
    }

    // 公共铸造 NFT
    function publicMint(string memory uri) public {

        require(bytes(uri).length > 0, "Invalid URI");

        // 铸造 NFT : ERC721 合约中的 _safeMint 函数
        _safeMint(msg.sender, _tokenId);

        // 设置 NFT 的 URI : ERC721URIStorage 合约中的 _setTokenURI 函数
        _setTokenURI(_tokenId, uri);

        _tokenId++;
    }

    /*
    ERC721 基础合约有一个 tokenURI 函数实现（第76行）
    ERC721URIStorage 扩展合约重写了 tokenURI 函数（第31行）
    当一个合约继承多个父合约且这些父合约有相同的函数时，Solidity 要求子合约必须明确重写这个函数来解决钻石问题（Diamond Problem）。
    */
    // 重写 tokenURI 函数，用于返回 NFT 的 URI
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        
        // 线性化规则，继承顺序从右到左，最右边的合约优先级最高
        // 因此调用 super.tokenURI(tokenId) 会调用 ERC721URIStorage 合约中的 tokenURI 函数
        return super.tokenURI(tokenId);
    }

    // 重写 supportsInterface 函数，用于支持 ERC721URIStorage 合约的接口
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage) returns (bool) {
        
        // 线性化规则，继承顺序从右到左，最右边的合约优先级最高
        // 因此调用 super.supportsInterface(interfaceId) 会调用 ERC721URIStorage 合约中的 supportsInterface 函数
        return super.supportsInterface(interfaceId);
    }

    // 获取 NFT 信息
    function _ownerOf(uint256 tokenId) internal view override returns (address) {

        require(tokenId <= _tokenId, "NFT not exists");
        return super._ownerOf(tokenId);
    }
}

