// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入测试库、日志库
import {Test, console} from "forge-std/Test.sol";

import {myERC20Token} from "../src/myERC20Token.sol";

contract myERC20TokenTest is Test {
    myERC20Token public myToken;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        myToken = new myERC20Token();
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    // 测试构造函数
    function testConstructor() public view {
        assertEq(myToken.name(), "myERC20Token");
        assertEq(myToken.symbol(), "MET");
        assertEq(myToken.decimals(), 18);
        assertEq(myToken.totalSupply(), 10000*10**myToken.decimals());
    }

    // 测试所有者铸造成功
    function testMintSuccess() public {
        myToken.mint(owner, 1000*10**myToken.decimals());
        assertEq(myToken.balanceOf(owner), 11000*10**myToken.decimals());
    }
    
    // 测试非所有者铸造失败
    function testMintFailed() public {
        vm.prank(user1);
        vm.expectRevert();
        myToken.mint(user1, 1000);
    }
}