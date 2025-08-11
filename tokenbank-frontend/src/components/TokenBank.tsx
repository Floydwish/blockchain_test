// src/components/TokenBank.tsx

import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { useState, useEffect } from 'react';
import { parseEther, formatEther } from 'viem';
import { TOKEN_BANK_CONTRACT_ADDRESS, TOKEN_BANK_CONTRACT_ABI } from '../config';

export default function TokenBank() {
  const { address, isConnected } = useAccount();
  const [depositAmount, setDepositAmount] = useState('0.1');
  const [errorMessage, setErrorMessage] = useState('');
  const [buttonDisabledReason, setButtonDisabledReason] = useState('');

  // 查询用户在 myBank 中的余额
  const { data: balance, refetch: refetchBalance, isError: isBalanceError, error: balanceError } = useReadContract({
    address: TOKEN_BANK_CONTRACT_ADDRESS,
    abi: TOKEN_BANK_CONTRACT_ABI,
    functionName: 'balances', // 注意这里是balances，与合约中的mapping名称一致
    args: [address as `0x${string}`],
  });

  // 查询合约总存款
  console.log('查询余额的地址:', address); // 确保输出不为undefined或0x0
  const { data: totalDeposits,
    refetch: refetchTotalDeposits
  } = useReadContract({
    address: TOKEN_BANK_CONTRACT_ADDRESS,
    abi: TOKEN_BANK_CONTRACT_ABI,
    functionName: 'totalDeposits',
  });

  // 存款功能 - 适配myBank合约的deposit函数
  const { writeContract: deposit, data: depositHash, isPending: isDepositing, isError: isDepositError, error: depositError } = useWriteContract();
  const { isLoading: isConfirmingDeposit, isSuccess: isDepositSuccess } = useWaitForTransactionReceipt({ hash: depositHash });

  const handleDeposit = () => {
    console.log('存款按钮被点击，准备执行存款操作');
    setErrorMessage('');
    
    try {
      const amount = parseFloat(depositAmount);
      if (isNaN(amount) || amount <= 0) {
        throw new Error('请输入有效的存款金额');
      }
      
      // 调用myBank合约的deposit函数（无参数，金额通过value传递）
      deposit({
        address: TOKEN_BANK_CONTRACT_ADDRESS,
        abi: TOKEN_BANK_CONTRACT_ABI,
        functionName: 'deposit', // 确保与合约中的函数名完全一致
        value: parseEther(depositAmount), // 存款金额作为value传递
      });
    } catch (err) {
      console.error('存款操作失败:', err);
      setErrorMessage(err instanceof Error ? err.message : '存款操作失败，请重试');
    }
  };

  // 取款功能 - 注意：myBank合约的withdraw函数有参数且仅所有者可调用
  const { writeContract: withdraw, data: withdrawHash, isPending: isWithdrawing } = useWriteContract();
  const { isLoading: isConfirmingWithdraw, isSuccess: isWithdrawSuccess } = useWaitForTransactionReceipt({ hash: withdrawHash });
  
  const handleWithdraw = (withdrawAmount: string) => {
    try {
      if (!balance) {
        throw new Error('没有可提取的余额');
      }
      
      const amount = parseEther(withdrawAmount);
      if (amount <= 0) {
        throw new Error('提取金额必须大于0');
      }
      
      // 调用myBank合约的withdraw函数，需要传入金额参数
      withdraw({
        address: TOKEN_BANK_CONTRACT_ADDRESS,
        abi: TOKEN_BANK_CONTRACT_ABI,
        functionName: 'withdraw',
        args: [amount], // 传入提取金额参数
      });
    } catch (err) {
      console.error('取款操作失败:', err);
      setErrorMessage(err instanceof Error ? err.message : '取款操作失败，请重试');
    }
  };

  // 监控按钮禁用原因
  useEffect(() => {
    if (isDepositing || isConfirmingDeposit) {
      setButtonDisabledReason('交易处理中');
    } else if (!depositAmount) {
      setButtonDisabledReason('未输入金额');
    } else if (parseFloat(depositAmount) <= 0) {
      setButtonDisabledReason('金额必须大于0');
    } else {
      setButtonDisabledReason('');
    }
  }, [isDepositing, isConfirmingDeposit, depositAmount]);

  // 处理错误信息
  useEffect(() => {
    if (isDepositError && depositError) {
      console.error('存款错误:', depositError);
      setErrorMessage(`存款失败: ${depositError.message}`);
    }
    
    if (isBalanceError && balanceError) {
      console.error('余额查询错误:', balanceError);
      setErrorMessage(`余额查询失败: ${balanceError.message}`);
    }
  }, [isDepositError, depositError, isBalanceError, balanceError]);

  // 交易成功后重新查询余额和总存款
  useEffect(() => {
    if (isDepositSuccess || isWithdrawSuccess) {
      refetchBalance();     // 重新查询余额   
      refetchTotalDeposits(); // 重新查询总存款
    }
  }, [isDepositSuccess, isWithdrawSuccess, refetchBalance, refetchTotalDeposits]);

  if (!isConnected) {
    return <div>请先连接钱包。</div>;
  }

  return (
    <div>
      <h2>myBank</h2>
      <p>你的存款余额: {balance ? formatEther(balance as bigint) : '0'} ETH</p>
      <p>合约总存款: {totalDeposits ? formatEther(totalDeposits as bigint) : '0'} ETH</p>
      
      {errorMessage && (
        <div style={{ color: 'red', margin: '10px 0' }}>
          ⚠️ {errorMessage}
        </div>
      )}
      
    
      {/* 开发环境调试信息 - 生产环境需移除或注释 */}
      {buttonDisabledReason && (
      <div style={{ color: '#666', fontSize: '0.8em' }}>
        按钮禁用原因: {buttonDisabledReason}
      </div>
      )}
      
      <div>
        <h3>存款</h3>
        <input 
          type="number" 
          value={depositAmount} 
          onChange={(e) => setDepositAmount(e.target.value)} 
          disabled={isDepositing || isConfirmingDeposit}
          step="0.01"
          min="0.01"
        />
        <button 
          onClick={handleDeposit} 
          disabled={isDepositing || isConfirmingDeposit || !depositAmount || parseFloat(depositAmount) <= 0}
        >
          {isDepositing || isConfirmingDeposit ? '存款中...' : '存款'}
        </button>
      </div>

      <div>
        <h3>取款（仅合约所有者）</h3>
        <input 
          type="number" 
          placeholder="输入取款金额"
          step="0.01"
          min="0.01"
          id="withdrawAmount"
        />
        <button 
          onClick={() => {
            const amount = (document.getElementById('withdrawAmount') as HTMLInputElement).value;
            handleWithdraw(amount);
          }} 
          disabled={!balance || isWithdrawing || isConfirmingWithdraw || (balance === 0n)}
        >
          {isWithdrawing || isConfirmingWithdraw ? '取款中...' : '取款'}
        </button>
      </div>
    </div>
  );
}
    


