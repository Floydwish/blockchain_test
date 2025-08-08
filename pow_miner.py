from gettext import find
import hashlib
from operator import le
import time

# 定义允许的前导0范围
MIN_ZEROS = 1
MAX_ZEROS = 6


def find_proof_of_work(nickname, leading_zero):
    """
    寻找符合特定前导0的哈希值
    """

    print(f"矿工{nickname}开始挖矿", flush=True)

    nonce = 0
    start_time = time.time()
    target_prefix = '0' * leading_zero
    print(f"开始寻找符合前导{leading_zero}个0的哈希值...")
    
    while True:
        data_to_hash = f"{nickname}:{nonce}"
        hash_result = hashlib.sha256(data_to_hash.encode()).hexdigest()
        if nonce !=0 and nonce % 100000 == 0:
            print(f"尝试{nonce}次，当前哈希值前缀为：{hash_result[:leading_zero]}")
        if hash_result.startswith(target_prefix):
            end_time = time.time()
            print(f"矿工{nickname}成功找到符合前导{leading_zero}个0的哈希值！")
            print(f"哈希值：{hash_result}")
            print(f"耗时：{end_time - start_time:.2f}秒\n\n")
            return nonce
        nonce += 1

if __name__ == "__main__":

    # 1. 获取矿工昵称、前导0个数
    nickname = input("请输入矿工昵称：")

    # 2.寻找 4 个 0 开头的哈希值
    find_proof_of_work(nickname, 4);

    # 3. 寻找 5 个 0 开头的哈希值
    find_proof_of_work(nickname, 5);

    # 3. 寻找 6 个 0 开头的哈希值
    #find_proof_of_work(nickname, 6);