//
//  UIView+Tools.swift
//  SwiftTest
//
//  Created by yyw on 2025/1/21.
//

import UIKit

extension UIView {
    func corner(byRoundingCorners corners: CACornerMask, radii: CGFloat) {
        self.layer.cornerRadius = radii
        self.layer.cornerCurve = .continuous
        self.layer.maskedCorners = corners
        self.clipsToBounds = true
    }
}

extension CALayer {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * anchorPoint.x, y: bounds.size.height * anchorPoint.y)
        
        newPoint = newPoint.applying(affineTransform())
        oldPoint = oldPoint.applying(affineTransform())
        
        var position = self.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.position = position
        self.anchorPoint = point
    }
}

extension UIView {
    func addShadowWithImageMask(offset: CGSize = CGSize(width: 2, height: 2),
                                radius: CGFloat = 5,
                                opacity: Float = 0.7,
                                color: UIColor = .black) {
        // 创建容器
        let container = UIView(frame: frame)
        container.backgroundColor = .clear
        
        // 转移imageView到容器
        let oldFrame = frame
        
        guard let oldSuperview = superview else { return }
        container.addSubview(self)
        
        frame = CGRect(origin: .zero, size: oldFrame.size)
        
        // 设置阴影
        container.layer.shadowColor = color.cgColor
        container.layer.shadowOffset = offset
        container.layer.shadowRadius = radius
        container.layer.shadowOpacity = opacity
        
        // 添加回视图层级
        oldSuperview.addSubview(container)
    }
}

