// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入测试库、日志库
import {Test, console} from "forge-std/Test.sol";
import {myNFT} from "../src/myNFT.sol";


contract myNFTTest is Test {
    myNFT public nft;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        nft = new myNFT();
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function testConstructor() public view {
        assertEq(nft.name(), "MyNFT");
        assertEq(nft.symbol(), "NFT");
    }

    function testMintSuccess() public {
        nft.mint(user1, "http://localhost:5173/sample-metadata.json");
        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.tokenURI(0), "http://localhost:5173/sample-metadata.json");
    }

    function testMintFailedNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        nft.mint(user1, "http://localhost:5173/sample-metadata2.json");
    }
    function testMintFailedInvalidAddress() public {
        vm.expectRevert();
        nft.mint(user1,"");
    }

    function testMintFailedInvalidURI() public {
        vm.expectRevert();
        nft.mint(user1, "" );
    }
    
    function testPublicMintSuccess() public {
        vm.prank(user1);
        nft.publicMint( "http://localhost:5173/sample-metadata.json");
        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.tokenURI(0), "http://localhost:5173/sample-metadata.json");
    }

    
    function testPublicMintFailedInvalidURI() public {
        vm.prank(user1);
        vm.expectRevert();
        nft.publicMint("");
    }

}