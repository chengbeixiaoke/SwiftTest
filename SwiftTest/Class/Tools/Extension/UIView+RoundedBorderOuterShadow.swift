//
//  UIView+RoundedBorderOuterShadow.swift
//  CashSAVO
//
//  Created by Codex on 2026/3/19.
//

import UIKit
import ObjectiveC

public struct YYViewCornerRadii {
    public var topLeft: CGFloat
    public var topRight: CGFloat
    public var bottomLeft: CGFloat
    public var bottomRight: CGFloat

    public init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.topLeft = max(0, topLeft)
        self.topRight = max(0, topRight)
        self.bottomLeft = max(0, bottomLeft)
        self.bottomRight = max(0, bottomRight)
    }

    public static func all(_ radius: CGFloat) -> YYViewCornerRadii {
        YYViewCornerRadii(topLeft: radius, topRight: radius, bottomLeft: radius, bottomRight: radius)
    }
}

private final class YYRoundedBorderShadowStyle: NSObject {
    let corners: YYViewCornerRadii
    let borderWidth: CGFloat
    let borderColor: UIColor
    let shadowColor: UIColor
    let shadowOpacity: Float
    let shadowOffset: CGSize
    let shadowRadius: CGFloat
    let shadowSpread: CGFloat

    init(corners: YYViewCornerRadii,
         borderWidth: CGFloat,
         borderColor: UIColor,
         shadowColor: UIColor,
         shadowOpacity: Float,
         shadowOffset: CGSize,
         shadowRadius: CGFloat,
         shadowSpread: CGFloat) {
        self.corners = corners
        self.borderWidth = max(0, borderWidth)
        self.borderColor = borderColor
        self.shadowColor = shadowColor
        self.shadowOpacity = max(0, shadowOpacity)
        self.shadowOffset = shadowOffset
        self.shadowRadius = max(0, shadowRadius)
        self.shadowSpread = shadowSpread
    }
}

private enum YYRoundedBorderShadowAssociatedKeys {
    static var style = 0
    static var maskLayer = 0
    static var borderLayer = 0
    static var shadowLayer = 0
    static var didSwizzle = 0
}

public extension UIView {
    func yy_applyRoundedBorderAndOuterShadow(corners: YYViewCornerRadii,
                                             borderWidth: CGFloat,
                                             borderColor: UIColor,
                                             shadowColor: UIColor = .black,
                                             shadowOpacity: Float = 0.18,
                                             shadowOffset: CGSize = .zero,
                                             shadowRadius: CGFloat = 12,
                                             shadowSpread: CGFloat = 0) {
        yy_enableRoundedBorderShadowLifecycleIfNeeded()

        let style = YYRoundedBorderShadowStyle(corners: corners,
                                               borderWidth: borderWidth,
                                               borderColor: borderColor,
                                               shadowColor: shadowColor,
                                               shadowOpacity: shadowOpacity,
                                               shadowOffset: shadowOffset,
                                               shadowRadius: shadowRadius,
                                               shadowSpread: shadowSpread)
        objc_setAssociatedObject(self,
                                 &YYRoundedBorderShadowAssociatedKeys.style,
                                 style,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        yy_updateRoundedBorderAndOuterShadow()
    }

    func yy_removeRoundedBorderAndOuterShadow() {
        (objc_getAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.maskLayer) as? CAShapeLayer)?.removeFromSuperlayer()
        (objc_getAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.borderLayer) as? CAShapeLayer)?.removeFromSuperlayer()
        (objc_getAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.shadowLayer) as? CAShapeLayer)?.removeFromSuperlayer()

        layer.mask = nil

        objc_setAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.style, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.maskLayer, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.borderLayer, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.shadowLayer, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func yy_updateRoundedBorderAndOuterShadow() {
        guard let style = objc_getAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.style) as? YYRoundedBorderShadowStyle else {
            return
        }
        guard bounds.width > 0, bounds.height > 0 else {
            return
        }

        let outerPath = yy_bezierPath(in: bounds, corners: style.corners)
        let insetAmount = style.borderWidth * 0.5
        let borderRect = bounds.insetBy(dx: insetAmount, dy: insetAmount)
        let borderCorners = yy_insetCorners(style.corners, amount: insetAmount)
        let borderPath = yy_bezierPath(in: borderRect, corners: borderCorners)

        let maskLayer = yy_maskLayer()
        maskLayer.frame = bounds
        maskLayer.path = outerPath.cgPath
        layer.mask = maskLayer

        let borderLayer = yy_borderLayer()
        borderLayer.frame = bounds
        borderLayer.path = borderPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = style.borderColor.cgColor
        borderLayer.lineWidth = style.borderWidth
        borderLayer.lineJoin = .round
        borderLayer.lineCap = .round
        borderLayer.contentsScale = UIScreen.main.scale
        if borderLayer.superlayer !== layer {
            borderLayer.removeFromSuperlayer()
            layer.addSublayer(borderLayer)
        }

        guard let superview else {
            (objc_getAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.shadowLayer) as? CAShapeLayer)?.removeFromSuperlayer()
            return
        }

        let shadowLayer = yy_shadowLayer()
        let shadowInset = yy_shadowInset(shadowRadius: style.shadowRadius,
                                         shadowOffset: style.shadowOffset,
                                         spread: style.shadowSpread)
        let frameInSuperview = convert(bounds, to: superview)
        let expandedFrame = frameInSuperview.insetBy(dx: -shadowInset, dy: -shadowInset)
        shadowLayer.frame = expandedFrame

        let shapeRect = CGRect(x: shadowInset, y: shadowInset, width: bounds.width, height: bounds.height)
        let shapePath = yy_bezierPath(in: shapeRect, corners: style.corners)
        shadowLayer.path = shapePath.cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.strokeColor = UIColor.clear.cgColor
        shadowLayer.lineWidth = 0
        shadowLayer.shadowColor = style.shadowColor.cgColor
        shadowLayer.shadowOpacity = style.shadowOpacity
        shadowLayer.shadowOffset = style.shadowOffset
        shadowLayer.shadowRadius = style.shadowRadius
        shadowLayer.shadowPath = yy_shadowPath(for: shapeRect,
                                               corners: style.corners,
                                               spread: style.shadowSpread).cgPath
        shadowLayer.mask = yy_outerShadowMaskLayer(for: shadowLayer.bounds,
                                                   innerRect: shapeRect,
                                                   corners: style.corners)

        if shadowLayer.superlayer !== superview.layer {
            shadowLayer.removeFromSuperlayer()
            superview.layer.insertSublayer(shadowLayer, below: layer)
        } else if let index = layer.superlayer?.sublayers?.firstIndex(of: layer), shadowLayer.superlayer === superview.layer {
            shadowLayer.removeFromSuperlayer()
            superview.layer.insertSublayer(shadowLayer, at: UInt32(max(index, 0)))
        }
    }
}

