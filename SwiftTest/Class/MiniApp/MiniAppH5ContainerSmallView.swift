//
//  MiniAppH5ContainerSmallView.swift
//  SwiftTest
//
//  Created by yyw on 2025/6/18.
//

import UIKit
import SnapKit

class MiniAppH5ContainerSmallView: UIView {
    var clickViewBlock: (()->())?
    
    lazy var logoView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.cornerRadius = UIScale(15)
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nameLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var authenticationImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "miniapp_authentication_icon")
        return imageView
    }()
    
    lazy var arrowImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "miniapp_arrow_20x20")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        let tap = UITapGestureRecognizer { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.clickViewBlock?()
        }
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let shadowView = UIView()
        shadowView.frame = CGRectMake(0, 0, frame.width, frame.height)
        shadowView.clipsToBounds = false
        addSubview(shadowView)

        let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: frame.width / 2.0)
        shadowView.layer.shadowPath = shadowPath.cgPath
        shadowView.layer.shadowThemeColor = .BG_E4E5E6
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 8
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        let strokeView = UIView()
        strokeView.frame = bounds.insetBy(dx: -1, dy: -1)
        strokeView.layer.cornerRadius = 25
        strokeView.layer.borderWidth = 1
        strokeView.layer.borderLineThemeColor = .BL_F1F1F1
        strokeView.layer.masksToBounds = true
        addSubview(strokeView)
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = UIScale(25)
        bgView.layer.cornerCurve = .continuous
        bgView.layer.masksToBounds = true
        bgView.frame = bounds
        addSubview(bgView)
        
        addSubview(logoView)
        logoView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(UIScale(10))
            make.width.height.equalTo(UIScale(32))
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(UIScale(52))
        }
        
        addSubview(authenticationImageView)
        authenticationImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(nameLabel.snp.right).offset(UIScale(5))
            make.width.height.equalTo(UIScale(14))
        }
        
        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(UIScale(12))
            make.size.equalTo(CGSize(width: UIScale(20), height: UIScale(20)))
        }

        updateUI()
    }
    
    func updateUI() {
        logoView.image = UIImage(named: "miniapp_auth_icon_1")
        nameLabel.text = "RAMP (By SAVO)"
    }
}
