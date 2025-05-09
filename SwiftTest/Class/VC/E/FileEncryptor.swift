//
//  FileEncryptor.swift
//  SwiftTest
//
//  Created by yyw on 2025/4/21.
//

import Foundation
import CryptoKit
import Security

class FileEncryptor {
    // 生成随机 AES Key 和 IV
    private func generateAESKeyAndIV() -> (key: Data, iv: Data) {
        let key = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        let iv = AES.GCM.Nonce().withUnsafeBytes { Data($0) }
        return (key, iv)
    }
    
    // RSA 加密（使用公钥）
    private func rsaEncrypt(data: Data, publicKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(
            publicKey,
            .rsaEncryptionPKCS1,
            data as CFData,
            &error
        ) as Data? else {
            throw error?.takeRetainedValue() ?? NSError(domain: "RSAError", code: -1, userInfo: nil)
        }
        return encryptedData
    }
    
    // 加密文件（流式处理）
    private func encryptFile(inputURL: URL,
                             outputURL: URL,
                             rsaPublicKey: SecKey) throws
    {
        // 1. 生成 AES Key 和 IV
        let (aesKey, iv) = generateAESKeyAndIV()
        
        // 2. 用 RSA 公钥加密 Key
        let encryptedKey = try rsaEncrypt(data: aesKey, publicKey: rsaPublicKey)
        
        // 3. 初始化 AES 加密器
        let sealedBox = try AES.GCM.seal(
            Data(), // 空数据，仅用于创建 Nonce
            using: SymmetricKey(data: aesKey),
            nonce: AES.GCM.Nonce(data: iv)
        )
        
        // 4. 写入加密文件（RSA(Key) + AES(FileData)）
        let outputHandle = try FileHandle(forWritingTo: outputURL)
        outputHandle.write(encryptedKey) // 写入 RSA 加密的头部
        
        // 5. 分块加密文件内容（每次 4KB）
        let inputHandle = try FileHandle(forReadingFrom: inputURL)
        let chunkSize = 4096
        while true {
            let chunk = inputHandle.readData(ofLength: chunkSize)
            if chunk.isEmpty { break }
            
            let encryptedChunk = try AES.GCM.seal(chunk,
                                                  using: SymmetricKey(data: aesKey),
                                                  nonce: sealedBox.nonce).combined! // 获取加密后的数据
            
            outputHandle.write(encryptedChunk)
        }
        
        inputHandle.closeFile()
        outputHandle.closeFile()
    }
    
    // PEM 公钥加载
    private func loadPublicKey(pem: String) throws -> SecKey {
        // 1. 清理 PEM 格式
        let base64String = pem
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 2. Base64 解码
        guard let keyData = Data(base64Encoded: base64String) else {
            throw NSError(domain: "KeyError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Base64 decoding failed"])
        }
        
