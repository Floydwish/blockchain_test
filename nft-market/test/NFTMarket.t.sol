// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {ERC721Mock} from "./mocks/ERC721Mock.sol";  // 使用自定义的 ERC721Mock 合约，而不是使用 openzeppelin 的 ERC721Mock 合约
//import {ERC721ConsecutiveMock} from "openzeppelin-contracts/contracts/mocks/token/ERC721ConsecutiveMock.sol"; // 有待后续研究


contract NFTMarketTest is Test {
    NFTMarket public nftMarket;
    ERC20Mock public paymentToken;
    ERC721Mock public nftContract;

    address public owner;
    address public seller;
    address public buyer;
    
    uint256 public tokenId;
    uint256 public price;

    function setUp() public {

        owner = address(this); // 测试合约所有者
        seller = makeAddr("seller"); // 卖家地址
        buyer = makeAddr("buyer");  // 买家地址
        tokenId = 1;           // NFT 代币 ID
        price = 2 ether;       // 代币价格

        nftMarket = new NFTMarket();   // 创建 NFT 市场合约
        paymentToken = new ERC20Mock(); // 创建支付代币


        // 创建 NFT 合约, 铸造 NFT 给 卖家
        nftContract = new ERC721Mock();
        nftContract.mint(seller, tokenId);
        address addr = nftContract.ownerOf(tokenId);
        console.log("addr", addr, "tokenId", tokenId);

        // 给买家 准备 ERC20 代币
        paymentToken.mint(buyer, 200 ether);
    }


    /* 测试上架 NFT */
    // 测试上架成功
    function test_listNFT() public {
        // 1. 卖家授权市场合约 转移 NFT
        vm.prank(seller);
        nftContract.approve(address(nftMarket), tokenId);

        // 2. 预期上架事件
        /*
        true: 检查第一个 indexed 参数 (nftContract)
        true: 检查第二个 indexed 参数 (tokenId)
        false: 不检查第三个 indexed 参数（因为price 没有 indexed 修饰）
        true: 检查所有非 indexed 参数（即 price 和 paymentToken）
         */
        vm.expectEmit(true, true, false, true);
        emit NFTMarket.NFTListed(address(nftContract), tokenId, price, address(paymentToken));

        // 3. 上架 NFT
        vm.prank(seller);         // 设置交易发起者为卖家（也就是 上架时 msg.sender 是 seller)
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));

        // 4.检查 NFT 所有权已经转移到市场合约
        assert(nftContract.ownerOf(tokenId) == address(nftMarket));

        // 5. 检查上架信息是否一致
        assertEq(nftMarket.getListing(address(nftContract), tokenId).price, price);
        assertEq(nftMarket.getListing(address(nftContract), tokenId).seller, seller);
        assertEq(nftMarket.getListing(address(nftContract), tokenId).paymentToken, address(paymentToken));
    }

    // 测试上架失败：非所有者
    function test_listNFT_Fail_NotOwner() public {
        // 1. 非所有者尝试上架 NFT
        vm.prank(buyer);  // 设置交易发起者为买家（买家没有权限上架该 NFT)
        vm.expectRevert("You are not the owner of this NFT");
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));
    }

    // 测试上架失败：没有授权
    function test_listNFT_Fail_NotApproved() public {

        // 未授权，尝试上架 NFT
        vm.prank(seller);
        vm.expectRevert("Market is not approved to transfer this NFT");
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));
    }
    // 测试上架失败：价格为 0
    function test_listNFT_Fail_PriceZero() public {
        // 1. 卖家授权市场合约 转移 NFT
        vm.prank(seller);   // 设置交易发起者为卖家，卖家才能授权市场合约转移 NFT
        nftContract.approve(address(nftMarket), tokenId);

        // 2. 预期上架失败
        vm.expectRevert("Price must be greater than 0");

        // 3. 上架 NFT
        vm.prank(seller);
        nftMarket.listNFT(address(nftContract), tokenId, 0, address(paymentToken));
    }

    // 测试上架失败：NFT 已经上架
    function test_listNFT_Fail_AlreadyListed() public {
        // 1. 卖家授权市场合约 转移 NFT
        vm.prank(seller);
        nftContract.approve(address(nftMarket), tokenId);

        // 2. 上架 NFT
        vm.prank(seller);
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));

        // 3. 再次上架 NFT, 应该失败
        vm.prank(seller);
        vm.expectRevert("You are not the owner of this NFT"); // NFT已经转移给了市场合约，所以卖家没有权限上架
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));
    }

    // 测试上架失败：支付代币无效
    function test_listNFT_Fail_InvalidPaymentToken() public {
        // 1. 卖家授权市场合约 转移 NFT
        vm.prank(seller);
        nftContract.approve(address(nftMarket), tokenId);

        // 2. 上架 NFT，应该失败
        vm.prank(seller);
        vm.expectRevert("Invalid payment token");
        nftMarket.listNFT(address(nftContract), tokenId, price, address(0)); // 支付代币为 0 地址
    }

    /* 测试购买 NFT */
    // 测试购买成功
    function test_buyNFT() public {
        // 1. 卖家上架 NFT
        vm.prank(seller); // vm.prank 只对下一行外部调用有效，所以需要重复设置交易发起者
        nftContract.approve(address(nftMarket), tokenId);   // 授权市场合约 转移 NFT
        vm.prank(seller); 
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));
        // 也可使用 vm.startPrank(seller) 和 vm.stopPrank() 来设置交易发起者, 可设置一个范围内有效

        // 2. 买家授权市场合约 转移代币
        vm.prank(buyer);
        paymentToken.approve(address(nftMarket), price);

        // 3. 预期购买事件
        vm.expectEmit(true, true, false, true);
        // emit 后面是预期的事件模板
        emit NFTMarket.NFTSold(address(nftContract), tokenId, price, address(paymentToken));
        
        // 4. 买家购买 NFT
        vm.prank(buyer);
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));

        // 5. 检查 NFT 所有权已经转移到买家
        assertEq(nftContract.ownerOf(tokenId), buyer);

        // 6. 检查代币余额
        assertEq(paymentToken.balanceOf(buyer), 200 ether - price); // 买家的剩余代币余额
        assertEq(paymentToken.balanceOf(seller), price);            // 卖家的代币余额  

        // 7. 检查上架信息已经被删除 (因为 NFT 已经出售，所以上架信息应该被删除)
        assertEq(nftMarket.getListing(address(nftContract), tokenId).price, 0);
        assertEq(nftMarket.getListing(address(nftContract), tokenId).seller, address(0));
        assertEq(nftMarket.getListing(address(nftContract), tokenId).paymentToken, address(0));
    }

    // 测试购买失败：自己买自己的 NFT
    function test_buyNFT_Fail_BuyYourself() public {
        // 1. 卖家上架 NFT
        vm.prank(seller);
        nftContract.approve(address(nftMarket), tokenId); // 授权市场合约 转移 NFT
        vm.prank(seller);
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));

        // 2. 预期购买失败
        vm.expectRevert("You cannot buy your own NFT");

        // 3. 卖家购买 自己的NFT, 应该失败
        vm.prank(seller);
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));
    }

    // 测试购买失败：NFT 重复购买
    function test_buyNFT_Fail_AlreadyBought() public {
        // 1. 卖家上架 NFT
        vm.prank(seller);
        nftContract.approve(address(nftMarket), tokenId); // 授权
        vm.prank(seller);
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));

        // 2. 买家购买 NFT
        vm.prank(buyer);
        paymentToken.approve(address(nftMarket), price);
        vm.prank(buyer);
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));

        // 3. 再次购买 NFT, 应该失败
        vm.prank(buyer);
        vm.expectRevert("NFT not listed"); // 重复购买失败,因为第1次购买后，上架信息已经被删除
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));
    }

    // 测试购买失败：支付 token 过多
    function test_buyNFT_Fail_OverPayment() public {
        // 1. 卖家上架 NFT
        vm.prank(seller);
        nftContract.approve(address(nftMarket), tokenId); // 授权
        vm.prank(seller);
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));

        // 2. 买家授权市场合约 转移代币（比价格多）
        vm.prank(buyer);
        paymentToken.approve(address(nftMarket), price + 1);

        // 3. 支付过多的代币购买 NFT, 应该失败 ??? 如何体现 ”支付过多的代币“
        vm.prank(buyer);
        vm.expectRevert("Over allowance"); // 支付过多的代币购买 NFT, 应该失败
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));
    }

    // 测试购买失败：支付token过少
    function test_buyNFT_Fail_InsufficientPayment() public {
        // 1. 卖家上架 NFT
        vm.prank(seller);
        nftContract.approve(address(nftMarket), tokenId); // 授权
        vm.prank(seller);
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));

        // 2. 买家授权市场合约 转移代币（比价格少）
        vm.prank(buyer);
        paymentToken.approve(address(nftMarket), price - 1);

        // 3. 预期购买失败
        vm.expectRevert("Insufficient allowance");

        // 4. 买家购买 NFT
        vm.prank(buyer);
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));
    }

    // 测试购买失败：代币余额不足
    /*
    function test_buyNFT_Fail_InsufficientBalance() public {
        // 1. 先卖家上架 NFT
        vm.prank(seller);
        nftContract.approve(address(nftMarket), tokenId);
        vm.prank(seller);
        nftMarket.listNFT(address(nftContract), tokenId, price, address(paymentToken));

        // 2. 买家授权市场合约 授权代币（比价格少）
        vm.prank(buyer);
        paymentToken.approve(address(nftMarket), price - 1);

        // 3. 预期购买失败
        vm.expectRevert("Insufficient allowance");

        // 4. 买家购买 NFT
        vm.prank(buyer);
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));
    }*/

    // 测试购买失败：NFT 不存在
    function test_buyNFT_Fail_NFTNotExists() public {
        // 买家尝试购买不存在的 NFT
        vm.prank(buyer);
        vm.expectRevert("NFT not listed"); // 购买未上架的 NFT, 应该失败
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));
    }

    /* 模糊测试 */
    // 模糊测试：测试随机使用 0.01-10000 Token价格上架NFT，并随机使用任意Address购买NFT
    function test_Fuzz_listNFT_RandomPrice(uint256 randomPrice, address randomAddress) public {
        // 注意：test_Fuzz 接口参数会随机生成(Foundry 内置模糊测试功能)，只需限定范围即可
        // 该接口会自动重复执行，达到多次测试随机值的效果（日志：(runs: 257）

        // 1. 限定随机价格, 范围0.01 到 10000 Token 
        // 注意：Token 的价格单位，默认是 10**18，所以需要乘以 10**18
        vm.assume(randomPrice >= 0.01 * 10**18 && randomPrice <= 10000 * 10**18);
        console.log("randomPrice", randomPrice);

        // 2. 限定随机地址
        console.log("randomAddress", randomAddress);
        vm.assume(randomAddress != seller); // 限定随机地址不能是卖家

        // 3. 上架 NFT
        vm.prank(seller);
        console.log("seller", seller, "tokenId", tokenId);
        nftContract.approve(address(nftMarket), tokenId); // 授权
        vm.prank(seller);
        nftMarket.listNFT(address(nftContract), tokenId, randomPrice, address(paymentToken));

        // 4. 买家购买 NFT
        vm.prank(randomAddress);
        paymentToken.mint(randomAddress,20000 ether);
        console.log("randomAddress", randomAddress);

        vm.prank(randomAddress);
        paymentToken.approve(address(nftMarket), randomPrice);

        vm.prank(randomAddress);
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));

        // 5. 检查 NFT 所有权已经转移到买家
        assertEq(nftContract.ownerOf(tokenId), randomAddress);
        
        // 6. 检查买家、卖家的代币余额
        assertEq(paymentToken.balanceOf(randomAddress), 20000 ether - randomPrice);
        assertEq(paymentToken.balanceOf(seller), randomPrice);

        // 7. 检查上架信息已经被删除
        assertEq(nftMarket.getListing(address(nftContract), tokenId).price, 0);
        assertEq(nftMarket.getListing(address(nftContract), tokenId).seller, address(0));
        assertEq(nftMarket.getListing(address(nftContract), tokenId).paymentToken, address(0));
        
    }

    /* 不可变测试 */
    // 不可变测试：测试无论如何买卖，NFTMarket合约中都不可能有 Token 持仓
    // 防止资金困在合约中
    function test_Immutability_NoTokenBalance_Fuzz(uint256 randomPrice, address randomBuyer) public {
        /*
        说明：
        1. 加上 _Fuzz 后，该接口会自动重复执行，达到多次测试随机值的效果（日志：(runs: 257）
        */

       // 1.限定随机价格
       vm.assume(randomPrice > 1 ether && randomPrice < 10000 ether);

       // 2. 限定随机地址
       vm.assume(randomBuyer != seller);

       // 3. 卖家上架 NFT
        vm.prank(seller);
        nftContract.approve(address(nftMarket), tokenId);
        vm.prank(seller);
        nftMarket.listNFT(address(nftContract), tokenId, randomPrice, address(paymentToken));

        // 4.买家铸造、授权代币
        vm.prank(randomBuyer);
        paymentToken.mint(randomBuyer,  randomPrice); // 买家铸造相等于NFT 价格的代币
        vm.prank(randomBuyer);
        paymentToken.approve(address(nftMarket), randomPrice);

        // 5. 买家购买 NFT
        vm.prank(randomBuyer);
        nftMarket.buyNFT(address(nftContract), tokenId, address(paymentToken));

        // 6. 检查 NFTMarket合约中没有 Token 持仓
        assertEq(paymentToken.balanceOf(address(nftMarket)), 0);
    }
}

/*
问题记录：
编写 NFTMarket 合约：

支持设定任意ERC20价格来上架NFT
支持支付ERC20购买指定的NFT
要求测试内容：

上架NFT：测试上架成功和失败情况，要求断言错误信息和上架事件。
购买NFT：测试购买成功、自己购买自己的NFT、NFT被重复购买、支付Token过多或者过少情况，要求断言错误信息和购买事件。
模糊测试：测试随机使用 0.01-10000 Token价格上架NFT，并随机使用任意Address购买NFT
「可选」不可变测试：测试无论如何买卖，NFTMarket合约中都不可能有 Token 持仓
提交内容要求

使用 foundry 测试和管理合约；
提交 Github 仓库链接到挑战中；
提交 foge test 测试执行结果txt到挑战中；

1. "支付Token过多或者过少情况",这种情况是指 “买家授权的代币” 过多或者过少吗？
如果是，那么就要求买家授权的 ERC20 代币数量刚好和 NFT 价格相等，是否存在用户体验不好的问题？
*/
