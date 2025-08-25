// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test{
    MultiSigWallet public multisig;

    // 3个多签持有人
    address public owner1 = makeAddr("owner1");
    address public owner2 = makeAddr("owner2");
    address public owner3 = makeAddr("owner3");

    // 非多签持有人
    address public notOwner = makeAddr("notOwner");

    // 接收资金的地址
    address public receiver = makeAddr("receiver");


    function setUp() public{
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        // 创建一个需要2个多签持有人确认的多签钱包
        multisig = new MultiSigWallet(owners, 2);

        // 向多签钱包发送ETH
        vm.deal(address(multisig), 10 ether);
        
    }

    // 测试构造函数初始化
    function test_Constructor() public view{
        // 检查多签钱包中的多签持有人数量
        assertEq(multisig.getOwners().length, 3);

        // 检查多签阈值
        assertEq(multisig.threshold(), 2);
        
        // 检查多签持有人列表
        assertTrue(multisig.isOwner(owner1));
        assertTrue(multisig.isOwner(owner2));
        assertTrue(multisig.isOwner(owner3));

        // 检查非多签持有人
        assertFalse(multisig.isOwner(notOwner));

    }

    // 检查非多签持有人不能提案
    function test_CreateProposalOnlyOwner() public{
        // 非多签持有人尝试提案
        vm.prank(notOwner);
        vm.expectRevert("Not an owner");
        multisig.createProposal(receiver, 1 ether, "Test proposal", "");
    }

    // 检查多签持有人可以提案
    function test_CreateProposalOwner() public{
        // 多签持有人尝试提案
        vm.prank(owner1);
        uint256 proposalId = multisig.createProposal(receiver, 1 ether, "Test proposal", "Test");

        // 检查提案详情
        (address to, uint256 value, , string memory description, bool executed, uint256 confirmations) = multisig.getProposal(proposalId);

        // 检查提案是否成功
        assertEq(to, receiver);
        assertEq(value, 1 ether);
        console2.log("description", description);
        assertEq(description, "Test");
        assertFalse(executed);
        assertEq(confirmations, 0);
    }

    // 测试确认提案功能
    function test_ConfirmProposal() public{
        // owner1创建提案
        vm.prank(owner1);
        uint256 proposalId = multisig.createProposal(receiver, 1 ether, "Test proposal", "");

        // owner2确认提案
        vm.prank(owner2);
        multisig.confirmProposal(proposalId);

        // 检查提案详情
        (, , , , bool executed, uint256 confirmations) = multisig.getProposal(proposalId);

        // 检查提案确认状态
        assertEq(confirmations, 1);//确认数为1
        assertFalse(executed);     // 检查提案是否未执行

        // 检查同一个人重复确认
        vm.prank(owner2);
        vm.expectRevert("Proposal already confirmed");
        multisig.confirmProposal(proposalId);
    }


    // 测试执行未达门槛的提案
    function test_ExecuteProposalNotEnoughConfirmations() public{
        // owner1 创建提案
        vm.prank(owner1);
        uint256 proposalId = multisig.createProposal(receiver, 1 ether, "Test proposal", "");

        // owner2 确认提案
        vm.prank(owner2);
        multisig.confirmProposal(proposalId);

        // 检查提案是否未执行
        (, , , , bool executed, ) = multisig.getProposal(proposalId);
        assertFalse(executed);

        // 尝试执行提案 (此时确认数为1，未达2个的门槛)
        vm.prank(owner1);
        vm.expectRevert("Not enough confirmations");
        multisig.executeProposal(proposalId);
    }

    // 测试执行达到门槛的提案
    function test_ExecuteProposalEnoughConfirmations() public{
        // owner1 创建提案
        vm.prank(owner1);
        uint256 proposalId = multisig.createProposal(receiver, 1 ether, "Test proposal", "");

        // owner2 确认提案
        vm.prank(owner2);
        multisig.confirmProposal(proposalId);

        // owner3 确认提案
        vm.prank(owner3);
        multisig.confirmProposal(proposalId);

        // 检查提案是否已执行
        (,,,, bool executed, uint256 confirmations) = multisig.getProposal(proposalId);
        console2.log("executed: ", executed);
        assertFalse(executed);

        // 检查提案执行前余额
        console2.log("multisig balance: ", address(multisig).balance);
        assertEq(address(multisig).balance, 10 ether);

        // 执行提案
        vm.prank(notOwner); // 任何人都可以执行
        multisig.executeProposal(proposalId);

        (,,,, bool executed2, ) = multisig.getProposal(proposalId);


        // 检查执行后状态
        console2.log("executed2: ", executed2);
        assertTrue(executed2);
        console2.log("multisig balance: ", address(multisig).balance);
        assertEq(address(multisig).balance, 9 ether);
        console2.log("receiver balance: ", address(receiver).balance);
        assertEq(address(receiver).balance, 1 ether);

        // 检查执行后确认数
        assertEq(confirmations, 2);
        
        
    }

    // 测试获取确认列表
    function test_GetConfirmations() public{
        // owner1 创建提案
        vm.prank(owner1);
        uint256 proposalId = multisig.createProposal(receiver, 1 ether, "Test proposal", "");

        // owner2 确认提案
        vm.prank(owner2);
        multisig.confirmProposal(proposalId);

        // 检查确认列表
        address[] memory confirmations = multisig.getConfirmations(proposalId);
        assertEq(confirmations.length, 1);
        assertEq(confirmations[0], owner2);

        // 检查确认列表长度
        assertEq(multisig.getConfirmations(proposalId).length, 1);
        
    }
        
}