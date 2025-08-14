/*
1.核心逻辑：通过命令行交互，完成以太坊生态基础钱包功能
2.整体流程：生成身份 -> 查询数据 -> 构建交易 -> 签名交易 -> 发送交易
    2.1 生成身份：通过密码学随机生成私钥，由私钥推导地址
    2.2 查询数据：通过 RPC 节点 获取链上数据
    2.3 构建交易：按照 EIP-1559 标准构建交易结构
    2.4 签名交易：使用私钥对交易进行签名，确保交易完整性 和 发送者身份
    2.5 发送交易：将签名后的交易广播到区块链网络，等待矿工打包

3. 项目结构
    3.1 核心依赖：
        - viem：以太坊客户端库，用于与区块链交互
        - dotenv：加载环境变量
        - commander：命令行交互库
    3.2 项目结构：
        - index.js：CLI 入口，负责命令行交互
        - wallet.js：私钥/地址生成
        - balance.js：余额查询
        - transaction.js：交易处理
        - .env：环境变量
*/
import { program } from "commander"; // 命令行工具
import dotenv from "dotenv";         // 环境变量加载工具
import chalk from "chalk";           // 命令行样式工具，美化输出
import { privateKeyToAccount } from "viem/accounts"; // 导入账户处理接口


// 导入自定义模块
import { generateAccount } from "./wallet.js"; // 用于生成钱包账户
import { getEthBalance, getERC20Balance }  from "./balance.js"; // 查询 ETH 和 ERC20 余额
import { createERC20Transfer, signTransaction, sendTransaction } from "./transaction.js"; // 构建交易、签名、发送交易

// 1.加载环境变量 （.env 文件， 获取 rpcUrl）
dotenv.config();

// 2. 检查 RPC 地址配置
if(!process.env.RPC_URL){
    console.error(chalk.red("error: RPC_URL 未配置"));
    process.exit(1);
}

// 3. 生成新账户命令
program
    .command('generate')
    .description('生成新钱包的私钥和地址')
    .action(() => {
        try {
            const account = generateAccount();
            console.log(chalk.green('新钱包生成成功:'));
            console.log(chalk.yellow('私钥:'), account.privateKey);
            console.log(chalk.yellow('地址:'), account.address);
        } 
        catch (errror){
            console.error(chalk.red('生成钱包失败:'), error.message);
        }
        }
    );

    // 余额查询命令
    program
        .command('balance <address>')
        .description('查询指定地址的 ETH 或 ERC20 余额')
        .option('-t, --token <token_contract_address>', '查询 ERC20 代币余额')
        .action(async (address, options) => {
            try {
                console.log(chalk.blue('正在查询余额...'));

                let result;
                if(options.token){ // 查 ERC20
                    result = await getERC20Balance(address, process.env.RPC_URL, options.token);
                }
                else{              // 查 ETH
                    result = await getEthBalance(address, process.env.RPC_URL);
                }

                console.log(chalk.green('查询成功:'));
                console.log(chalk.yellow('余额:'), result.balance);
                console.log(chalk.yellow('代币符号:'), result.tokenSymbol);
                console.log(chalk.yellow('代币小数位数:'), result.decimals);
            }
            catch (error){
                console.error(chalk.red('查询失败:'), error.message);
            }
        });

// 转账命令
program
    .command('transfer')
    .description('ERC20 代币转账')
    .requiredOption('-k, --privateKey <private_key>', '发送者私钥')
    .requiredOption('-t, --token <token_contract_address>', '代币合约地址')
    .requiredOption('-r, --recipient <recipient_address>', '接收者地址')
    .requiredOption('-a, --amount <amount>', '转账金额')
    .action(async (options) => {
        try {
            // 1.从私钥得到发送者地址
            const senderAddress = privateKeyToAccount(options.privateKey).address;
            console.log(chalk.blue('sendAddress: ', senderAddress));

            // 2.构建交易
            console.log(chalk.blue('正在构建交易...'));
            const transaction = await createERC20Transfer(
                senderAddress,
                options.token,
                options.recipient,
                options.amount,
                process.env.RPC_URL
            );
            console.log(chalk.green('构建交易结束'));


            // 3. 签名交易
            console.log(chalk.blue('正在签名交易...'));
            const signedTx = await signTransaction(transaction, options.privateKey);
            console.log(chalk.green('签名交易结束'));

            // 4. 发送交易
            console.log(chalk.blue('正在发送交易...'));
            const result = await sendTransaction(signedTx, process.env.RPC_URL);
            console.log(chalk.green('交易发送成功:'));
            console.log(chalk.yellow('交易哈希: ', result.hash));
            console.log(chalk.yellow('交易链接: ', result.explorerUrl));

        }
        catch (error){
            console.error(chalk.red('转账失败: '), error.message);
        }
    });

    // 解析命令并执行
    program.parse(process.argv);
    console.log(chalk.blue("生成钱包命令: node index.js generate"));
console.log(chalk.blue("查询 ETH 余额命令: node index.js balance <address>"));
console.log(chalk.blue("查询 ERC20 余额命令: node index.js balance <address> -t <token_contract_address>"));
console.log(chalk.blue("转账命令: node index.js transfer -k <private_key> -t <token_contract_address> -r <recipient_address> -a <amount>"));