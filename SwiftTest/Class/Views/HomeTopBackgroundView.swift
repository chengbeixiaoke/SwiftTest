//
//  HomeTopBackgroundView.swift
//  CashSAVO
//
//  Created by yyw on 2025/12/22.
//

import UIKit
import SnapKit

class HomeTopBackgroundView: UIView {
    private let radius = WidthScreen * 0.7
    
    private var contentView: UIView = UIView()
    private var leftGradientView: HomeTopBackgroundGradientView?
    private var rightGradientView: HomeTopBackgroundGradientView?
    private var centerGradientView: HomeTopBackgroundGradientView?
    private var gradientLayer: CAGradientLayer?
    
    private var displayLink: CADisplayLink?
    private var gradientColor: GradientColor!
    
    private var level: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentView)
        contentView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateAlpha(_ alpha: CGFloat) {
        contentView.alpha = alpha
    }
    
    public func updateLevel(level: Int) {
        if self.level == level {
            return
        }
        self.level = level
        
        displayLink?.invalidate()
        displayLink = nil
        contentView.alpha = contentViewAlpha
        
        leftGradientView?.removeFromSuperview()
        rightGradientView?.removeFromSuperview()
        centerGradientView?.removeFromSuperview()
        
        gradientColor = GradientColor.color(level: level)
        do {
            let position = CGPointMake(0, 0)
            let frame =  CGRectMake(-radius, 0, radius*2.0, radius*2.0)
            let leftGradientView = HomeTopBackgroundGradientView(frame: frame,
                                                                 position: position,
                                                                 velocity: randomVelocity(),
                                                                 colors: gradientColor.left)
            leftGradientView.center = position
            contentView.addSubview(leftGradientView)
            self.leftGradientView = leftGradientView
        }
        
        do {
            let position = CGPointMake(WidthScreen, 0)
            let frame = CGRectMake(WidthScreen - radius, 0, radius*2.0, radius*2.0)
            let rightGradientView = HomeTopBackgroundGradientView(frame: frame,
                                                                  position: position,
                                                                  velocity: randomVelocity(),
                                                                  colors: gradientColor.right)
            rightGradientView.center = position
            contentView.addSubview(rightGradientView)
            self.rightGradientView = rightGradientView
        }
        
        do {
            let position = CGPointMake(WidthScreen / 2.0, 0)
            let frame = CGRectMake(radius, 0, radius*2.0, radius*2.0)
            let centerGradientView = HomeTopBackgroundGradientView(frame: frame,
                                                                   position: position,
                                                                   velocity: randomVelocity(),
                                                                   colors: gradientColor.center)
            centerGradientView.center = position
            contentView.addSubview(centerGradientView)
            self.centerGradientView = centerGradientView
        }
        
        updateBlurEffect()
        
        startAnimation()
    }
    
    private func updateBlurEffect() {
        gradientLayer?.removeFromSuperlayer()
        
        if AppThemeModeManager.isDark() {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = [UIColor.ColorFromHex("000000"),
                                    UIColor.ColorFromHex("000000", 0.58),
                                    UIColor.ColorFromHex("000000", 0.0)].map { $0.cgColor }
            gradientLayer.locations = [0.0, 0.45, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            contentView.layer.addSublayer(gradientLayer)
            self.gradientLayer = gradientLayer
        } else {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = [UIColor.ColorFromHex("FFFFFF"),
                                    UIColor.ColorFromHex("FFFFFF", 0.7),
                                    UIColor.ColorFromHex("000000", 0.01)].map { $0.cgColor }
            gradientLayer.locations = [0.0, 0.3, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            contentView.layer.addSublayer(gradientLayer)
            self.gradientLayer = gradientLayer
        }
    }
    
    private func startAnimation() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateUI() {
        let viewWidth = bounds.size.width
        let y_min = -radius/8.0
        let y_max = UIScale(440) - radius/4.0
        let x_min = -radius/8.0
        let x_max = viewWidth + radius/8.0
        
        guard let leftGradientView = leftGradientView, let rightGradientView = rightGradientView, let centerGradientView = centerGradientView else { return }
        
        // 更新位置
        leftGradientView.position.x += leftGradientView.velocity.dx
        leftGradientView.position.y += leftGradientView.velocity.dy
        
        rightGradientView.position.x += rightGradientView.velocity.dx
        rightGradientView.position.y += rightGradientView.velocity.dy
        
        centerGradientView.position.x += centerGradientView.velocity.dx
        centerGradientView.position.y += centerGradientView.velocity.dy
        
        // 边界碰撞检测
        if leftGradientView.position.x >= viewWidth - radius/2.0 {
            leftGradientView.position.x = viewWidth - radius/2.0
            leftGradientView.velocity.dx *= -1
        }
        
        if leftGradientView.position.x <= x_min {
            leftGradientView.position.x = x_min
            leftGradientView.velocity.dx *= -1
        }
        
        if leftGradientView.position.y >= y_max * 0.5 {
            leftGradientView.position.y = y_max * 0.5
            leftGradientView.velocity.dy *= -1
        }
        
        if leftGradientView.position.y <= y_min {
            leftGradientView.position.y = y_min
            leftGradientView.velocity.dy *= -1
        }
        
        // 边界碰撞检测
        if rightGradientView.position.x >= x_max {
            rightGradientView.position.x = x_max
            rightGradientView.velocity.dx *= -1
        }
        
        if rightGradientView.position.x <= radius/2.0 {
            rightGradientView.position.x = radius/2.0
            rightGradientView.velocity.dx *= -1
        }
        
        if rightGradientView.position.y >= y_max * 0.8 {
            rightGradientView.position.y = y_max * 0.8
            rightGradientView.velocity.dy *= -1
        }
        
        if rightGradientView.position.y <= y_min {
            rightGradientView.position.y = y_min
            rightGradientView.velocity.dy *= -1
        }
        
        // 边界碰撞检测
        if centerGradientView.position.x >= viewWidth - radius/4.0 {
            centerGradientView.position.x = viewWidth - radius/4.0
            centerGradientView.velocity.dx *= -1
        }
        
        if centerGradientView.position.x <= radius/4.0 {
            centerGradientView.position.x = radius/4.0
            centerGradientView.velocity.dx *= -1
        }
        
        if centerGradientView.position.y >= y_max {
            centerGradientView.position.y = y_max
            centerGradientView.velocity.dy *= -1
        }
        
        if centerGradientView.position.y <= y_min {
            centerGradientView.position.y = y_min
            centerGradientView.velocity.dy *= -1
        }
        
        // 色块碰撞检测
        if leftGradientView.center.distance(from: rightGradientView.center) < radius/2.0 {
            leftGradientView.velocity.dx *= -1
            
            rightGradientView.velocity.dy *= -1
        }
        
        if leftGradientView.center.distance(from: centerGradientView.center) < radius/2.0 {
            leftGradientView.velocity.dx *= -1
            
            centerGradientView.velocity.dy *= -1
        }
        
        if rightGradientView.center.distance(from: centerGradientView.center) < radius/2.0 {
            rightGradientView.velocity.dx *= -1
            
            centerGradientView.velocity.dy *= -1
        }
        
        leftGradientView.center = leftGradientView.position
        rightGradientView.center = rightGradientView.position
        centerGradientView.center = centerGradientView.position
    }
    
    private func randomVelocity() -> CGVector {
        let minSpeed: CGFloat = 0.5
        let maxSpeed: CGFloat = 2.0
        
        return CGVector(dx: CGFloat.random(in: minSpeed...maxSpeed) * (Bool.random() ? 1 : -1),
                        dy: CGFloat.random(in: minSpeed...maxSpeed) * (Bool.random() ? 1 : -1))
    }
    
    public var contentViewAlpha: CGFloat {
        switch level {
        case 1:
            // 绿
            return 0.2
            
        case 2:
            // 橙
            return 0.2
            
        case 3:
            // 蓝
            return 0.2
            
        case 4:
            // 紫
            return 0.23
            
        case 5, 6:
            // 红
            return AppThemeModeManager.isDark() ? 0.2 : 0.17
            
        default:
            return 0.2
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateBlurEffect()
        }
    }
    
    deinit {
        displayLink?.invalidate()
        displayLink = nil
    }
}

extension HomeTopBackgroundView {
    struct GradientColor {
        let left: [UIColor]
        let right: [UIColor]
        let center: [UIColor]
        
        init(left: [UIColor], right: [UIColor], center: [UIColor]) {
            self.left = left
            self.right = right
            self.center = center
        }
        
        static func color(level: Int) -> GradientColor {
            switch level {
            case 1:
                return GradientColor(left: [UIColor.Level_0_Left_1, UIColor.Level_0_Left_0],
                                     right: [UIColor.Level_0_Right_1, UIColor.Level_0_Right_0],
                                     center: [UIColor.Level_0_Center_1, UIColor.Level_0_Center_0])
                
            case 2:
                return GradientColor(left: [UIColor.Level_1_Left_1, UIColor.Level_1_Left_0],
                                     right: [UIColor.Level_1_Right_1, UIColor.Level_1_Right_0],
                                     center: [UIColor.Level_1_Center_1, UIColor.Level_1_Center_0])
                
            case 3:
                return GradientColor(left: [UIColor.Level_2_Left_1, UIColor.Level_2_Left_0],
                                     right: [UIColor.Level_2_Right_1, UIColor.Level_2_Right_0],
                                     center: [UIColor.Level_2_Center_1, UIColor.Level_2_Center_0])
                
            case 4:
                return GradientColor(left: [UIColor.Level_3_Left_1, UIColor.Level_3_Left_0],
                                     right: [UIColor.Level_3_Right_1, UIColor.Level_3_Right_0],
                                     center: [UIColor.Level_3_Center_1, UIColor.Level_3_Center_0])
                
            case 5:
                return GradientColor(left: [UIColor.Level_4_Left_1, UIColor.Level_4_Left_0],
                                     right: [UIColor.Level_4_Right_1, UIColor.Level_4_Right_0],
                                     center: [UIColor.Level_4_Center_1, UIColor.Level_4_Center_0])
                
            case 6:
                return GradientColor(left: [UIColor.Level_5_Left_1, UIColor.Level_5_Left_0],
                                     right: [UIColor.Level_5_Right_1, UIColor.Level_5_Right_0],
                                     center: [UIColor.Level_5_Center_1, UIColor.Level_5_Center_0])
                
            default:
                return GradientColor(left: [UIColor.Level_0_Left_1, UIColor.Level_0_Left_0],
                                     right: [UIColor.Level_0_Right_1, UIColor.Level_0_Right_0],
                                     center: [UIColor.Level_0_Center_1, UIColor.Level_0_Center_0])
            }
        }
    }
}

class HomeTopBackgroundGradientView: UIView {
    var position: CGPoint
    var velocity: CGVector
    let colors: [UIColor]
    
    init(frame: CGRect, position: CGPoint, velocity: CGVector, colors: [UIColor]) {
        self.position = position
        self.velocity = velocity
        self.colors = colors
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.type = .radial
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(gradientLayer)
    }
}
