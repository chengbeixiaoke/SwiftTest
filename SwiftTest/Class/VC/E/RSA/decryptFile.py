from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_v1_5, AES
from Crypto.Util.Padding import unpad
import base64
import os

# RSA 私钥 (PEM 格式)
private_key_pem = """
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDN0vfBS6qYfmuQ
Wlh06Bc/5a9BxI9/eHoKlnlCpb5gRCEkSRD6umJFAbOjy8x+Eh+F6KVOAuseUGeJ
x7fBMyY6AMsv87dyFWOi07arw1bGtfjfrtQc4TYyIxgD6lnBznN9y+tRC4/cUZ3f
R0usqLB4cpy9W9RzNqezZ71WiSDDLZ5H3AP9ge0miQXPLf9p7uqzp9kaxLgNDi26
FWTA2S30mSv5/QEZ6w0tpQORrkcsSS0oYYKp2cMG/rndhM1AIGk/N0kLGT3p8F5a
bMWPtPlaOdFF9jWi5WHOxmg2Mqp2PsAhKFvUgSSHk7LfFWm/u6et1eRdFGAm2tix
2pPgxX4xAgMBAAECggEACvWENpkSTMtSa927nwHqlv7iTYSrRVTDXsPzUe6kS9jk
0NtJGaiJ6fW0vHByA3Zwkj84agZywWrzkFz/djyEeQsoxnVaG6ty4i0WqV+dw7fV
uAdFiQIe0h2XPkIgpFabRKPydB7C+q6n0scnitpyhv9HRDfbAIV0+XL5HF3xziKL
mXPCM4bF/pGAsosurl+5p3UPTfmHe1jmMGOmPWz4NjrJg9BM61huGTDZ4kIyQoRH
WuUxx5VD1O2J+cUdU/5jnU04PPMX29P/ZoeSZqlcb1ssmXWz4q454XqY8jGFde8X
g+u7+5wDGd3fh2nDcnJoRkgxoQRIDGgDvi7ghW9OLwKBgQD/OJy/y0UC3yVdad3R
PkmLOQ0sPH944kkyJ0lwSXn3tiO1pVmzWM8KoPBMZmVcDfyK2qOOKTnftd5n7x7w
Yo2L9s72wE0EREOOg83nlfHXjDfowu7qk1K444mO0VqIVLAyJB1Yf4sPYC6UD3i6
DBliedix9tGazBE7dqmjSLaiGwKBgQDOc8PJCR6wJnx4vjzn9UEVcTwXWh6NDQeO
klTqAa6wyDwJrDXK3TftvgvUGkuhqppoex0FSD3rAYAQ1ey7u/UgSTCi1RAGz/q0
4B+DnK6eudMbH1e/PVfa3TC2j9Zcfp0oV9kYuohaWBK9zd3Xx3PaHbBkdEebq7PH
G2EpNRFFowKBgBvhHEZbNwusQpGkueVcj34U2lqFtUsINQS0g/IvJJKpo9b43Aaa
YeuATx+ZY+MdaAPnBEzINhk47bWeyltp+JpceJk9wmv/5P1RapGssIFiQM09Vgnr
0/J8cI9YUTJpReIETexX6mHgmNX1prN0FOXL957hHl5xgkRjnv5GOCUXAoGBAM3j
aWd97trhJtULc5YoYmXN7Y2kVD96tQScLo7Iarzmk+lZkrPjdjlkhEtchfyONTrp
PIHeD9HkRyGDFnoK8mTmWNiq/zasB2yG7ybEBOlKjJvJ4CpaNNmSKViHjdHkezqW
kW016XGfz+D2A72DrafiX91ukVNQIxP33CfKQpVdAoGARoFjh+/yp/38llyEAgOj
RQz0wUxQkqelVSITq5tNxe1FJtIFUp87Ql32MMm4iBTOA47QwgP6NECMHYE1L1BT
PRPtL8IOJRSHd4XguYdtEpQTq+E54eGYOMtI1yYxa53umtb9uWIZCJ5xMGENBurD
bxtY4QqMvUZB13KPvwC2Ze4=
-----END PRIVATE KEY-----
"""

def load_private_key(pem_str):
    """加载 PEM 格式的 RSA 私钥"""
    # 清理 PEM 格式的字符串
    pem_str = pem_str.replace("-----BEGIN PRIVATE KEY-----", "")
    pem_str = pem_str.replace("-----END PRIVATE KEY-----", "")
    pem_str = pem_str.replace("\n", "").replace("\r", "").strip()
    
    # 解码 base64
    key_der = base64.b64decode(pem_str)
    
    # 创建 RSA 密钥对象
    private_key = RSA.import_key(key_der)
    return private_key

def rsa_decrypt(data, private_key):
    """使用 RSA 私钥解密数据"""
    cipher = PKCS1_v1_5.new(private_key)
    decrypted = cipher.decrypt(data, None)
    if decrypted is None:
        raise ValueError("RSA 解密失败")
    return decrypted

def decrypt_file(input_path, output_path, private_key, rsa_encrypted_key_length=256):
    """
    解密文件
    
    参数:
        input_path: 输入文件路径
        output_path: 输出文件路径
        private_key: RSA 私钥
        rsa_encrypted_key_length: RSA 加密的密钥长度 (默认 256 字节)
    """
    with open(input_path, 'rb') as infile, open(output_path, 'wb') as outfile:
        # 1. 读取 RSA 加密的 AES 密钥
        encrypted_aes_key = infile.read(rsa_encrypted_key_length)
        
        # 2. 解密 AES 密钥
        aes_key = rsa_decrypt(encrypted_aes_key, private_key)
        
        # 读取并解密剩余数据
        while True:
            chunk = infile.read(4096 + 12 + 16)  # 16 字节是 GCM 的 tag
            if not chunk:
                break

            # 最后一个块可能小于完整大小
            if len(chunk) < 28:
                raise ValueError("无效的加密数据")
            
            iv = chunk[:12]
            ciphertext = chunk[12:-16]
            received_tag = chunk[-16:]
            cipher = AES.new(aes_key, AES.MODE_GCM, nonce=iv)

            try:
                decrypted_chunk = cipher.decrypt_and_verify(ciphertext, received_tag)
                outfile.write(decrypted_chunk)
            except ValueError as e:
                raise ValueError("解密失败或认证失败: " + str(e))

# 示例使用
if __name__ == "__main__":
    # 加载私钥
    private_key = load_private_key(private_key_pem)
    # 输入和输出文件路径
    encrypted_file = "2025-04-24_4029257634_Logs.enc"
    decrypted_file = "2025-04-24_4029257634_Logs.log"
    
    try:
        decrypt_file(encrypted_file, decrypted_file, private_key)
        print(f"文件解密成功，保存到: {decrypted_file}")
    except Exception as e:
        print(f"解密失败: {str(e)}")
