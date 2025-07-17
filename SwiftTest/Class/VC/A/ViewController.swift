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

class ViewController: WYYUIViewViewController {
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
        
        view.backgroundColor = UIColor.ColorWhite
        
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
    }
    
    /// 开启通话计时
    func startTimer() {
        test()
    }
    
    func test() {
        do{
            let vc = VC1()
            let naviVc = UINavigationController(rootViewController: vc)
            naviVc.modalPresentationStyle = .pageSheet
            present(naviVc, animated: true)
        }
    }
    
    override func wyy_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.wyy_traitCollectionDidChange(previousTraitCollection)
        
        view.backgroundColor = UIColor.ColorBG_6236FF_1_ADA7FF_1
    }
}

class VC1: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        
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
                weakSelf.test()
            }
            .store(in: &cancellables)
    }
    
    func test() {
//        let vc = VC2()
//        vc.modalPresentationStyle = .pageSheet
//        present(vc, animated: true)
        
        MiniAppManager.shared.openMiniApp("https://imadmin.crazyshit.io/chats/detail/4rhkk/5d77h")
    }
}

class VC2: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .orange
        
        
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
                weakSelf.test()
            }
            .store(in: &cancellables)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
    
    func test() {
        let vc = VC3()
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
}

class VC3: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        
        
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
                weakSelf.test()
            }
            .store(in: &cancellables)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
    
    func test() {
        let vc = VC4()
        vc.modalPresentationStyle = .custom
        present(vc, animated: true)
    }
}

class VC4: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        
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
                weakSelf.test()
            }
            .store(in: &cancellables)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
    
    func test() {
        let vc = VC3()
        vc.modalPresentationStyle = .custom
        present(vc, animated: true)
    }
}
