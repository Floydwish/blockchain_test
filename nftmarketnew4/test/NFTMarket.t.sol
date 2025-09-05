// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入测试库、日志库
import {Test, console} from "forge-std/Test.sol";
import {myNFTMarket} from "../src/myNFTMarket.sol";
import {myNFT} from "../src/myNFT.sol";
import {myERC20Token} from "../src/myERC20Token.sol";

contract myNFTMarketTest is Test {
    myNFTMarket public nftMarket;
    myNFT public nft;
    myERC20Token public erc20;

    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        nftMarket = new myNFTMarket();
        nft = new myNFT();
        erc20 = new myERC20Token();

        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    /* 测试上架 NFT */

    // 测试上架 NFT 成功：固定价格1 ether
    function test_listNFTSuccess() public {
        vm.prank(user1);
        nft.publicMint( "http://localhost:5173/sample-metadata.json");
        
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);

        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        assertEq(nft.ownerOf(0), address(nftMarket));
        assertEq(nftMarket.getListedNft(address(nft), 0).nftAddress, address(nft));
        assertEq(nftMarket.getListedNft(address(nft), 0).nftId, 0);
        assertEq(nftMarket.getListedNft(address(nft), 0).price, 1 ether);
        assertEq(nftMarket.getListedNft(address(nft), 0).erc20Address, address(erc20));
        assertEq(nftMarket.getListedNft(address(nft), 0).seller, user1);
    }

    // 测试上架 NFT 成功：随机价格
    function test_Fuzz_listNFTSuccessRandomPrice() public {
        // 获取随机价格
        uint256 randomPrice = bound(
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))),
            0.01 ether,
            1000 ether
        );
        console.log("randomPrice", randomPrice);

        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, randomPrice, address(erc20));
    }

    // 1.测试上架失败：非所有者
    function test_listNFTFailedNotOwner() public {

        // 1. user 1 铸造 NFT
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");

        vm.prank(user1);
        nft.approve(address(nftMarket), 0);

        // 2. user 2 尝试上架 NFT
        vm.prank(user2);
        vm.expectRevert("You are not the owner of this NFT");
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));
    }

    // 2. 测试上架失败：NFT 合约地址无效
    function test_listNFTFailedInvalidNFTAddress() public {
        vm.prank(user1);
        nft.publicMint( "http://localhost:5173/sample-metadata.json");
       
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);

        vm.prank(user1);
        vm.expectRevert("NFT contract address is invalid");
        nftMarket.listNFT(address(0), 0, 1 ether, address(erc20));
    }

    // 3.测试上架失败：NFT 不存在
    function test_listNFTFailedNFTNotExists() public {

        vm.prank(user1);
        vm.expectRevert("NFT not exists");

        nftMarket.listNFT(address(nft), 1, 1 ether, address(erc20));
    }

    // 4.测试上架失败：NFT 已经上架
    function test_listNFTFailedAlreadyListed() public {
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        console.log("owner:", owner);
        console.log("user1:", user1);
        console.log("user2:", user2);
        vm.prank(user1);

        // 上架之后，所有者变成了市场合约，所以会被权限检查拦住，无法再次上架
        vm.expectRevert("You are not the owner of this NFT");
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));
    }

    // 5.测试上架失败：没有授权
    function test_listNFTFailedNotApproved() public {
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        vm.expectRevert("NFT not approved");
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));
    }

    // 6.测试上架失败：代币合约地址无效
    function test_listNFTFailedInvalidERC20Address() public {
        vm.prank(user1);
        nft.publicMint( "http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        vm.expectRevert("ERC20 contract address is invalid");
        nftMarket.listNFT(address(nft), 0, 1 ether, address(0));
    }

    // 7.测试上架失败：价格为 0
    function test_listNFTFailedPriceZero() public {
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        vm.expectRevert("Price must be greater than 0");
        nftMarket.listNFT(address(nft), 0, 0, address(erc20));
    }

    // 8. 测试上架失败：上架事件
    function test_listNFTFailedEvent() public {
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);

        // 设置期望事件
        vm.expectEmit(true, true, false, false);

        // 设置具体的期望参数
        emit myNFTMarket.ListNFT(address(nft), 0, 1 ether, address(erc20));
        
        // 上架后，产生事件
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));
        
    }

    /* 测试购买 NFT */

    // 测试购买 NFT 成功：固定价格1 ether
    function test_buyNFTSuccess() public {

        // 1. 卖家上架 NFT
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        // 2. 买家授权市场合约 转移代币
        vm.prank(owner);
        erc20.mint(user2, 10 ether);
        vm.prank(user2);
        erc20.approve(address(nftMarket), 1 ether);
        vm.prank(user2);
        nftMarket.buyNFT(address(nft), 0, 1 ether, address(erc20)); 
    }

    // 测试购买成功：随机价格
    function test_Fuzz_buyNFTSuccessRandomPrice() public {
        // 1. 卖家上架 NFT
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        // 2. 买家授权市场合约 转移代币
        // 获取随机价格
        uint256 randomPrice = bound(
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))),
            0.01 ether,
            1000 ether
        );
        console.log("randomPrice", randomPrice);

        vm.prank(owner);
        erc20.mint(user2, randomPrice);
        vm.prank(user2);
        erc20.approve(address(nftMarket), randomPrice);
        vm.prank(user2);
        nftMarket.buyNFT(address(nft), 0, randomPrice, address(erc20));
    }

    // 测试购买失败：NFT 合约地址无效
    function test_buyNFTFailedInvalidNFTAddress() public {
        // 1. 卖家上架 NFT
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        vm.expectRevert("NFT contract address is invalid");
        nftMarket.listNFT(address(0), 0, 1 ether, address(erc20));

        // 2. 买家授权市场合约 转移代币
        vm.prank(owner);
        erc20.mint(user2, 1 ether);
        vm.prank(user2);
        erc20.approve(address(nftMarket), 1 ether);
        vm.prank(user2);
        vm.expectRevert("NFT contract address is invalid");
        nftMarket.buyNFT(address(0), 0, 1 ether, address(erc20));
    }

    // 测试购买失败：NFT 未上架
    function test_buyNFTFailedNFTNotListed() public {
        // 1. 卖家上架 NFT
        vm.prank(user1);
        nft.publicMint( "http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        //vm.prank(user1);
        //nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        // 2. 买家授权市场合约 转移代币
        vm.prank(owner);
        erc20.mint(user2, 1 ether);
        vm.prank(user2);
        erc20.approve(address(nftMarket), 1 ether);
        vm.prank(user2);
        vm.expectRevert("NFT not listed");
        nftMarket.buyNFT(address(nft), 0, 1 ether, address(erc20));
    }
    
    // 测试购买失败：代币合约地址无效
    function test_buyNFTFailedInvalidERC20Address() public {
        // 1. 卖家上架 NFT
        vm.prank(user1);
        nft.publicMint( "http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        // 2. 买家授权市场合约 转移代币
        vm.prank(owner);
        erc20.mint(user2, 1 ether);
        vm.prank(user2);
        erc20.approve(address(nftMarket), 1 ether);
        vm.prank(user2);
        vm.expectRevert("ERC20 contract address is invalid");
        nftMarket.buyNFT(address(nft), 0, 1 ether, address(0));
    }

    // 测试购买失败：代币余额不足
    function test_buyNFTFailedInsufficientBalance() public {
        // 1. 卖家上架 NFT
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        // 2. 买家授权市场合约 转移代币
        vm.prank(owner);
        erc20.mint(user2, 0.5 ether);                               // 余额 0.5 ether
        vm.prank(user2);
        erc20.approve(address(nftMarket), 0.5 ether);               // 授权 0.5 ether
        vm.prank(user2);
        vm.expectRevert("Insufficient balance");
        nftMarket.buyNFT(address(nft), 0, 1 ether, address(erc20)); // 购买要 1 ether
    }

    // 测试购买失败：代币授权不足
    function test_buyNFTFailedInsufficientAllowance() public {
        // 1. 卖家上架 NFT
        vm.prank(user1);
        nft.publicMint( "http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        // 2. 买家授权市场合约 转移代币
        vm.prank(owner);
        erc20.mint(user2, 2 ether);                               // 余额 2 ether
        vm.prank(user2);
        erc20.approve(address(nftMarket), 0.5 ether);               // 授权 0.5 ether
        vm.prank(user2);
        vm.expectRevert("Insufficient allowance");
        nftMarket.buyNFT(address(nft), 0, 1 ether, address(erc20)); // 购买要 1 ether
    }

    // 测试购买失败：价格为0
    function test_buyNFTFailedPriceZero() public {
        // 1. 卖家上架 NFT
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        // 2. 买家授权市场合约 转移代币
        vm.prank(owner);
        erc20.mint(user2, 1 ether);
        vm.prank(user2);
        erc20.approve(address(nftMarket), 1 ether);
        vm.prank(user2);
        vm.expectRevert("Price must be greater than 0");
        nftMarket.buyNFT(address(nft), 0, 0, address(erc20));  // 0 价格购买
    }

    // 测试购买事件
    function test_buyNFTFailedEvent() public {
        // 1. 卖家上架 NFT
        vm.prank(user1);
        nft.publicMint("http://localhost:5173/sample-metadata.json");
        vm.prank(user1);
        nft.approve(address(nftMarket), 0);
        vm.prank(user1);
        nftMarket.listNFT(address(nft), 0, 1 ether, address(erc20));

        // 2. 买家授权市场合约 转移代币
        vm.prank(owner);
        erc20.mint(user2, 1 ether);
        vm.prank(user2);
        erc20.approve(address(nftMarket), 1 ether);
        vm.prank(user2);
        vm.expectEmit(true, true, false, true);
        emit myNFTMarket.BuyNFT(address(nft), 0, 1 ether, address(erc20));
        nftMarket.buyNFT(address(nft), 0, 1 ether, address(erc20));
    }
}

/*
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
*/

