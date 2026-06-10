//
//  BaseView.swift
//  SavoBaseModule
//
//  Created by yyw on 2025/8/20.
//

import UIKit
import YYKit

open class BaseView: UIView {
    // 缓存注册的监听深浅色变化的token
    private var colorAppearanceChangeRegistration: Any?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 注册 深/浅 颜色变化的监听
        configureColorAppearanceObservation()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // iOS17之前的系统使用该方法监听深/浅色变化
    final public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #unavailable(iOS 17.0) {
            guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
            colorAppearanceDidChange(from: previousTraitCollection)
        }
    }
    
    // iOS17之后的系统使用该方法监听深/浅色变化
    open func colorAppearanceDidChange(from previousTraitCollection: UITraitCollection?) {
        
    }
    
    deinit {
#if DEBUG
        printLog("[View] - deinit:\(self.className())")
#endif
    }
}

private extension BaseView {
    func configureColorAppearanceObservation() {
        if #available(iOS 17.0, *) {
            colorAppearanceChangeRegistration = registerForTraitChanges([UITraitUserInterfaceStyle.self, UITraitAccessibilityContrast.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                guard self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
                self.colorAppearanceDidChange(from: previousTraitCollection)
            }
        }
    }
}