/*  
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { useState, useEffect } from 'react';
import { parseEther, formatEther } from 'viem';
import { TOKEN_BANK_CONTRACT_ADDRESS, TOKEN_BANK_CONTRACT_ABI } from '../config';

export default function TokenBank() {
  const { address, isConnected } = useAccount();
  const [depositAmount, setDepositAmount] = useState('0.1');

  // 查询用户在 TokenBank 中的余额
  const { data: balance, refetch: refetchBalance } = useReadContract({
    address: TOKEN_BANK_CONTRACT_ADDRESS,
    abi: TOKEN_BANK_CONTRACT_ABI,
    functionName: 'balances',
    args: [address],
    //watch: true,
  });

  // 存款功能
  const { writeContract: deposit, data: depositHash, isPending: isDepositing } = useWriteContract();
  const { isLoading: isConfirmingDeposit, isSuccess: isDepositSuccess } = useWaitForTransactionReceipt({ hash: depositHash });

  const handleDeposit = () => {
    deposit({
      address: TOKEN_BANK_CONTRACT_ADDRESS,
      abi: TOKEN_BANK_CONTRACT_ABI,
      functionName: 'deposit',
      value: parseEther(depositAmount), // 存款金额
    });
  };

  // 取款功能
  const { writeContract: withdraw, data: withdrawHash, isPending: isWithdrawing } = useWriteContract();
  const { isLoading: isConfirmingWithdraw, isSuccess: isWithdrawSuccess } = useWaitForTransactionReceipt({ hash: withdrawHash });
  
  const handleWithdraw = () => {
    // 这里假设取款金额是全部余额，你也可以添加输入框让用户自定义
    if (balance) {
      withdraw({
        address: TOKEN_BANK_CONTRACT_ADDRESS,
        abi: TOKEN_BANK_CONTRACT_ABI,
        functionName: 'withdraw',
        //args: [balance],
      });
    }
  };

  // 交易成功后重新查询余额
  useEffect(() => {
    if (isDepositSuccess) {
      refetchBalance();
    }
  }, [isDepositSuccess, refetchBalance]);

  useEffect(() => {
    if (isWithdrawSuccess) {
      refetchBalance();
    }
  }, [isWithdrawSuccess, refetchBalance]);

  if (!isConnected) {
    return <div>请先连接钱包。</div>;
  }

  return (
    <div>
      <h2>TokenBank</h2>
      <p>你的存款余额: {balance ? formatEther(balance as bigint) : '0'} ETH</p>
      
      <div>
        <h3>存款</h3>
        <input 
          type="number" 
          value={depositAmount} 
          onChange={(e) => setDepositAmount(e.target.value)} 
          disabled={isDepositing || isConfirmingDeposit}
        />
        <button 
          onClick={handleDeposit} 
          disabled={isDepositing || isConfirmingDeposit || !depositAmount || parseFloat(depositAmount) <= 0}
        >
          {isDepositing || isConfirmingDeposit ? '存款中...' : '存款'}
        </button>
      </div>

      <div>
        <h3>取款</h3>
        <button 
          onClick={handleWithdraw} 
          disabled={!withdraw || isWithdrawing || isConfirmingWithdraw || !balance || balance === 0n}
        >
          {isWithdrawing || isConfirmingWithdraw ? '取款中...' : '取款全部余额'}
        </button>
      </div>
    </div>
  );
}
*/