        // 3. 设置密钥属性
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: 2048 // 根据实际密钥大小调整
        ]
        
        // 4. 创建 SecKey
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error) else {
            let errorDescription = error?.takeRetainedValue().localizedDescription ?? "Unknown error"
            throw NSError(domain: "KeyError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Key creation failed: \(errorDescription)"])
        }
        
        return key
    }
    
    
    // 加密文件
    func encryptFile(inputURL: URL,
                     outputURL: URL,
                     completion: ((Error?)->()))
    {
        let pem = """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzdL3wUuqmH5rkFpYdOgX
        P+WvQcSPf3h6CpZ5QqW+YEQhJEkQ+rpiRQGzo8vMfhIfheilTgLrHlBnice3wTMm
        OgDLL/O3chVjotO2q8NWxrX4367UHOE2MiMYA+pZwc5zfcvrUQuP3FGd30dLrKiw
        eHKcvVvUczans2e9Vokgwy2eR9wD/YHtJokFzy3/ae7qs6fZGsS4DQ4tuhVkwNkt
        9Jkr+f0BGesNLaUDka5HLEktKGGCqdnDBv653YTNQCBpPzdJCxk96fBeWmzFj7T5
        WjnRRfY1ouVhzsZoNjKqdj7AIShb1IEkh5Oy3xVpv7unrdXkXRRgJtrYsdqT4MV+
        MQIDAQAB
        -----END PUBLIC KEY-----
        """
        do {
            let rsaPublicKey = try loadPublicKey(pem: pem)
            try encryptFile(inputURL: inputURL,
                            outputURL: outputURL,
                            rsaPublicKey: rsaPublicKey)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    // RSA 解密（使用私钥）
    private func rsaDecrypt(data: Data, privateKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey,
                                                            .rsaEncryptionPKCS1,
                                                            data as CFData,
                                                            &error) as Data? else {
            throw error?.takeRetainedValue() ?? NSError(domain: "RSAError", code: -1, userInfo: nil)
        }
        return decryptedData
    }
    
    // 解密文件
    private func decryptFile(inputURL: URL,
                             outputURL: URL,
                             rsaPrivateKey: SecKey,
                             // RSA-2048 加密后长度
                             rsaEncryptedKeyLength: Int = 256) throws
    {
        let inputHandle = try FileHandle(forReadingFrom: inputURL)
        let outputHandle = try FileHandle(forWritingTo: outputURL)
        
        // 1. 提取 RSA 加密的 Key+IV
        let encryptedKey = inputHandle.readData(ofLength: rsaEncryptedKeyLength)
        let aesKey = try rsaDecrypt(data: encryptedKey, privateKey: rsaPrivateKey)
        
        // 3. 初始化 AES 解密器
        let symmetricKey = SymmetricKey(data: aesKey)
        
        // 4. 分块解密剩余文件内容
        let chunkSize = 4096 + 12 + 16 // AES-GCM 会增加 12 字节的 IV 和 16 字节的 tag
        while true {
            let chunk = inputHandle.readData(ofLength: chunkSize)
            if chunk.isEmpty { break }
            
            let sealedBox = try AES.GCM.SealedBox(combined: chunk)
            let decryptedChunk = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            outputHandle.write(decryptedChunk)
        }
        
        inputHandle.closeFile()
        outputHandle.closeFile()
    }
    
    // PEM 密钥加载
    private func loadPrivateKey(pem: String) throws -> SecKey {
        let base64String = pem
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = Data(base64Encoded: base64String, options: [.ignoreUnknownCharacters]) else {
            throw NSError(domain: "Invalid Base64", code: 0, userInfo: nil)
        }
        
        print(data.hexString)
        
        print(data.base64EncodedString())
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 2048
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(data as CFData, attributes as CFDictionary, &error) else {
            throw error?.takeRetainedValue() ?? NSError(domain: "Key creation failed", code: 0, userInfo: nil)
        }
        
        return privateKey
    }
    
    func decryptFile(inputURL: URL,
                     outputURL: URL,
                     completion: ((Error?)->()))
    {
        // 加载 RSA 私钥（PEM 格式）
        let privateKeyPEM = """
        -----BEGIN PRIVATE KEY-----
        MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDAx4kOV1MnTopJxYzBtVQAD6vhZgrItDGv3QnMQTYO+PWLDRx3Q5y2GUYHUdRa3qFvhcxwpvK3F18JwUeqFkHTbGD0R5S+vxKFrraKQNSG+Tmg31yU+cujw/YpwVNmJnF+0LmRGrnBneytko2VxAfUAbXRZttueM8lBSJ6PO8t6n8m4I+K+pjABi5zTlSZ9kNFuSXbadA5DPkYnghy5EYairh3ta6Uq6po8e4p8sN7RIdMW+styx4zbwCFQlXuvE4cTVQwZB/dHVP8+fecKy35YfWMarn8ziFFp0x9MROZE4fVdHP+4zm1eAT5KsdltdlNwIPog0YgrVCCO3OoTt5RAgMBAAECggEABnBXsh9drTQ661U+Qv1MZqLfXNw6l5roprEDXfOO45vCQERmJy/efujL0Wxk00rosZPSiO/zjwTYYVgXvZ0oElCmMZyHMeKKAuXrrgUVsCMofwh81DM+b2wo93qv/1tA+tFMBGYkDozougCpStd5AzZSKUIGKdu+P/RaoyJwQuxZfLfrEWTyXncUX6CRD+X3hJEtwFExpnhTuMXST4/NKYZ2BLNrcrIe+hlT2gujWxsOVnpUWRG9Q1Cx/a8khVc/U7EkCygx7FSOSX/N1/hBWv3H+0CODBeLQUhmOiXyooBXpVdBD3vTOHdJ+iy5X5KBCGUHmnKwqvSr5RyqoqsrgQKBgQDmVW+cEzZws87ZX/6uy8pSuMlqPEj046sgKsxiJsnGaKTdBJJ8wOq8OTMaDJBVj6lSGs14pQZhjbehsQ0sS8xVu8flS2uiGdC7JXrjA0vJg9ZrFP8DF0vxVhKysfr62/uZV97JyiEh9D/jMERkWJEMErq8IUhNKPOHnsjfWla/0QKBgQDWQtCmXC+TNS1b79Di7I3D07/p4GETCrYRFVfzmfVTaZP8ZYbzn+RgNexBZiqLmPm/eGyaWoD/ZCIYz5ZJ+50n9ihMJZha2Y8dPUNSZ0JH6oC0QDrcAROZGl/CZHTByJ+KtZZC29ZLU18KKE8asHlPFop7+WXHJq+evPLajahWgQKBgQDEAcxaitb3DWxm+xOl9/ISdwGfj/Gdw+gqFYGbvNpUJ1S0aGGoHBslVZ+w+SQSS5CROBHGKtjFR24PALXvDgmyo3u2GnpblZBU0c5DRNjHgZODyHhCTx7nHpIG0wJ7W5w9n9MM8R9E369GTBrHMb8tAPs7gS8fykuDC5Jwz1WnIQKBgHXZVEhcpjJS6nsKAhv+vs76VjG+n8ZIevIUikbL5NsXVDVcZojz5jphDmy+VCJqZtxA0YNoylEu824wJ9rTkZJcW7feadl2lrgfbTsS3qsNufLq7TT7RptMnWUfufSoc9BopphpsInH9ptwpmnorSCqJkugVrHefnRSO0Wo6vGBAoGAAQ1Y7mTE2dLnauKozz+Lt0Kx6KqwzxIzG1Ip4exbBwq38yEvv2mMcGpytDqvbndGfuT7nuSe5qYcKE0bvExiy8Cib4ZCD1Te02RdXbil8S1VsrdvYvjHvdt8wuWZ9RU0dslS1rc2aqpHjGaQsG/nIz5/ueEtdQAHAbmGqg4KcsE=
        -----END PRIVATE KEY-----
        """
        do {
            let rsaPrivateKey = try loadPrivateKey(pem: privateKeyPEM)
            try decryptFile(inputURL: inputURL,
                            outputURL: outputURL,
                            rsaPrivateKey: rsaPrivateKey)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
