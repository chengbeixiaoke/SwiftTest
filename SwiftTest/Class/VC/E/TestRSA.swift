//
//  TestRSA.swift
//  SwiftTest
//
//  Created by yyw on 2025/4/22.
//

import Foundation
import Security

class TestRSA {
    
    // 生成 RSA 密钥对
    func generateRSAKeyPair() -> (publicKey: SecKey?, privateKey: SecKey?) {
        let keySize = 2048
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: keySize,
            kSecPrivateKeyAttrs: [
                kSecAttrIsPermanent: false
            ]
        ]
        
        var publicKey, privateKey: SecKey?
        let status = SecKeyGeneratePair(attributes as CFDictionary, &publicKey, &privateKey)
        if status != errSecSuccess {
            print("Failed to generate key pair: \(status)")
            return (nil, nil)
        }
        return (publicKey, privateKey)
    }
    
    // 将 SecKey 转换为 Data
    func keyToData(_ key: SecKey) -> Data? {
        var error: Unmanaged<CFError>?
        if let keyData = SecKeyCopyExternalRepresentation(key, &error) {
            return keyData as Data
        } else if let error = error?.takeRetainedValue() {
            print("Error converting key to data: \(error)")
        }
        return nil
    }
    
    // 将 Data 转换为 Base64 字符串
    func dataToBase64(_ data: Data) -> String {
        print(data.base64EncodedString(options: .lineLength64Characters))
        print(data.base64EncodedString(options: .lineLength76Characters))
        print(data.base64EncodedString(options: .endLineWithCarriageReturn))
        print(data.base64EncodedString(options: .endLineWithLineFeed))

        
        return data.base64EncodedString(options: .lineLength64Characters)
    }
}
