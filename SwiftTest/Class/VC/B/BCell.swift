//
//  BCell.swift
//  SwiftTest
//
//  Created by yyw on 2024/12/2.
//

import Foundation
import SnapKit
import YYKit

class LeftSlideCell: UITableViewCell {
    enum LeftSlide {
        case delete
        case mute
        case top
    }
    
    var changeEditingBlock: ((LeftSlideCell?) -> ())?
    var clickDeleteBlock: (() -> ())?
    var clickMuteBlock: (() -> ())?
    var clickTopBlock: (() -> ())?
    
    private lazy var swipeGesture_left = {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .left
        return swipeGesture
    }()
    
    private lazy var swipeGesture_right = {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .right
        return swipeGesture
    }()
    
    private lazy var panGesture = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        return panGesture
    }()
    
    lazy var wyy_backgroundView = {
        let view = UIView()
        view.setCornerRadius(UIScale(20))
        view.backgroundColor = .BG_F8F8F8_1
        return view
    }()
    
    lazy var wyy_contentView = {
        return UIView()
    }()
    
    var deleteButtonTransformX: CGFloat = 0
    lazy var deleteButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "im_delete"), for: .normal)
        return button
    }()
    
    var muteButtonTransformX: CGFloat = 0
    lazy var muteButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "im_mute"), for: .normal)
        return button
    }()
    
    var topButtonTransformX: CGFloat = 0
    lazy var topButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "im_top"), for: .normal)
        return button
    }()
    
    var rightWidth: CGFloat = 0
    var types: [LeftSlide] = []
    var originalCenter: CGPoint = .zero
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(wyy_backgroundView)
        wyy_backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: UIScale(8), bottom: 0, right: UIScale(8)))
        }
        wyy_backgroundView.alpha = 0.0
        
        contentView.addSubview(wyy_contentView)
        wyy_contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupGesture() {
        panGesture.require(toFail: swipeGesture_left)
        panGesture.require(toFail: swipeGesture_right)
        
        contentView.addGestureRecognizer(swipeGesture_left)
        contentView.addGestureRecognizer(swipeGesture_right)
        contentView.addGestureRecognizer(panGesture)
    }
    
    func setupLeftSlideView(_ types: [LeftSlide]) {
        deleteButton.removeFromSuperview()
        muteButton.removeFromSuperview()
        topButton.removeFromSuperview()
        
        self.types = types
        var right: CGFloat = UIScale(15)
        let width = UIScale(60)
        let height = UIScale(64)
        if types.contains(.delete) {
            contentView.addSubview(deleteButton)
            deleteButton.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(right)
                make.centerY.equalToSuperview()
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
            deleteButton.addTarget(self, action: #selector(clickDelete), for: .touchUpInside)
            right += UIScale(5) + width
            deleteButton.transform = CGAffineTransform(translationX: right + width, y: 0)
            deleteButtonTransformX = right
        }
        
        if types.contains(.mute) {
            contentView.addSubview(muteButton)
            muteButton.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(right)
                make.centerY.equalToSuperview()
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
            muteButton.addTarget(self, action: #selector(clickMute), for: .touchUpInside)
            right += UIScale(5) + width
            muteButton.transform = CGAffineTransform(translationX: right, y: 0)
            muteButtonTransformX = right
        }
        
        if types.contains(.top) {
            contentView.addSubview(topButton)
            topButton.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(right)
                make.centerY.equalToSuperview()
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
            topButton.addTarget(self, action: #selector(clickTop), for: .touchUpInside)
            right += width
            topButton.transform = CGAffineTransform(translationX: right, y: 0)
            topButtonTransformX = right
        }
        rightWidth = right
    }
    
    func showLeftSlideView(_ duration: Double, completion: @escaping (Bool) -> ()) {
        changeEditingBlock?(self)
        UIView.animate(withDuration: duration) {
            if self.types.contains(.delete) {
                self.deleteButton.transform = .identity
            }
            if self.types.contains(.mute) {
                self.muteButton.transform = .identity
            }
            if self.types.contains(.top) {
                self.topButton.transform = .identity
            }
            self.wyy_backgroundView.alpha = 1.0
            self.wyy_contentView.frame.origin.x = -self.rightWidth
        } completion: { s in
            completion(s)
        }
    }
    
    func hideLeftSlideView(_ duration: Double, completion: @escaping (Bool) -> ()) {
        changeEditingBlock?(nil)
        UIView.animate(withDuration: duration) {
            if self.types.contains(.delete) {
                self.deleteButton.transform = CGAffineTransform(translationX: self.deleteButtonTransformX, y: 0)
            }
            if self.types.contains(.mute) {
                self.muteButton.transform = CGAffineTransform(translationX: self.muteButtonTransformX, y: 0)
            }
            if self.types.contains(.top) {
                self.topButton.transform = CGAffineTransform(translationX: self.topButtonTransformX, y: 0)
            }
            self.wyy_backgroundView.alpha = 0.0
            self.wyy_contentView.frame.origin.x = 0
        } completion: { s in
            completion(s)
        }
    }
    
    @objc private func clickDelete(_ sender: Any) {
        clickDeleteBlock?()
    }
    
    @objc private func clickMute(_ sender: Any) {
        clickMuteBlock?()
    }
    
    @objc private func clickTop(_ sender: Any) {
        clickTopBlock?()
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            if gesture.direction == .left {
                showLeftSlideView(0.3) { _ in }
            }
            
            if gesture.direction == .right {
                hideLeftSlideView(0.3) { _ in }
            }
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            originalCenter = wyy_contentView.center
        case .changed:
            let translation = gesture.translation(in: self)
            let scale = translation.x / rightWidth
            print(scale)
            wyy_contentView.center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            
            if scale < 0 {
                if scale >= -1 {
                    wyy_backgroundView.alpha = -scale
                    if types.contains(.delete) {
                        deleteButton.transform = CGAffineTransform(translationX: deleteButtonTransformX * (1 + scale), y: 0)
                    }
                    if types.contains(.mute) {
                        muteButton.transform = CGAffineTransform(translationX: muteButtonTransformX * (1 + scale), y: 0)
                    }
                    if types.contains(.top) {
                        topButton.transform = CGAffineTransform(translationX: topButtonTransformX * (1 + scale), y: 0)
                    }
                }
            }
            else {
                if scale <= 1 {
                    wyy_backgroundView.alpha = 1 - scale
                    if types.contains(.delete) {
                        deleteButton.transform = CGAffineTransform(translationX: deleteButtonTransformX * scale, y: 0)
                    }
                    if types.contains(.mute) {
                        muteButton.transform = CGAffineTransform(translationX: muteButtonTransformX * scale, y: 0)
                    }
                    if types.contains(.top) {
                        topButton.transform = CGAffineTransform(translationX: topButtonTransformX * scale, y: 0)
                    }
                }
            }
            
            // 限制滑动范围
            if wyy_contentView.frame.origin.x < -rightWidth {
                wyy_contentView.frame.origin.x = -rightWidth
            }
            else if wyy_contentView.frame.origin.x > 0 {
                wyy_contentView.frame.origin.x = 0
            }
        case .ended, .cancelled:
            if wyy_contentView.frame.origin.x < -rightWidth/2.0 {
                showLeftSlideView(0.2) { _ in }
            } else {
                hideLeftSlideView(0.2) { _ in }
            }
        default:
            break
        }
    }
    
    func showWyy_backgroundView(_ duration: Double = 0.1) {
        UIView.animate(withDuration: duration) {
            self.wyy_backgroundView.alpha = 1.0
        }
    }
    
    func hideWyy_backgroundView(_ duration: Double = 0.1) {
        UIView.animate(withDuration: duration) {
            self.wyy_backgroundView.alpha = 0.0
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            let velocity = panGesture.velocity(in: self)
            return abs(velocity.x) > abs(velocity.y) // 只处理水平滑动
        }
        return true
    }
}

class BCell: LeftSlideCell {
    lazy var avatarView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.cornerRadius = 21
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    lazy var nameLabel = {
        let label = YYLabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var messageLabel = {
        let label = YYLabel()
        return label
    }()
    
    override func setupUI() {
        super.setupUI()
        
        wyy_contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(UIScale(18))
            make.width.height.equalTo(UIScale(54))
        }
        
        wyy_contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(wyy_contentView.snp.top).offset(UIScale(26))
            make.left.equalToSuperview().inset(UIScale(81))
        }
        
        wyy_contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(wyy_contentView.snp.top).offset(UIScale(52))
            make.left.equalToSuperview().inset(UIScale(81))
        }
    }
    
    func updateUI() {
        setupLeftSlideView([.delete, .mute, .top])
        self.avatarView.backgroundColor = .gray
        self.nameLabel.text = "测试测试测试测试测试测试测试测试测试测试测试"
        self.messageLabel.text = "测试测"
    }
}
