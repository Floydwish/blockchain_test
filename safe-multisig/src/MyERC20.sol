// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MyERC20 is ERC20 {
    constructor(string memory name,     // 代币名称
                string memory symbol,   // 代币符号
                uint256 initialSupply)  // 代币初始供应量（带18位小数）
                ERC20(name, symbol){    // 初始化父类
        _mint(msg.sender, initialSupply); // 初始化代币数量:发送给部署者
    }
}
