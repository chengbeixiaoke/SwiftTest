//
//  CALayer+Extension.swift
//  SPortal
//
//  Created by yyw on 2025/8/19.
//

import UIKit

extension CALayer {
    func setAnchorPoint(_ point: CGPoint)
    {
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

private var keyBorderLineThemeColor: UInt8 = 0
private var keyShadowThemeColor: UInt8 = 0

extension CALayer {
    public var borderLineThemeColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &keyBorderLineThemeColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &keyBorderLineThemeColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.borderColor = newValue?.cgColor
        }
    }
    
    public var shadowThemeColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &keyShadowThemeColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &keyShadowThemeColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.shadowColor = newValue?.cgColor
        }
    }
    
    func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        if let color = borderLineThemeColor {
            self.borderColor = color.cgColor
        }
        if let color = shadowThemeColor {
            self.shadowColor = color.cgColor
        }
    }
}

private var keyStrokeThemeColor: UInt8 = 0
private var keyFillThemeColor: UInt8 = 0

extension CAShapeLayer {
    public var strokeThemeColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &keyStrokeThemeColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &keyStrokeThemeColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.strokeColor = newValue?.cgColor
        }
    }
    
    public var fillThemeColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &keyFillThemeColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &keyFillThemeColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.fillColor = newValue?.cgColor
        }
    }
    
    func shapeLayerTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        if let color = strokeThemeColor {
            self.strokeColor = color.cgColor
        }
        if let color = fillThemeColor {
            self.fillColor = color.cgColor
        }
    }
}
