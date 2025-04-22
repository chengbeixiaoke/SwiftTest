//
//  EViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/1/3.
//

import UIKit
import SnapKit
import Combine
import CommonCrypto
import CryptoKit

enum CryptoError: Error {
    case initializationFailed
    case encryptionFailed
    case finalizationFailed
}

class EViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    let fileEncryptor = FileEncryptor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let encryption = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        encryption.setTitle("加密", for: .normal)
        encryption.setTitleColor(.blue, for: .normal)
        view.addSubview(encryption)
        encryption.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 50))
        }
        
        encryption.tapPublisher
            .sink { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.encryptFile()
            }
            .store(in: &cancellables)
        
        let decryption = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        decryption.setTitle("解密", for: .normal)
        decryption.setTitleColor(.blue, for: .normal)
        view.addSubview(decryption)
        decryption.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 50))
        }
        
        decryption.tapPublisher
            .sink { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.decryptFile()
            }
            .store(in: &cancellables)
    }
    
    // 生成RSA密钥对
    func createRSAKeyPair() {
        let testRSA = TestRSA()
        let (publicKey, privateKey) = testRSA.generateRSAKeyPair()
        
        if let publicKey = publicKey, let privateKey = privateKey {
            if let publicKeyData = testRSA.keyToData(publicKey), let privateKeyData = testRSA.keyToData(privateKey) {
                let publicKeyBase64 = testRSA.dataToBase64(publicKeyData)
                let privateKeyBase64 = testRSA.dataToBase64(privateKeyData)
                
                print("Public Key (Base64):")
                print(publicKeyBase64)
                
                print("\nPrivate Key (Base64):")
                print(privateKeyBase64)
            }
        }
    }
    
    // 加密文件
    func encryptFile() {
        guard let filePath = Bundle.main.path(forResource: "2025-04-18_3897301462_Logs", ofType: "log") else { return }
        guard let outputURL = URL.outputURL("2025-04-18_3897301462_Logs_encryptFile",
                                            clearOld: true,
                                            createEmptyFile: true) else { return }
        
        fileEncryptor.encryptFile(inputURL: URL.FileURL(filePath),
                                  outputURL: outputURL)
        { error in
            print(error?.localizedDescription ?? "加密成功")
        }
    }
    
    func decryptFile()
    {
        guard let inputURL = URL.outputURL("2025-04-18_3897301462_Logs_encryptFile") else { return }
        guard let outputURL = URL.outputURL("2025-04-18_3897301462_Logs_decryptFile.log",
                                            clearOld: true,
                                            createEmptyFile: true) else { return }
        
        fileEncryptor.decryptFile(inputURL: inputURL,
                                  outputURL: outputURL)
        { error in
            print(error?.localizedDescription ?? "解密成功")
        }
    }
}
