//
//  ACell.swift
//  SwiftTest
//
//  Created by yyw on 2024/12/2.
//

import Foundation
import SnapKit
import YYKit

class ACell: BaseTableViewCell {
    lazy var nameLabel = {
        let label = YYLabel()
        label.font = .Medium(16)
        label.textColor = .Text_000000_1
        return label
    }()
    
    lazy var messageLabel = {
        let label = YYLabel()
        label.font = .Medium(16)
        label.textColor = .Text_0091FF_1
        return label
    }()
    
    override func setupUI() {
        super.setupUI()
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.top).offset(26)
            make.left.equalToSuperview().inset(15)
        }
        
        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.top).offset(52)
            make.left.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(15)
        }
    }
}
