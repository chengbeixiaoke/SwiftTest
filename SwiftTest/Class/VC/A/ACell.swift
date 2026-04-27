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
        label.textColor = .Text_000000
        return label
    }()
    
    lazy var messageLabel = {
        let label = YYLabel()
        label.font = .Medium(16)
        label.textColor = .Text_0091FF
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

class A2Cell: BaseTableViewCell {
    private lazy var levelBackgroundView = {
        return HomeTopBackgroundView(frame: CGRectMake(0, 0, WidthScreen, HeightScreen))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        super.setupUI()
        contentView.addSubview(levelBackgroundView)
        levelBackgroundView.updateLevel(level: 5)
        levelBackgroundView.clipsToBounds = true
    }
}
