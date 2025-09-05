// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {myNFT} from "../src/myNFT.sol";
import {console} from "forge-std/console.sol";

contract DeployNFT is Script {
    // 1.合约实例
    myNFT public nft;

    // 2.部署者地址
    address public deployer;

    // 3.初始化
    function setUp() public {
        deployer = msg.sender; // 部署者地址为 msg.sender
    }

    // 4.执行
    function run() public {
        // 0.开始记录交易
        vm.startBroadcast();

        // 1.部署 NFT 合约
        console.log("Deploying NFT contract...");
        nft = new myNFT();
        console.log("NFT contract deployed at:", address(nft));

        // 2 铸造 NFT 给部署者 (可选：myNFT 合约中没有铸造 NFT 给部署者）
        console.log("Minting NFT to owner...");
        nft.mint(deployer, "http://localhost:5173/sample-metadata.json");
        console.log("NFT minted to owner");
        
        // 3.停止记录交易
        vm.stopBroadcast();

        // 4.验证部署结构
        console.log("\n===== Deployment Summary =====\n");
        console.log("Deployer:", deployer);
        console.log("NFT contract:", address(nft));
        console.log("Deployer NFT balance:", nft.balanceOf(deployer));
        console.log("======================================\n");

    }

    // 5. 添加验证部署结果的函数（可选）
    function verifyDeployment() public view{

        // NFT 合约验证
        require(address(nft) != address(0), "NFT contract not deployed");


        // 部署者 NFT 余额验证
        require(nft.balanceOf(deployer) > 0, "NFT balance not enough");

        console.log("Deployment verified successfully");
    }
}