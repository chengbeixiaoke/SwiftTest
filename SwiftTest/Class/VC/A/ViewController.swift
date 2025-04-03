//
//  ViewController.swift
//  SwiftTest
//
//  Created by 王阳洋 on 2024/10/13.
//

import UIKit
import Combine
import Network
import SnapKit
import SwiftyJSON
import CoreStore
import Security
import CryptoKit
import Security
import CommonCrypto
import YYKit
import UIKit
import CombineCocoa
import AVFoundation
import AVKit
import MyPackage
import ffmpegkit

class ViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear:")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewController viewDidAppear:")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController viewWillDisappear:")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController viewDidDisappear:")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")

        view.backgroundColor = .white
        
        let button = UIButton()
        button.setTitle("按钮", for: .normal)
        button.backgroundColor = .red
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSizeMake(100, 50))
        }
        button.tapPublisher
            .sink { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.startTimer()
            }
            .store(in: &cancellables)
    }
    
    /// 开启通话计时
    func startTimer() { 
        print("测试一哈".test())
        print(OtherFile.default().name)
        navigationController?.pushViewController(VideoPlayerViewController())
    }
}
