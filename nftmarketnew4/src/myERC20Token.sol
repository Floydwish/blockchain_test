//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
合约设计说明：

一、项目所需功能
1. 给指定地址铸造代币
2. 授权指定地址可以转移代币（NFT市场合约）

二、权限
1. 只有合约拥有者可以铸造代币

三、实现
1. 铸造代币：继承 ERC20 合约
2. 授权指定地址可以转移代币：使用 ERC20 合约中的 approve 函数
3. 权限控制：使用 Ownable 合约实现合约拥有者管理


*/

// 导入openzeppelin-contracts库中的ERC20合约, 用于实现ERC20代币的标准功能
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// 导入openzeppelin-contracts库中的Ownable合约，用于实现代币的拥有者管理
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract myERC20Token is ERC20, Ownable {

    // 构造函数
    // 调用 ERC20 父合约的构造函数, 设置代币名称和符号
    // 调用 Ownable 父合约的构造函数，设置本合约的拥有者为 msg.sender
    constructor() ERC20("myERC20Token", "MET") Ownable(msg.sender){
        // 铸造初始代币给合约拥有者
        // ERC20 合约中的 internal 函数，继承后用于铸造代币
        _mint(msg.sender, 10000*10**decimals()); 
    }

    // 铸造代币
    // 其中 onlyOwner 函数修改器由 Ownable 合约提供，限制合约拥有者才能铸造代币
    function mint(address to, uint256 amount) public onlyOwner {
        // 铸造代币：使用 ERC2O 合约中的 _mint
        _mint(to, amount);
    }

}
