//
//  BCell.swift
//  SwiftTest
//
//  Created by yyw on 2024/12/2.
//

import Foundation
import SnapKit

class BCell: UITableViewCell {
    var longPress:((UIView)->())?
    
    
    lazy var avatarView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.cornerRadius = 21
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    lazy var nameLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var callingButton = {
        let button = UIButton()
        button.setTitle("打电话", for: .normal)
        button.backgroundColor = .red
        return button
    }()
    
    lazy var messageLabel = {
        let label = UILabel()
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setUpContentView()
        
        self.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_ :))))
    }
    
    @objc func longPressAction(_ longPress: UIGestureRecognizer) {
        if longPress.state == .began {
            self.longPress?(self.contentView)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpContentView() {
        
        let selectedBg = UIView()
        selectedBg.layer.cornerRadius = 15
        selectedBg.layer.masksToBounds = true
        selectedBg.layer.cornerCurve = .continuous
        selectedBg.backgroundColor = .gray
        
        let bgview = UIView(frame: .zero)
        bgview.addSubview(selectedBg)
        selectedBg.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)).priority(.high)
        }
        selectedBackgroundView = bgview
        
        self.backgroundColor = .white
        
        self.contentView.addSubview(self.avatarView)
        self.avatarView.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.leading.equalTo(self.contentView.snp.leading).offset(18)
            make.size.equalTo(CGSize(width: 42, height: 42))
        }
        
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.avatarView.snp.trailing).offset(30)
        }
        
        self.contentView.addSubview(callingButton)
        callingButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 40))
        }
    }
    
    func updateContactView() {
        self.nameLabel.text = "测试测试测试测试测试测试测试测试测试测试测试"
        self.messageLabel.text = "测试测"
    }
}
