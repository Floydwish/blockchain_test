from crypt import methods
from math import log
from telnetlib import LOGOUT
from time import time
import hashlib
import json
from typing import Any, Dict, List, Optional
from urllib.parse import urlparse

import logging
import requests

from flask import Flask, jsonify, request
from uuid import uuid4

from argparse import ArgumentParser


# 配置日志输出到控制台，并将最低显示级别设置为 INFO
# 这意味着 INFO、WARNING、ERROR、CRITICAL 级别的消息都会被显示
logging.basicConfig(level=logging.INFO)

'''
# 输出纯字符串
logging.info("程序启动成功。")

# 输出字符串和整数变量
logging.info(f"用户ID: {user_id} 已登录。")

# 输出字符串和字符串变量
logging.info(f"欢迎回来，{username}！")

# 输出字符串、整数和浮点数变量
logging.info(f"用户 {username} 的得分为 {score}。")

# 输出多个变量
logging.info(f"购物车中有 {item_count} 件商品，用户ID为 {user_id}。")

# 也可以使用其他日志级别
logging.warning(f"用户 {username} 尝试访问受限区域。")
logging.error(f"处理用户 {user_id} 的请求时发生未知错误。")
'''



######## 模块一：核心区块链结构
class BlockChain(object):
    # 1.初始化区块链：定义链、交易池、创世区块
    # 主要：创建区块链骨架，包括存储区块的列表、待处理交易列表；生成链上第1个区块（创世区块）
    def __init__(self):
        self.chain = []                 # 存放：所有已经挖出的区块
        self.current_transactions = []  # 存放：等待打包到下一个区块的交易
        self.nodes = set()              # 存放：网络中其他区块链节点的地址

        # 创建创世区块
        # previous_hash='1': 随意给的，因为创世区块没有前一个块
        # proof=100: 随意给的，后面通过工作量证明算法计算得出
        self.new_block(previous_hash=1, proof=100)

    # 2. 创建新区块，并添加到链中
    # 主要：定义如何将待处理的交易打包，并生成新的区块，将其添加到区块链上
    def new_block(self, proof: int, previous_hash: Optional[str]) -> Dict[str, Any]:
        '''
        参数：
            proof: 工作量证明算法计算出的证明值
            previous_hash: 前一个区块的哈希值
        返回：
            新的区块字典
        '''
        block = {
            'index': len(self.chain) + 1,              # 区块在链中的序号
            'timestamp': time(),                       # 区块创建时的时间戳
            'transactions': self.current_transactions, # 当前等待打包的交易
            'proof': proof,                            # 挖矿找到的数字

            # 上一个区块的哈希。如果是创世块，则用传入的'1'
            # 否则，调用 self.hash() 计算上一个区块的哈希
            'previous_hash': previous_hash or self.hash(self.chain[-1]),
        }
        logging.info(f'上一个区块的哈希值计算结果：{previous_hash or self.hash(self.chain[-1])}')
        logging.info(f'新区块的previous_hash字段: {block["previous_hash"]}')

        # 重置当前待处理的交易列表，因为已经被打包到新的区块了
        self.current_transactions = []

        # 将新区块添加到链上
        self.chain.append(block)

        return block

    # 3. 计算区块哈希
    # 主要：定义如何计算一个区块的哈希值，用于连接区块和验证数据完整性
    @staticmethod
    def hash(block):
        '''
        参数：
            block: 区块字典
        返回：
            区块的哈希字符串
        '''
        # 确保字典是排序的，因为哈希函数对输入顺序敏感
        # 将字典转换为JSON字符串，并编码为字节 (哈希函数需要字节输入)
        # 使用sha256算法计算哈希值
        block_string = json.dumps(block, sort_keys=True).encode()
        return hashlib.sha256(block_string).hexdigest()


    # 4. 获取最新的区块
    @property
    def last_block(self) -> Dict[str, Any]:
        '''
        返回：
            链中的最后一个区块,也就是最后一个元素
        '''
        return self.chain[-1]

  ###### 模块二：工作量证明 (Pow - Proof of Work)
  ### 挖矿的核心机制：用来控制新区块的生成速度和难度
  # 1. 工作量证明算法
  # 目的：找到一个满足特定条件（难度目标）的数字 (proof), 这个过程就是“挖矿”  
    def proof_of_work(self, last_proof: int) -> int:
        '''
        参数：
            last_proof: 前一个区块的proof值
        返回：
            满足条件的proof值
        '''
        proof = 0
        # 尝试不同的 proof 数字，直到满足 valid_proof 条件
        while self.valid_proof(last_proof, proof) is False:
            proof +=1
        return proof

    # 2. 验证工作量证明
    # 目的：验证一个给定的proof 是否满足难度目标
    @staticmethod
    def valid_proof(last_proof: int, proof: int) -> bool:
        '''
        参数：
            last_proof: 前一个区块的proof值
            proof: 当前尝试的proof值
        返回：
            是否满足难度目标
        '''
        # 将前后2个proof拼接成字符串，编码为字节，再计算哈希值
        guess = f'{last_proof}{proof}'.encode()
        result_hash = hashlib.sha256(guess).hexdigest()

        # 检查哈希值是否以4个0开头
        if result_hash[:4] == '0000':
            logging.info(f'找到有效proof, guess: {guess}, result_hash：{result_hash}, proof:{proof}')

        return result_hash[:4] == '0000'

