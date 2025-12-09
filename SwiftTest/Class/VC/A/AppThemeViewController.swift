//
//  AppThemeViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/4/11.
//

import UIKit
import WebKit
import SnapKit
import YYKit
import Combine
import CombineCocoa

class AppThemeViewController: BaseViewController {
    private var cancellables = Set<AnyCancellable>()

    lazy var nameLabel = {
        let label = YYLabel()
        return label
    }()
    
    lazy var nameLabel2 = {
        let label = YYLabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .Text_000000
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview().inset(30)
        }
        
        let attr = NSMutableAttributedString(string: "测试代码")
        attr.color = .Text_000000
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
    }
    
    override func wyy_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.wyy_traitCollectionDidChange(previousTraitCollection)
        
    }
    
    func action() {
        if AppThemeModeManager.isDark() {
            AppThemeModeManager.shared.changeAppThemeMode(.light)
        }
        else {
            AppThemeModeManager.shared.changeAppThemeMode(.dark)
        }
    }
}
