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
        
        let imageView = UIImageView(image: UIImage(named: "miniapp_image"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
        
        let button2 = UIButton()
        button2.setTitle("复原", for: .normal)
        button2.backgroundColor = .red
        view.addSubview(button2)
        button2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.snp.centerY).offset(UIScale(60))
            make.size.equalTo(CGSizeMake(100, 50))
        }
        button2.tapPublisher
            .sink {
                MiniAppManager.shared.restoration()
            }
            .store(in: &cancellables)
        
        test()
        
        view.setGradientBackground(colors: [.black, .clear],
                                   locations: [0, 1],
                                   startPoint: CGPoint(x: 0.5, y: 1.0),
                                   endPoint: CGPoint(x: 0.5, y: 0.7),
                                   size: CGSize(width: view.frame.width, height: view.frame.height))
    }
    
    /// 开启通话计时
    func startTimer() {
        MiniAppManager.shared.openMiniApp("http://192.168.0.143/miniappH5.html")
    }
    
    func test() {
        
    }
}
