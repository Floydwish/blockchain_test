// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MultiSigWallet {
    // 事件定义
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, address indexed to, uint256 value, bytes data, string description);
    event ProposalConfirmed(uint256 indexed proposalId, address indexed confirmer);
    event ProposalExecuted(uint256 indexed proposalId);
    event OwnerAdded(address indexed newOwner);
    event OwnerRemoved(address indexed oldOwner);
    event ThresholdChanged(uint256 newThreshold);
    event EthReceived(address indexed sender, uint256 amount);

    // 多签持有人
    address[] public owners;

    // 记录地址是否是多签持有人
    mapping(address => bool) public isOwner;

    // 签名门槛
    uint256 public threshold;

    // 提案结构体
    struct Proposal {
        address to;    // 交易目标地址
        uint256 value; // 发送的ETH数量
        bytes data;    // 交易数据
        string description; // 提案描述
        bool executed; // 是否已执行
        uint256 confirmations; // 已经确认的数量
        mapping(address => bool) confirmed; // 记录每个持有人是否确认
    }

    // 提案列表
    mapping(uint256 => Proposal) public proposals;

    // 提案ID计数器
    uint256 public proposalCount;

    // 仅多签持有人可以调用
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    // 提案必须存在
    modifier proposalExists(uint256 proposalId) {
        require(proposalId < proposalCount, "Proposal does not exist");
        _;
    }

    // 提案必须未执行
    modifier notExecuted(uint256 proposalId) {
        require(!proposals[proposalId].executed, "Proposal already executed");
        _;
    }

    // 提案必须未被确认
    modifier notConfirmed(uint256 proposalId) {
        require(!proposals[proposalId].confirmed[msg.sender], "Proposal already confirmed");
        _;
    }

    // 初始化多签钱包，设置初始持有人和签名门槛
    constructor(address[] memory _owners, uint256 _threshold) {
        require(_owners.length > 0, "Owners are required");
        require(_threshold > 0 && _threshold <= _owners.length, "Invalid threshold");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner already exists");

            isOwner[owner] = true;
            owners.push(owner);
        }

        threshold = _threshold; // 设置签名门槛
        proposalCount = 0; // 初始化提案计数器
    }

    // 提交新的提案
    function createProposal(address to, uint256 value, bytes memory data, string memory description) public onlyOwner returns (uint256 proposalId){
        proposalId = proposalCount;

        Proposal storage proposal = proposals[proposalId];
        proposal.to = to;
        proposal.value = value;
        proposal.data = data;
        proposal.description = description;
        proposal.executed = false;
        proposal.confirmations = 0;

        proposalCount++; // 增加提案计数器
        emit ProposalCreated(proposalId, msg.sender, to, value, data, description);
        return proposalId;
    }

    // 确认一个提案 (某个多签持有人确认提案)
    function confirmProposal(uint256 proposalId) public onlyOwner 
        proposalExists(proposalId)
        notExecuted(proposalId)
        notConfirmed(proposalId){
            Proposal storage proposal = proposals[proposalId];
            proposal.confirmed[msg.sender] = true;
            proposal.confirmations++;

            emit ProposalConfirmed(proposalId, msg.sender);
        }

    
    // 执行一个已经达到签名门槛的提案 (任何人都可以执行)
    function executeProposal(uint256 proposalId) public proposalExists(proposalId)
        notExecuted(proposalId)
        {
            Proposal storage proposal = proposals[proposalId];
            require(proposal.confirmations >= threshold, "Not enough confirmations");

            proposal.executed = true; // 标记为已执行

            // 执行交易
            // 使用低级call函数执行交易，value参数指定发送的ETH数量，data参数指定交易数据
            // 从多签钱包 向 目标地址 发送 ETH
            // 如果 proposal.to 是 EOA，则直接发送ETH
            // 如果 proposal.to 是合约，则执行合约中的函数 (携带data参数，包括 函数签名和参数)
            (bool success, ) = proposal.to.call{value: proposal.value}(proposal.data);
            require(success, "Execution failed");

            emit ProposalExecuted(proposalId);
        }

    
    // 获取提案的确认情况 (返回所有确认者的地址)
    function getConfirmations(uint256 proposalId) public view proposalExists(proposalId) returns (address[] memory) {
        // 获取确认者数量
        uint256 confirmCount = proposals[proposalId].confirmations;

        // 创建一个数组来存储确认者地址
        address[] memory confirmers = new address[](confirmCount);

        uint256 index = 0;
        // 遍历所有持有人
        for(uint256 i = 0; i < owners.length; i++){
            // 如果持有人确认了提案
            if(proposals[proposalId].confirmed[owners[i]]){
                // 将持有人地址添加到确认者数组中
                confirmers[index] = owners[i];
                index++; // 增加索引
            }
        }
        return confirmers; // 返回确认者地址数组
    }

    // 获取所有所有多签持有人
    function getOwners() public view returns (address[] memory){
        return owners;
    }

    // 获取提案详情
    function getProposal(uint256 proposalId) public view proposalExists(proposalId)
        returns (address to, uint256 value, bytes memory data, string memory description, bool executed, uint256 confirmations){
            Proposal storage proposal = proposals[proposalId];
            return (proposal.to,
                    proposal.value,
                    proposal.data,
                    proposal.description,
                    proposal.executed,
                    proposal.confirmations);
        }

    // 添加新的多签持有人（通过提案的方式: 待实现）
    function addOwner(address newOwner) internal onlyOwner{
        require(newOwner != address(0), "Invalid owner");
        require(!isOwner[newOwner], "Owner already exists");

        // 添加新的多签持有人
        isOwner[newOwner] = true;
        owners.push(newOwner);
        emit OwnerAdded(newOwner);
    }

    // 移除多签持有人（通过提案的方式：待实现）
    function removeOwner(address oldOwner) internal onlyOwner{
        require(oldOwner != address(0), "Invalid owner");
        require(isOwner[oldOwner], "Owner does not exist");
        require(owners.length > 1, "Cannot remove the last owner");  // 不能移除最后一个多签持有人
        require(threshold <= owners.length - 1, "Threshold cannot be greater than the number of owners");  // 移除后门槛值 不能大于 剩余多签持有人数量

        isOwner[oldOwner] = false; // 记录地址为不是多签持有人

        // 溢出多签持有人数组
        for(uint256 i = 0; i < owners.length; i++){
            if(owners[i] == oldOwner){ // 找到要移除的地址
                // 将最后一个元素移动到当前为止，再删除最后一个元素
                owners[i] = owners[owners.length -1];
                owners.pop();
                break;
            }
        }

        emit OwnerRemoved(oldOwner);
    }

    // 获取多签钱包余额
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }

    // 接收ETH
    receive() external payable{
        emit EthReceived(msg.sender, msg.value);
    }
}