######## 模块三：交易管理
    # 1. 添加新的交易
    # 目的：允许用户向链上添加新交易，这些交易会暂时存储，等待被打包进下一个区块
    def new_transaction(self, sender: str, recipient: str, amount: int) -> int:
        '''
        参数：
            sender: 发送者地址
            recipient: 接收者地址
            amount: 交易金额
        返回：
            新区块的索引
        '''
        # 将这个新交易添加到当前待处理的交易列表
        self.current_transactions.append({
            'sender': sender,
            'recipient': recipient,
            'amount': amount,
        })

        # 返回新区块的索引，这个交易会被添加到新区块
        return self.last_block['index'] + 1


######## 模块四：网络与共识
# 为了让区块链去中心化，需要能够与其他节点通信，并就链的真实性达成共识
# 1.注册新节点
# 目的：允许其他节点加入网络
    def register_node(self, address: str) -> None:
        '''
        参数：
            address: 新节点的URL地址, 如 'http://192.168.0.5:5000'
        '''
        #解析 URL, 提取 ip:port 部分
        parsed_url = urlparse(address)
        logging.info(f"address: {address} parsed_url: {parsed_url}")

        # 添加节点到集合中
        self.nodes.add(parsed_url.netloc)
        logging.info(f"nodes: {self.nodes}")

    # 2. 验证链的有效性
    # 目的：检查区块链是否符合规则（哈希连接正确、PoW 验证通过）。这是共识算法的一部分
    def valid_chain(self, chain: List[Dict[str, Any]]) -> bool:
        '''
        参数：
            chain: 要验证的区块链
        返回：
            是否有效
        '''
        last_block = chain[0]   #从创世区块开始
        current_index = 1       #从第二个区块开始遍历检查

        while current_index < len(chain): # chain 为待检查链；Dict[str, Any] 为链中区块
            block = chain[current_index]  # 获取当前区块
            logging.info(f"last_block: {last_block} block: {block}")

            # a.检查当前区块的previous_hash 是否等于前一个区块的实际哈希值
            if(block['previous_hash'] != self.hash(last_block)):
                return False

            # b.检查当前区块和前一区块的proof，计算后是否能满足PoW 难度目标
            if not self.valid_proof(last_block['proof'], block['proof']):
                return False

            # c.更新last_block 为当前区块，继续检查下一个区块
            last_block = block
            current_index +=1

        return True  # 通过所有检查，证明链有效

    # 3. 解决冲突
    # 目的：当多个节点有不同版本的区块链时，通过共识算法选择最长的链，作为正确的链
    def resolve_conflicts(self) -> bool:
        '''
        返回值：
            如果链被替换，返回True；否则返回False
        '''
        neighbours = self.nodes  #获取所有已知邻居节点
        new_chain = None         #存储发现的新长链

        max_length = len(self.length)  # 以自身链的长度作为最大长度

        # a.遍历所有邻居节点，获取它们所在的链并验证
        for node in neighbours:
            try: # 添加异常处理，否则宕机一个节点可能导致共识失败
                response = requests.get(f'http://{node}/chain') # 向邻居节点请求其所在的完整链

            except requests.exceptions.ConnectionError:
                logging.info(f"无法连接到节点 {node}")
                continue  # 跳过这个节点，继续检查下一个

            if response.status_code == 200:    #如果成功获取到链
                length = response.json()['length']
                chain = response.json()['chain']

                # 检查链的长度是否大于当前链，并且是有效的
                if length > max_length and self.valid_chain(chain):
                    max_length = length # 更新最长链的长度
                    new_chain = chain   # 保存这个最长的链


        # b. 如果发现了更长的、有效的链，就替换掉自己的链
        if new_chain:
            self.chain = new_chain
            return True

        # c. 没有发现更长、且有效的链，自己的链就是最权威的
        return False


###### 模块五：Flask API 路由            
# 说明：这部分把区块链功能暴露为Web 接口，让用户或程序可以通过HTTP 请求来操作区块链

# 1.初始化 Flask 应用和区块链实例
# 目的：启动 Web 服务器 和 区块链的核心逻辑

# 1.1 初始化 Flask 应用
app = Flask(__name__)

# 1.2 为当前节点生成唯一ID
node_identifier = str(uuid4()).replace('-', '')

# 1.3 创建区块链实例
blockchain = BlockChain()
logging.info(f'区块链实例创建：Blockchain initialized with node {node_identifier}')


