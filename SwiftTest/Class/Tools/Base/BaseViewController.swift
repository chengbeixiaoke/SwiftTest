//
//  BaseViewController.swift
//  SavoBaseModule
//
//  Created by yyw on 2025/8/19.
//

import UIKit
import YYKit
import SnapKit

open class BaseViewController: UIViewController {
    // 缓存注册的监听深浅色变化的token
    private var colorAppearanceChangeRegistration: Any?
    
    // 生命周期回调
    public var viewWillAppearBlock: ((BaseViewController)->())?
    public var viewDidAppearBlock: ((BaseViewController)->())?
    public var viewWillDisappearBlock: ((BaseViewController)->())?
    public var viewDidDisappearBlock: ((BaseViewController)->())?
            
    // VC 背景颜色
    // 弹窗类型的背景色是181818
    open var viewBackgroundColor: UIColor {
        return .BG_FFFFFF_1_181818_1
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewWillAppearBlock?(self)
        printLog("[VC] - viewWillAppear: \(self.className())")
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearBlock?(self)
        printLog("[VC] - viewDidAppear: \(self.className())")
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearBlock?(self)
        printLog("[VC] - viewWillDisappear: \(self.className())")
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDisappearBlock?(self)
        printLog("[VC] - viewDidDisappear: \(self.className())")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册 深/浅 颜色变化的监听
        configureColorAppearanceObservation()
        
        view.backgroundColor = viewBackgroundColor
    }
    
    open func clickBackAction() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
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
        printLog("[VC] - deinit:\(self.className())")
    }
}

private extension BaseViewController {
    func configureColorAppearanceObservation() {
        if #available(iOS 17.0, *) {
            colorAppearanceChangeRegistration = registerForTraitChanges([UITraitUserInterfaceStyle.self, UITraitAccessibilityContrast.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                guard self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
                self.colorAppearanceDidChange(from: previousTraitCollection)
            }
        }
    }
}
