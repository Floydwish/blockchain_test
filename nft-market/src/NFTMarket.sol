// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

contract NFTMarket {
    
    // 上架的 nft 信息
    struct Listing {
        uint256 price;          // 价格
        address seller;         // 卖家地址
        address paymentToken;   // 支付代币合约地址
    }
    
    // 上架的 nft 列表 (NFT 合约地址 => NFT 代币 ID => 上架详情)
    mapping(address => mapping(uint256 => Listing)) public listings;

    // 上架 nft 事件
    event NFTListed(address indexed nftContract, uint256 indexed tokenId, uint256 price, address paymentToken);

    // 售出 nft 事件
    event NFTSold(address indexed nftContract, uint256 indexed tokenId, uint256 price, address paymentToken);

    function listNFT(address _tokenAddress, uint256 _tokenId, uint256 _price, address _paymentToken) public {
        // 1.检查价格范围
        console.log("listNFT: _price", _price);
        require(_price > 0, "Price must be greater than 0");

        // 2.所有权检查：确保调用者是 NFT 的拥有者
        IERC721 nftContract = IERC721(_tokenAddress);   // 获取 NFT 合约接口实例
        console.log("nftContract.ownerOf(_tokenId)", nftContract.ownerOf(_tokenId));
        console.log("msg.sender", msg.sender);
        require(nftContract.ownerOf(_tokenId) == msg.sender, "You are not the owner of this NFT");

        // 3.授权检查：确保本市场合约被授权，可以转移该NFT
        // 注意：更好的设计是购买时才转移NFT，而不是上架时转移NFT
        require(nftContract.getApproved(_tokenId) == address(this)   // 检查是否授权该NFT给市场合约
        || nftContract.isApprovedForAll(msg.sender, address(this)),  // 检查是否授权所有NFT给市场合约
        "Market is not approved to transfer this NFT");

        // 4.检查是否已经上架 (如果已经上架，listings 中应该有记录)
        require(listings[_tokenAddress][_tokenId].seller == address(0), "NFT already listed");

        // 5.检查支付代币是否有效 (支付代币不能为空)
        require(_paymentToken != address(0), "Invalid payment token");

        // 6.转移所有权：将 NFT 从卖家转移到市场合约
        nftContract.transferFrom(msg.sender, address(this), _tokenId);

        // 7.更新上架信息
        listings[_tokenAddress][_tokenId] = Listing({
            price: _price,
            seller: msg.sender,
            paymentToken: _paymentToken
        });

        // 8.触发上架事件
        emit NFTListed(_tokenAddress, _tokenId, _price, _paymentToken);
    }

    function buyNFT(address _tokenAddress, uint256 _tokenId, address _paymentToken) public {
        // 1.检查是否上架
        Listing memory listing = listings[_tokenAddress][_tokenId];
        console.log("listing.seller", listing.seller);
        console.log("msg.sender", msg.sender);
        require(listing.seller != address(0), "NFT not listed");

        // 2.检查买卖地址是否一致，防止自买自卖
        require(listing.seller != msg.sender, "You cannot buy your own NFT");

        // 3.检查支付代币是否一致 (支付指定的代币)
        require(listing.paymentToken == _paymentToken, "Invalid payment token");

        // 4.检查买家代币余额是否足够支付
        IERC20 paymentToken = IERC20(_paymentToken);    // 获取支付的代币合约实例，以调用代币接口方法
        console.log("msg.sender", msg.sender);
        console.log("paymentToken.balanceOf(msg.sender)", paymentToken.balanceOf(msg.sender));
        console.log("listing.price", listing.price);
        require(paymentToken.balanceOf(msg.sender) >= listing.price, "Insufficient balance");

        // 5.检查代币授权（是否允许市场合约从买家账户中扣款）
        console.log("address(this)", address(this));
        console.log("msg.sender", msg.sender);
        console.log("paymentToken.allowance(msg.sender, address(this))", paymentToken.allowance(msg.sender, address(this)));
        // 5.1 检查授权是否足够
        require(paymentToken.allowance(msg.sender, address(this)) >= listing.price, "Insufficient allowance");
        
        // 5.2 检查授权是否相等 (授权金额必须等于购买金额，避免授权过多)
        require(paymentToken.allowance(msg.sender, address(this)) == listing.price, "Over allowance");


        // 6.转移代币：从买家账户中 转移代币到 卖家账户
        require(paymentToken.transferFrom(msg.sender, listing.seller, listing.price), "Transfer failed");

        // 7.转移 NFT：从市场合约 转移 NFT 到 买家账户
        IERC721 nftContract = IERC721(_tokenAddress);
        nftContract.transferFrom(address(this), msg.sender, _tokenId);

        // 8.删除上架信息
        delete listings[_tokenAddress][_tokenId];

        // 9.触发售出事件
        emit NFTSold(_tokenAddress, _tokenId, listing.price, _paymentToken);
    }

    // 获取上架的 NFT 信息
    function getListing(address _tokenAddress, uint256 _tokenId) public view returns (Listing memory) {
        return listings[_tokenAddress][_tokenId];
    }
}
