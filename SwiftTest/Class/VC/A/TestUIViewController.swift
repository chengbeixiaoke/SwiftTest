//
//  TestUIViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/4/11.
//

import UIKit
import WebKit
import SnapKit
import YYKit

class TestUIViewController: WYYUIViewViewController {
    
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
        
        setupUI()
    }
    
    func setupUI() {
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
    }
}




