// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {myBank} from "../src/Bank.sol";
import {console} from "forge-std/console.sol";

contract BankTest is Test {
    myBank public bank;

    address[] public users;

    address owner;

    function setUp() public {
        bank = new myBank();

        owner = address(this); //测试合约作为所有者

        for (uint i = 0; i < 10; i++) {
            address user = makeAddr(string.concat("user", vm.toString(i)));
            users.push(user);
            vm.deal(users[i], 20 ether);
        }

    }

    // 检查存款前后余额和总存款额是否正确
    function test_DepositUpdateBalance() public {
        uint256 depositAmount = 1 ether;

        // 存款后预计用户余额
        uint256 userBalanceAfter = bank.getBalance(users[0]) + depositAmount;

        // 存款后预计总存款额
        uint256 totalDepositsAfter = bank.totalDeposits() + depositAmount;

        // 模拟 user1 存款
        vm.prank(users[0]); // 设置用户1为当前交易的发起者 (msg.sender)
        bank.deposit{value: depositAmount}();   // 存款

        // 验证用户余额和总存款额更新
        assertEq(bank.getBalance(users[0]), userBalanceAfter); // 验证用户1的余额
        assertEq(bank.totalDeposits(), totalDepositsAfter);   // 验证总存款额
    }

    // 检查1个用户存款后，top3是否正确
    function test_top3WithOneUser() public {
        // 模拟 user1 存款
        vm.prank(users[0]);
        bank.deposit{value: 1 ether}();

        // 验证 top3 是否正确
        console.log("users[0]", users[0]);
        console.log("bank.getTop3Depositors(0)", bank.getTop3Depositors(0));
        assertEq(bank.getTop3Depositors(0), users[0]);
        assertEq(bank.getTop3Depositors(1), address(0));
        assertEq(bank.getTop3Depositors(2), address(0));
    }

    // 检查2个用户存款后，top3是否正确
    function test_top3WithTwoUser() public {
        // 模拟 user2 存款
        vm.prank(users[1]);
        bank.deposit{value: 2 ether}();

        // 模拟 user3 存款
        vm.prank(users[2]);
        bank.deposit{value: 3 ether}();

        // 验证 top3 是否正确
        assertEq(bank.getTop3Depositors(0), users[2]);
        assertEq(bank.getTop3Depositors(1), users[1]);
        assertEq(bank.getTop3Depositors(2), address(0));
    }

    // 检查3个用户存款后，top3是否正确
    function test_top3WithThreeUser() public {
        // 模拟 user4 存款
        vm.prank(users[3]);
        bank.deposit{value: 4 ether}();

        // 模拟 user5 存款
        vm.prank(users[4]);
        bank.deposit{value: 5 ether}();

        // 模拟 user6 存款
        vm.prank(users[5]);
        bank.deposit{value: 6 ether}();

        // 验证 top3 是否正确
        assertEq(bank.getTop3Depositors(0), users[5]);
        assertEq(bank.getTop3Depositors(1), users[4]);
        assertEq(bank.getTop3Depositors(2), users[3]);
    }

    // 检查4个用户存款后，top3是否正确
    function test_top3WithFourUser() public {
        // 模拟 user7 存款
        vm.prank(users[6]);
        bank.deposit{value: 7 ether}();

        // 模拟 user8 存款
        vm.prank(users[7]);
        bank.deposit{value: 8 ether}();

        // 模拟 user9 存款
        vm.prank(users[8]);
        bank.deposit{value: 9 ether}();

        // 模拟 user10 存款
        vm.prank(users[9]);
        bank.deposit{value: 10 ether}();

        // 验证 top3 是否正确
        assertEq(bank.getTop3Depositors(0), users[9]);
        assertEq(bank.getTop3Depositors(1), users[8]);
        assertEq(bank.getTop3Depositors(2), users[7]);
    }

    // 检查1个用户多次存款后，top3是否正确
    function test_top3WithOneUserMultipleDeposit() public {
        // 模拟 user1 存款
        vm.prank(users[0]);
        bank.deposit{value: 10 ether}();


        // 模拟 user1 存款
        vm.prank(users[0]);
        bank.deposit{value: 2 ether}();

        // 验证 top3 是否正确
        assertEq(bank.getTop3Depositors(0), users[0]);
        assertEq(bank.getTop3Depositors(1), address(0));
        assertEq(bank.getTop3Depositors(2), address(0));
    }

    //检查其他人不可以取款
    function test_withdrawNoManager() public {
        // 模拟 user1 取款, 应该失败    
        vm.deal(users[0], 10 ether); 
        vm.prank(users[0]); // user1 调用合约开始取款
        vm.expectRevert("Only the owner can withdraw.");
        bank.withdraw(1 ether);

    }


    

    //检查只有管理员可以取款
    function test_withdrawManager() public {

        // 模拟 user1 存款
        vm.prank(users[0]);
        bank.deposit{value: 10 ether}();

        // 检查总存款额
        uint256 totalDeposits = bank.getTotalDeposits();
        console.log("totalDeposits", totalDeposits);

        vm.deal(owner, 2 ether);

        // 管理员取款，应该成功
        vm.prank(owner);
        bank.withdraw(1 ether);
    }

    receive() external payable {
        console.log("receive");
    }
}