private extension UIView {
    func yy_maskLayer() -> CAShapeLayer {
        if let layer = objc_getAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.maskLayer) as? CAShapeLayer {
            return layer
        }
        let layer = CAShapeLayer()
        objc_setAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.maskLayer, layer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return layer
    }

    func yy_borderLayer() -> CAShapeLayer {
        if let layer = objc_getAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.borderLayer) as? CAShapeLayer {
            return layer
        }
        let layer = CAShapeLayer()
        objc_setAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.borderLayer, layer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return layer
    }

    func yy_shadowLayer() -> CAShapeLayer {
        if let layer = objc_getAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.shadowLayer) as? CAShapeLayer {
            return layer
        }
        let layer = CAShapeLayer()
        objc_setAssociatedObject(self, &YYRoundedBorderShadowAssociatedKeys.shadowLayer, layer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return layer
    }

    func yy_enableRoundedBorderShadowLifecycleIfNeeded() {
        let hasSwizzled = (objc_getAssociatedObject(UIView.self, &YYRoundedBorderShadowAssociatedKeys.didSwizzle) as? Bool) ?? false
        guard !hasSwizzled else { return }

        objc_setAssociatedObject(UIView.self,
                                 &YYRoundedBorderShadowAssociatedKeys.didSwizzle,
                                 true,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let originalLayout = class_getInstanceMethod(UIView.self, #selector(UIView.layoutSubviews))
        let swizzledLayout = class_getInstanceMethod(UIView.self, #selector(UIView.yy_layoutSubviewsForRoundedBorderShadow))
        if let originalLayout, let swizzledLayout {
            method_exchangeImplementations(originalLayout, swizzledLayout)
        }

        let originalSuperview = class_getInstanceMethod(UIView.self, #selector(UIView.didMoveToSuperview))
        let swizzledSuperview = class_getInstanceMethod(UIView.self, #selector(UIView.yy_didMoveToSuperviewForRoundedBorderShadow))
        if let originalSuperview, let swizzledSuperview {
            method_exchangeImplementations(originalSuperview, swizzledSuperview)
        }
    }

    @objc func yy_layoutSubviewsForRoundedBorderShadow() {
        yy_layoutSubviewsForRoundedBorderShadow()
        yy_updateRoundedBorderAndOuterShadow()
    }

    @objc func yy_didMoveToSuperviewForRoundedBorderShadow() {
        yy_didMoveToSuperviewForRoundedBorderShadow()
        yy_updateRoundedBorderAndOuterShadow()
    }

    func yy_shadowPath(for rect: CGRect, corners: YYViewCornerRadii, spread: CGFloat) -> UIBezierPath {
        guard spread != 0 else {
            return yy_bezierPath(in: rect, corners: corners)
        }

        let expandedRect = rect.insetBy(dx: -spread, dy: -spread)
        let expandedCorners = YYViewCornerRadii(topLeft: corners.topLeft + spread,
                                                topRight: corners.topRight + spread,
                                                bottomLeft: corners.bottomLeft + spread,
                                                bottomRight: corners.bottomRight + spread)
        return yy_bezierPath(in: expandedRect, corners: expandedCorners)
    }

    func yy_outerShadowMaskLayer(for rect: CGRect,
                                 innerRect: CGRect,
                                 corners: YYViewCornerRadii) -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: rect)
        path.append(yy_bezierPath(in: innerRect, corners: corners))
        path.usesEvenOddFillRule = true
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        return maskLayer
    }

    func yy_shadowInset(shadowRadius: CGFloat, shadowOffset: CGSize, spread: CGFloat) -> CGFloat {
        max(shadowRadius * 2 + max(abs(shadowOffset.width), abs(shadowOffset.height)) + abs(spread), 1)
    }

    func yy_insetCorners(_ corners: YYViewCornerRadii, amount: CGFloat) -> YYViewCornerRadii {
        YYViewCornerRadii(topLeft: max(0, corners.topLeft - amount),
                          topRight: max(0, corners.topRight - amount),
                          bottomLeft: max(0, corners.bottomLeft - amount),
                          bottomRight: max(0, corners.bottomRight - amount))
    }

    func yy_bezierPath(in rect: CGRect, corners: YYViewCornerRadii) -> UIBezierPath {
        let normalized = yy_normalizedCorners(for: rect, corners: corners)
        let minX = rect.minX
        let maxX = rect.maxX
        let minY = rect.minY
        let maxY = rect.maxY

        let path = UIBezierPath()
        path.move(to: CGPoint(x: minX + normalized.topLeft, y: minY))
        path.addLine(to: CGPoint(x: maxX - normalized.topRight, y: minY))

        if normalized.topRight > 0 {
            path.addArc(withCenter: CGPoint(x: maxX - normalized.topRight, y: minY + normalized.topRight),
                        radius: normalized.topRight,
                        startAngle: -.pi / 2,
                        endAngle: 0,
                        clockwise: true)
        }

        path.addLine(to: CGPoint(x: maxX, y: maxY - normalized.bottomRight))

        if normalized.bottomRight > 0 {
            path.addArc(withCenter: CGPoint(x: maxX - normalized.bottomRight, y: maxY - normalized.bottomRight),
                        radius: normalized.bottomRight,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: true)
        }

        path.addLine(to: CGPoint(x: minX + normalized.bottomLeft, y: maxY))

        if normalized.bottomLeft > 0 {
            path.addArc(withCenter: CGPoint(x: minX + normalized.bottomLeft, y: maxY - normalized.bottomLeft),
                        radius: normalized.bottomLeft,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: true)
        }

        path.addLine(to: CGPoint(x: minX, y: minY + normalized.topLeft))

        if normalized.topLeft > 0 {
            path.addArc(withCenter: CGPoint(x: minX + normalized.topLeft, y: minY + normalized.topLeft),
                        radius: normalized.topLeft,
                        startAngle: .pi,
                        endAngle: .pi * 1.5,
                        clockwise: true)
        }

        path.close()
        return path
    }

    func yy_normalizedCorners(for rect: CGRect, corners: YYViewCornerRadii) -> YYViewCornerRadii {
        guard rect.width > 0, rect.height > 0 else {
            return .all(0)
        }

        var topLeft = min(corners.topLeft, rect.width * 0.5, rect.height * 0.5)
        var topRight = min(corners.topRight, rect.width * 0.5, rect.height * 0.5)
        var bottomLeft = min(corners.bottomLeft, rect.width * 0.5, rect.height * 0.5)
        var bottomRight = min(corners.bottomRight, rect.width * 0.5, rect.height * 0.5)

        let topScale = min(1, rect.width / max(topLeft + topRight, 0.0001))
        let bottomScale = min(1, rect.width / max(bottomLeft + bottomRight, 0.0001))
        let leftScale = min(1, rect.height / max(topLeft + bottomLeft, 0.0001))
        let rightScale = min(1, rect.height / max(topRight + bottomRight, 0.0001))

        topLeft *= min(topScale, leftScale)
        topRight *= min(topScale, rightScale)
        bottomLeft *= min(bottomScale, leftScale)
        bottomRight *= min(bottomScale, rightScale)

        return YYViewCornerRadii(topLeft: topLeft,
                                 topRight: topRight,
                                 bottomLeft: bottomLeft,
                                 bottomRight: bottomRight)
    }
}
