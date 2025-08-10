// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract NFTMarketScript is Script {
    NFTMarket public nftMarket;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        nftMarket = new NFTMarket();

        vm.stopBroadcast();
    }
}
