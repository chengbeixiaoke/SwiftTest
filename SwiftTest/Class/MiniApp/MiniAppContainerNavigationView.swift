//
//  MiniAppContainerNavigationView.swift
//  CashSAVO
//
//  Created by yyw on 2025/5/8.
//

import UIKit
import SnapKit

class MiniAppContainerNavigationView: UIView {
    var clickActionBlock: ((MiniAppContainerButtonView.ButtonType)->())?
    
    lazy var closeButton = {
        let button = MiniAppContainerButtonView(frame: .zero, types: [.close])
        return button
    }()
    
    lazy var closeButton2 = {
        let button = MiniAppContainerButtonView(frame: .zero, types: [.back, .close])
        return button
    }()
    
    lazy var downButton = {
        let button = MiniAppContainerButtonView(frame: .zero, types: [.down])
        return button
    }()
    
    lazy var moreButton = {
        let button = MiniAppContainerButtonView(frame: .zero, types: [.kefu, .more])
        return button
    }()
    
    lazy var titleLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    lazy var subtitleLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Miniapp"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.white
        
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(57)
            make.left.equalToSuperview().inset(15)
            make.width.equalTo(closeButton.viewWidth)
            make.height.equalTo(closeButton.viewHeight)
        }
        closeButton.clickBlock = { [weak self] type in
            guard let weakSelf = self else { return }
            weakSelf.clickActionBlock?(type)
        }
        
        addSubview(closeButton2)
        closeButton2.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(57)
            make.left.equalToSuperview().inset(UIScale(15))
            make.width.equalTo(closeButton2.viewWidth)
            make.height.equalTo(closeButton2.viewHeight)
        }
        closeButton2.clickBlock = { [weak self] type in
            guard let weakSelf = self else { return }
            weakSelf.clickActionBlock?(type)
        }
        closeButton2.isHidden = true
        
        addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton.snp.centerY)
            make.right.equalToSuperview().inset(15)
            make.width.equalTo(moreButton.viewWidth)
            make.height.equalTo(moreButton.viewHeight)
        }
        moreButton.clickBlock = { [weak self] type in
            guard let weakSelf = self else { return }
            weakSelf.clickActionBlock?(type)
        }
        
        addSubview(downButton)
        downButton.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton.snp.centerY)
            make.right.equalTo(moreButton.snp.left).offset(-8)
            make.width.equalTo(downButton.viewWidth)
            make.height.equalTo(downButton.viewHeight)
        }
        downButton.clickBlock = { [weak self] type in
            guard let weakSelf = self else { return }
            weakSelf.clickActionBlock?(type)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.top).offset(66)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(closeButton.snp.right).offset(UIScale(10))
            make.right.lessThanOrEqualTo(downButton.snp.left).offset(UIScale(-10))
        }
        
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.snp.top).offset(UIScale(86))
        }
    }
    
    func canGoBack(_ can: Bool) {
        
        if can {
            closeButton.isHidden = true
            closeButton2.isHidden = false
            titleLabel.snp.remakeConstraints { make in
                make.centerY.equalTo(self.snp.top).offset(UIScale(66))
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualTo(closeButton2.snp.right).offset(UIScale(10))
                make.right.lessThanOrEqualTo(downButton.snp.left).offset(UIScale(-10))
            }
        }
        else {
            closeButton.isHidden = false
            closeButton2.isHidden = true
            titleLabel.snp.remakeConstraints { make in
                make.centerY.equalTo(self.snp.top).offset(UIScale(66))
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualTo(closeButton.snp.right).offset(UIScale(10))
                make.right.lessThanOrEqualTo(downButton.snp.left).offset(UIScale(-10))
            }
        }        
    }
    
    func updateUI(_ name: String) {
        titleLabel.text = name
    }
}
