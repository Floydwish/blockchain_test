// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
合约设计说明：

一、项目所需功能
1. 上架 NFT (任意符合 ERC721 标准的 NFT)
2. 购买 NFT (任意符合 ERC20 标准的代币)

二、权限控制
无

三、实现
1. 上架 NFT：使用 IERC721 接口实现
2. 购买 NFT：使用 IERC20 接口实现

四、事件
1. NFT 上架事件
2. NFT 购买事件

*/

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {console} from "forge-std/console.sol";

contract myNFTMarket {
    // 上架 NFT 信息结构体
    struct listInfo {
        address nftAddress;  // NFT 合约地址
        address seller;      // 卖家地址
        uint256 nftId;        // NFT ID
        uint256 price;        // 价格
        address erc20Address; // 付款代币合约地址
    }

    // 上架 NFT 列表
    // NFT 合约地址 => NFT ID => 上架信息
    mapping(address => mapping(uint256 => listInfo)) public listedNft;

    constructor(){}

    event ListNFT(address indexed nftAddress, uint256 indexed nftId, uint256 price, address erc20Address);
    event BuyNFT(address indexed nftAddress, uint256 indexed nftId, uint256 price, address erc20Address);

    // 上架 NFT
    function listNFT(address nftAddress, uint256 nftId, uint256 price, address erc20Address) public {

        console.log("nftAddress", nftAddress);
        console.log("nftId", nftId);
        console.log("msg.sender", msg.sender);
        //console.log("IERC721(nftAddress).ownerOf(nftId)", IERC721(nftAddress).ownerOf(nftId));

        // 1. 检查 NFT 合约地址是否正常
        console.log("address(0)", address(0));
        require(nftAddress != address(0), "NFT contract address is invalid");
        console.log("11111111");

        // 2. 检查 NFT 是否存在
        IERC721 nftContract = IERC721(nftAddress);
        console.log("89999999", nftContract.ownerOf(nftId));
        require(nftContract.ownerOf(nftId) != address(0), "NFT not exists");

        // 3. 检查 NFT 是否是卖家所有
        require(IERC721(nftAddress).ownerOf(nftId) == msg.sender, "You are not the owner of this NFT");


        // 4. 检查 NFT 是否已经上架
        require(listedNft[nftAddress][nftId].nftAddress == address(0), "NFT already listed");

        // 5. 检查 NFT 是否授权给市场合约
        require(nftContract.getApproved(nftId) == address(this), "NFT not approved");

        // 6. 检查代币合约地址是否正常
        require(erc20Address != address(0), "ERC20 contract address is invalid");

        // 7. 检查价格是否大于0
        require(price > 0, "Price must be greater than 0");

        // 8. 将 NFT 转移到市场合约
        nftContract.transferFrom(msg.sender, address(this), nftId);

        // 9. 上架
        listedNft[nftAddress][nftId] = listInfo(nftAddress, msg.sender,nftId, price, erc20Address);

        // 10. 触发上架事件
        emit ListNFT(nftAddress, nftId, price, erc20Address);
    }

    // 购买 NFT
    function buyNFT(address nftAddress, uint256 nftId, uint256 price, address erc20Address) public {
        // 1. 检查 NFT 合约地址是否正常
        require(nftAddress != address(0), "NFT contract address is invalid");

        // 3. 检查 NFT 是否已经上架
        require(listedNft[nftAddress][nftId].nftAddress != address(0), "NFT not listed");

        // 4. 检查代币合约地址是否正常
        require(erc20Address != address(0), "ERC20 contract address is invalid");

        // 5. 检查买家代币余额是否充足
        IERC20 erc20Contract = IERC20(erc20Address);
        require(erc20Contract.balanceOf(msg.sender) >= price, "Insufficient balance");

        // 7. 检查买家代币授权给市场合约的额度
        require(erc20Contract.allowance(msg.sender, address(this)) >= price ,"Insufficient allowance");

        // 8. 检查价格是否大于0
        require(price > 0, "Price must be greater than 0");

        // 9. 将代币从买家转移到卖家
        require(erc20Contract.transferFrom(msg.sender, listedNft[nftAddress][nftId].seller, price), "Transfer failed");

        // 10. 将 NFT 从市场合约转移到买家
        IERC721 nftContract = IERC721(nftAddress);
        nftContract.transferFrom(address(this), msg.sender, nftId);
        
        // 11. 删除上架信息
        delete listedNft[nftAddress][nftId];
        
        // 12. 触发购买事件
        emit BuyNFT(nftAddress, nftId, price, erc20Address);
    }

    function getListedNft(address nftAddress, uint256 nftId) public view returns (listInfo memory) {
        return listedNft[nftAddress][nftId];
    }

}