# 2.挖矿API
# 目的：通过Web 接口，让用户可以请求挖矿，生成新区块并获得奖励
@app.route('/mine', methods=['GET'])
def mine():
    # 1.1 获取最新区块的 proof
    last_block = blockchain.last_block;
    last_proof = last_block['proof'];

    # 1.2 运行工作量证明算法，找到新的 proof
    logging.info(f'开始挖矿，当前区块的proof值为：{last_proof}')
    new_proof = blockchain.proof_of_work(last_proof)
    logging.info(f'结束挖矿，新区块的proof值为：{new_proof}')

    # 1.3 给挖矿成功的节点发送奖励（发送者 “0” 表示是系统奖励）
    blockchain.new_transaction(
        sender = '0',
        recipient = node_identifier, # 奖励接收者为当前节点
        amount = 1,                  # 奖金为1个币
    )

    # 1.4 构建新的区块，并添加到链上
    block = blockchain.new_block(new_proof, None) # previous_hash 为None, 会自动计算上一个区块的Hash

    # 1.5 组装响应，返回新区块信息
    response = {
        'message': "New Block Forged",           # 响应信息
        'index': block['index'],                 # 新区块的索引
        'transactions': block['transactions'],   # 新区块的交易列表
        'proof': block['proof'],                 # 新区块的 proof
        'previous_hash': block['previous_hash'], # 新区块的previous_hash
    }
    logging.info(f'新区块信息：{response}')

    # 1.6 返回 Json响应 和 HTTP 请求成功的状态码
    return jsonify(response), 200


# 3. 新交易的API
# 目的：通过Web 接口，让用户可以提交新的交易
@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    # 1.1 获取请求中的 json 数据
    values = request.get_json()

    # 1.2 检查请求中是否包含必要字段
    required = ['sender', 'recipient', 'amount']
    if not all(k in values for k in required):
        return 'Missing values', 400  # 返回错误信息和 http 状态码

    # 1.3 创建新的交易并添加到待处理列表
    index = blockchain.new_transaction(
        values['sender'],
        values['recipient'],
        values['amount']
    )

    #1.4 返回响应信息，新区块的索引，告知交易会被打包到新的区块
    response = {
        'message': f'Transaction will be added to Block {index}' # 响应信息   
    }
    return jsonify(response), 201 # 返回Json 响应 和 HTTP 状态码 201，表示交易创建成功

# 4. 获取整个区块链的API
# 目的：通过 Web 接口，让用户可以获取当前节点的完整区块链数据
@app.route('/chain', methods = ['GET'])
def full_chain():
    '''
    返回值：
        当前节点的所有区块和链的长度
    '''
    response = {
        'chain': blockchain.chain,
        'length': len(blockchain.chain),
    }

    # 返回 Json 响应 和 HTTP 状态码 200
    return jsonify(response), 200


# 5. 注册新节点的API
# 目的：通过 Web 接口，让用户可以注册新的区块链节点
# 方式：用户提交新节点的地址，让当前节点将它添加到已知节点列表中
@app.route('/nodes/register', methods = ['POST'])
def register_nodes():
    # 1.1 获取请求中的 json 数据
    values = request.get_json()

    # 1.2 检查请求中是否包含 “nodes” 字段，并且不为空
    nodes = values.get('nodes')
    if nodes is None:
        return "Error: Please supply a valid list of nodes", 400 # 缺少节点返回错误

    # 1.3 遍历节点，注册每个节点
    for node in nodes:
        blockchain.register_node(node)

    # 1.4 返回成功信息，说明新节点已经添加成功
    response = {
        'message': "New nodes have been added",
        'total_nodes': list(blockchain.nodes), # 返回所有已知节点列表
    }
    return jsonify(response), 201

# 6. 解决冲突的API(达成共识)
# 目的：通过 Web 接口，让用户可以请求解决冲突，选择最长的链
@app.route('/nodes/resolve', methods = ['GET'])
def consensus():
    # 1.1 调用共识算法，看是否替换了最长的有效链
    replaced = blockchain.resolve_conflicts()

    # 1.2 根据是否替换，返回不同响应
    if replaced:
        response = {
            'message': "Our chain was replaced",    # 提示链被替换
            'new_chain': blockchain.chain,          # 返回新的链
        }
    else:
        response = {
            'message': "Our chain is authoritative", # 提示当前链是最长的有效链
            'chain': blockchain.chain,               # 返回当前链
        }

    return jsonify(response), 200


# 7. 运行主程序
# 目的：设置程序的入口点，并启动 Flask Web 服务器
if __name__ == '__main__':
    # 1.1 解析命令行参数   
    parse = ArgumentParser()

    # 1.2 通过命令行添加端口 (命令格式：python myBlockChain.py -p 5001， 默认为5000端口)
    parse.add_argument('-p', '--port', default = 5000, type = int, help = 'port to listen on')
    args = parse.parse_args()
    port = args.port

    logging.info(f'Listening for requests on port {port}')

    # 1.3 启动 Flask 应用，监听指定端口
    app.run(host = '127.0.0.1', port = port) # 这里监听本地连接
