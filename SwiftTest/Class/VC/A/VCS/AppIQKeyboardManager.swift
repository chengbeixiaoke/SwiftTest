//
//  AppIQKeyboardManager.swift
//  CashSAVO
//
//  Created by yyw on 2025/9/28.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

class AppIQKeyboardManager {
    static func enableIQKeyboardManager(enable: Bool) {
        DispatchQueue.main.async {
            
            if enable {
                let manager = IQKeyboardManager.shared
                
                // 启用基础功能
                manager.isEnabled = true
                // 是否 点击背景收起键盘
                manager.resignOnTouchOutside = true
                // 键盘距离文本字段的间距
                manager.keyboardDistance = 30.0
                
                do {
                    let manager = IQKeyboardToolbarManager.shared
                    manager.isEnabled = false
                    manager.toolbarConfiguration.manageBehavior = .bySubviews
                    manager.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
                }
            }
            else {
                let manager = IQKeyboardManager.shared
                
                // 启用基础功能
                manager.isEnabled = false
                // 是否 点击背景收起键盘
                manager.resignOnTouchOutside = false
                // 键盘距离文本字段的间距
                manager.keyboardDistance = 0
                
                do {
                    let manager = IQKeyboardToolbarManager.shared
                    manager.isEnabled = false
                    manager.toolbarConfiguration.manageBehavior = .bySubviews
                    manager.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
                }
            }
        }
    }
}
