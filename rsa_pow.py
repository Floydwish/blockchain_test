import time
import hashlib
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.backends import default_backend

# 配置
MY_NICKNAME = "bob"
TARGET_ZEROS = 4

print(f"POW & RAS 实践开始，昵称：{MY_NICKNAME}，前导0个数：{TARGET_ZEROS}", flush=True)

#1.生成RSA密钥对
private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048, backend=default_backend())
public_key = private_key.public_key()
print("公私钥对生成成功", flush=True)

#2.寻找 POW 哈希内容
print(f"寻找 {TARGET_ZEROS} 个前导0的哈希值", flush=True)
nonce, start_time = 0, time.time()
target_prefix = "0" * TARGET_ZEROS
pow_data_to_sign = None

while True:
    data_to_sign = f"{MY_NICKNAME}:{nonce}"
    #print(f"data_to_sign: {data_to_sign}", flush=True)

    hash_result=hashlib.sha256(data_to_sign.encode()).hexdigest()
    if hash_result.startswith(target_prefix):
        pow_data_to_sign = data_to_sign
        print(f"找到哈希内容：'{pow_data_to_sign}', 哈希值：{hash_result},耗时：{time.time()-start_time:.4f}秒", flush=True)
        break
    nonce += 1
    


# 3.私钥签名
if pow_data_to_sign:
    message_bytes = pow_data_to_sign.encode()
    signature = private_key.sign(message_bytes, padding.PSS(mgf=padding.MGF1(hashes.SHA256()), salt_length=padding.PSS.MAX_LENGTH), hashes.SHA256())
    print(f"签名成功，签名值：{signature.hex()}", flush=True)

    # 4. 公钥验证
    try:
        public_key.verify(signature, message_bytes,padding.PSS(mgf=padding.MGF1(hashes.SHA256()), salt_length=padding.PSS.MAX_LENGTH), hashes.SHA256())
        print("签名验证成功", flush=True)
    except Exception as e:
        print(f"签名验证失败：{e}", flush=True)
else:
    print("未找到POW哈希，跳过签名验证", flush=True)

print(f"POW & RAS 实践结束")
