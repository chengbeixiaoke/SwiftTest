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
import YYKit

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
    
    lazy var nameLabel = {
        let label = YYLabel()
        return label
    }()
    
    lazy var nameLabel2 = {
        let label = YYLabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor.ColorBlack
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
        
        view.backgroundColor = UIColor.ColorWhite
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview().inset(30)
        }
        
        let attr = NSMutableAttributedString(string: "测试代码")
        attr.color = UIColor.ColorBlack
        attr.font = UIFont.systemFont(ofSize: 30)
        nameLabel.attributedText = attr
        
        view.addSubview(nameLabel2)
        nameLabel2.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(70)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview().inset(30)
        }
        nameLabel2.text = "哈哈哈哈哈上"
        
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
                weakSelf.action()
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
            .sink { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.navigationController?.pushViewController(TestUIViewController(), animated: true)
                //                MiniAppManager.shared.restoration()
                
            }
            .store(in: &cancellables)
    }
    
    func action() {
        if AppThemeModeManager.isDark() {
            AppThemeModeManager.shared.changeAppThemeMode(.light)
        }
        else {
            AppThemeModeManager.shared.changeAppThemeMode(.dark)
        }
    }
    
    override func wyy_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.wyy_traitCollectionDidChange(previousTraitCollection)
        
    }
}
