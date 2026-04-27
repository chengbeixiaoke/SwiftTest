//
//  UIView+Extension.swift
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
    
    func snapshotImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
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

extension UIView {
    @discardableResult
    func setGradientBackground(colors: [UIColor],
                               locations: [NSNumber],
                               startPoint: CGPoint,
                               endPoint: CGPoint,
                               size: CGSize) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.addSublayer(gradientLayer)
        return gradientLayer
    }
}


extension UIView {
    public func setCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = true
    }
}

public extension UIView {
    // MARK: 圆角
    typealias SSRadii = (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat)
    
    // MARK: - 边框配置
    struct BorderConfig {
        public var width: CGFloat
        public var color: UIColor
        public var dashPattern: [NSNumber]? = nil  // 可选：虚线设置，如 [5, 3]
        
        public init(width: CGFloat, color: UIColor, dashPattern: [NSNumber]? = nil) {
            self.width = width
            self.color = color
            self.dashPattern = dashPattern
        }
        
        public static let none = BorderConfig(width: 0, color: .clear)
    }
    
    // MARK: - 私有属性（使用关联对象存储边框层）
    private struct AssociatedKeys {
        static var borderLayerKey: UInt8 = 0
        static var radiiKey: UInt8 = 0
    }

    private var borderLayer: CAShapeLayer? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.borderLayerKey) as? CAShapeLayer }
        set { objc_setAssociatedObject(self, &AssociatedKeys.borderLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var viewRadii: SSRadii? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.radiiKey) as? SSRadii }
        set { objc_setAssociatedObject(self, &AssociatedKeys.radiiKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - 主方法：设置不同弧度的四个角（支持边框）
    
    /// 设置不同弧度的四个角
    /// - Parameters:
    ///   - radii: 角弧度
    ///   - borderConfig: 边框配置（可选）
    func setCornerRadii(_ radii: SSRadii, borderConfig: BorderConfig = .none)
    {
        // 确保 bounds 有效
        guard bounds.width > 0, bounds.height > 0 else { return }
        
        viewRadii = radii
        
        // 生成圆角路径
        let path = createRoundedRectPath(in: bounds, radii: radii)
        
        // 应用 mask
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
        // 处理边框
        updateBorderLayer(with: path, config: borderConfig)
    }
    
    // MARK: - 私有方法
    
    /// 创建圆角路径
    private func createRoundedRectPath(in bounds: CGRect, radii: SSRadii) -> UIBezierPath
    {
        
        // 如果所有角弧度相同且大于0，使用系统方法
        if radii.topLeft == radii.topRight && radii.topLeft == radii.bottomLeft && radii.topLeft == radii.bottomRight && radii.topLeft > 0 {
            printLog("[WYY]: \(bounds), \(radii.topLeft)")
            return UIBezierPath(roundedRect: CGRectMake(0, 0, 382, 61), cornerRadius: 25)
        }
        
        let path = UIBezierPath()
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY
        
        // 从左上角开始绘制
        path.move(to: CGPoint(x: minX + radii.topLeft, y: minY))
        
        // 上边和右上角
        path.addLine(to: CGPoint(x: maxX - radii.topRight, y: minY))
        if radii.topRight > 0 {
            path.addArc(withCenter: CGPoint(x: maxX - radii.topRight, y: minY + radii.topRight),
                        radius: radii.topRight,
                        startAngle: CGFloat(3 * Double.pi / 2),
                        endAngle: 0,
                        clockwise: true)
        }
        
        // 右边和右下角
        path.addLine(to: CGPoint(x: maxX, y: maxY - radii.bottomRight))
        if radii.bottomRight > 0 {
            path.addArc(withCenter: CGPoint(x: maxX - radii.bottomRight, y: maxY - radii.bottomRight),
                        radius: radii.bottomRight,
                        startAngle: 0,
                        endAngle: CGFloat(Double.pi / 2),
                        clockwise: true)
        }
        
        // 下边和左下角
        path.addLine(to: CGPoint(x: minX + radii.bottomLeft, y: maxY))
        if radii.bottomLeft > 0 {
            path.addArc(withCenter: CGPoint(x: minX + radii.bottomLeft, y: maxY - radii.bottomLeft),
                        radius: radii.bottomLeft,
                        startAngle: CGFloat(Double.pi / 2),
                        endAngle: CGFloat(Double.pi),
                        clockwise: true)
        }
        
        // 左边和左上角
        path.addLine(to: CGPoint(x: minX, y: minY + radii.topLeft))
        if radii.topLeft > 0 {
            path.addArc(withCenter: CGPoint(x: minX + radii.topLeft, y: minY + radii.topLeft),
                        radius: radii.topLeft,
                        startAngle: CGFloat(Double.pi),
                        endAngle: CGFloat(3 * Double.pi / 2),
                        clockwise: true)
        }
        
        path.close()
        return path
    }
    
    /// 更新边框层（内边框）- 推荐版本
    func updateBorderLayer(with path: UIBezierPath,
                           config: BorderConfig)
    {
        guard let radii = viewRadii else { return }
        
        // 移除旧的边框层
        borderLayer?.removeFromSuperlayer()
        
        // 如果不需要边框，直接返回
        guard config.width > 0, config.color != .clear else { return }
        
        // 创建边框层
        let border = CAShapeLayer()
        border.frame = bounds
        
        // 内边框：向内缩进半个线宽
        let inset = config.width / 2
        let insetRect = bounds.insetBy(dx: inset, dy: inset)
        
        let _radii = (topLeft: radii.topLeft - inset,
                      topRight: radii.topRight - inset,
                      bottomLeft: radii.bottomLeft - inset,
                      bottomRight: radii.bottomRight - inset)
        let insetPath = createRoundedRectPath(in: insetRect, radii: _radii)
        border.path = insetPath.cgPath
        border.strokeColor = config.color.cgColor
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = config.width
        border.lineDashPattern = config.dashPattern
        border.name = "com.view.borderLayer"
        
        self.layer.addSublayer(border)
        self.borderLayer = border
    }
    
    // MARK: - 辅助方法
    /// 更新边框（当需要单独修改边框时调用）
    func updateBorder(_ config: BorderConfig)
    {
        guard let currentPath = (self.layer.mask as? CAShapeLayer)?.path else { return }
        let path = UIBezierPath(cgPath: currentPath)
        updateBorderLayer(with: path, config: config)
    }
    
    /// 移除边框
    func removeBorder()
    {
        borderLayer?.removeFromSuperlayer()
        borderLayer = nil
    }
}
