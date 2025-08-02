// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// IBank 接口
interface IBank{
    function withdraw(address payable to) external;
}

contract myBank is IBank{
    address private owner; // 合约所有者地址
    uint256 public totalDeposits; // 总存款金额

    //mapping 类型变量，用于存储每个地址对应的余额
    mapping(address => uint256) private balances;

    // 数组，用于记录存款金额的前3名用户
    address[3] public top3Depositors;

    // 构造函数，设置合约所有者
    constructor(){
        owner = msg.sender; // 设置合约所有者为部署者
    }

    // 存款函数，用于存储资金到 Bank 合约地址
    // payable 关键字，表示合约可以接收 ETH
    function deposit() public virtual payable {
        require(msg.value > 0, "Deposit amount must > 0");

        // 将发送者地址和金额存入mapping
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;

        // 更新Top3 用户
        updateTop3Depositors();
    }

    // 收款函数
    receive() external virtual payable {
        //自动调用 deposit() 函数
        deposit(); 
    }

    // 取款函数，用于从合约地址提取资金
    function withdraw(uint256 _amount) public{
        // 1. 检查是否为合约所有者
        require(msg.sender == owner, "Only the owner can withdraw.");

        // 2. 检查合约总存款金额是否足够
        require(totalDeposits >= _amount, "Infufficient money in contract");

        // 3. 更新余额
        totalDeposits -= _amount;

        // 4.将资金发送给所有者
        (bool success, ) = owner.call{value: _amount}("");
        require(success, "Withdraw failed");
    }

    // 提取所有资金到指定地址
    function withdraw(address payable to) public override{
        to.transfer(address(this).balance);

        // 更新余额
        totalDeposits = 0;

    }

    function updateTop3Depositors() internal{
        // 1. 获取当前存款用户的地址和金额
        address currentUser = msg.sender;
        uint256 currentBalance = balances[currentUser]; // 这里不用msg.value, 因为这是本次的存款金额，实际可能累计多次

        // 2.找到Top3 中余额最低用户及其index
        uint256 minBalance = balances[top3Depositors[0]];
        uint minIndex = 0;

        for(uint i = 1; i < top3Depositors.length; i++ ){
            if(balances[top3Depositors[i]] < minBalance){
                minBalance = balances[top3Depositors[i]];
                minIndex = i;
            }
        }

        // 3.如果当前用户比 Top3 最低的要高，或者是空位, 就放入
        if(currentBalance > minBalance || top3Depositors[minIndex] == address(0)){
            top3Depositors[minIndex] = currentUser; 
        }

        // 4.按照从高到低排序
        for(uint i = 0; i < top3Depositors.length -1; i++){
            for(uint j = i + 1; j < top3Depositors.length; j++)
            {
                if(balances[top3Depositors[i]] < balances[top3Depositors[j]]){
                    address tmp = top3Depositors[i];
                    top3Depositors[i] = top3Depositors[j];
                    top3Depositors[j] = tmp;
                }
            }
        }
    }


}

// BigBank 继承 myBank
contract BigBank is myBank{

    address private owner;//合约部署者地址
    address public admin; // 管理员地址

    constructor(){
        admin = msg.sender;
    }

    //mapping 类型变量，用于存储每个地址对应的余额
    mapping(address => uint256) public balances;

    //定义最小存款金额
    uint256 public constant MIN_DEPOSIT_AMOUNT = 0.001 ether;


    modifier validDepositAmount(){
        require(msg.value > MIN_DEPOSIT_AMOUNT, "Deposit amount must be greater than 0.001 ether!");
        _;
    }

    modifier onlyOwnerOrAdmin(){
        require(msg.sender == owner || msg.sender == admin, "Only owner or admin can call this function");
        _;
    }

    // 转移管理员函数
    function transferAdmin(address _newAdmin) public onlyOwnerOrAdmin(){
        require(_newAdmin != address(0)); //不能传入空地址作为管理员
        admin = _newAdmin;
    }

        // 收款函数
    receive() external override payable {
        //自动调用 deposit() 函数
        deposit(); 
    }

    event DepositEvent(address indexed sender, uint256 amount);

    // 存款函数，用于存储资金到 Bank 合约地址
    // payable 关键字，表示合约可以接收 ETH
    function deposit() public override payable validDepositAmount{

        // 将发送者地址和金额存入mapping
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;

        // 触发 Deposit 事件
        emit DepositEvent(msg.sender, msg.value);
    }

}


contract Admin{
    address private owner;  //合约所有者

    constructor(){
        owner = msg.sender;
    }

        // 收款函数
    receive() external payable {
    }

    function GetValue() public view returns(uint){
        return address(this).balance;
    }

    function adminWithdraw(IBank bank) public{
        bank.withdraw(payable(address(this)));
    }
}

