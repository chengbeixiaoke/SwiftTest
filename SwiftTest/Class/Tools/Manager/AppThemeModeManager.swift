//
//  AppThemeModeManager.swift
//  SavoBaseModule
//
//  Created by yyw on 2025/1/8.
//

import UIKit

let keyCacheAppThemeMode = "keyCacheAppThemeMode"

public enum AppThemeMode: String {
    /// 跟随系统
    case followingSystem = "0"
    /// 深色
    case dark = "1"
    /// 浅色
    case light = "2"
}

public protocol SavoAppDelegateProtocol {
    func updateTraitCollection(_ type: UIUserInterfaceStyle)
}

public class AppThemeModeManager {
    // MARK: - 单例
    public static let shared: AppThemeModeManager = AppThemeModeManager()
    
    //
    public var appDelegate: SavoAppDelegateProtocol? = nil
    
    fileprivate var window: UIWindow?
    private init() {}
    
    private var _currentMode: AppThemeMode = AppThemeModeManager.getCurrentModeByCache()
    public private(set) var currentMode: AppThemeMode {
        get {
            return _currentMode
        }
        set {
            _currentMode = newValue
        }
    }
    
    public func changeAppThemeMode(_ mode: AppThemeMode) {
        if self.currentMode == mode {
            return
        }
        self.currentMode = mode
        
        let defualt = UserDefaults.standard
        defualt.set(mode.rawValue, forKey: keyCacheAppThemeMode)
        
        self.changeKeyWindowUserInterfaceStyle(self.userInterfaceStyle())
    }
    
    fileprivate func getSystemThemeMode() -> AppThemeMode {
        var style: AppThemeMode = .light
        
        ExecuteOnMainThreadAndWait {
            if let window = self.window {
                if window.traitCollection.userInterfaceStyle == .dark {
                    style = .dark
                } else {
                    style = .light
                }
            }
            else {
                if UITraitCollection.current.userInterfaceStyle == UIUserInterfaceStyle.dark {
                    style = .dark
                }
                else {
                    style = .light
                }
            }
        }
        return style
    }
    
    public func userInterfaceStyle() -> UIUserInterfaceStyle {
        switch self.currentMode {
        case .followingSystem:
            return .unspecified
            
        case .dark:
            return .dark
            
        case .light:
            return .light
        }
    }
    
    fileprivate func changeKeyWindowUserInterfaceStyle(_ type: UIUserInterfaceStyle) {
        if let appDelegate = appDelegate {
            appDelegate.updateTraitCollection(type)
            let modeDescription: String
            switch type {
            case .light:
                modeDescription = "浅色模式"
            case .dark:
                modeDescription = "深色模式"
            default:
                modeDescription = "跟随系统"
            }
            printLog("[Theme] 主题颜色切换为: \(modeDescription)")
        }
    }
}

public extension AppThemeModeManager {
    static func getCurrentModeByCache() -> AppThemeMode {
        let defualt = UserDefaults.standard
        if let cache = defualt.value(forKey: keyCacheAppThemeMode) as? String {
            return AppThemeMode.init(rawValue: cache) ?? .followingSystem
        }
        return .followingSystem
    }
    
    static func isDark() -> Bool {
        switch AppThemeModeManager.shared.currentMode {
        case .dark:
            return true
        case .light:
            return false
        case .followingSystem:
            return AppThemeModeManager.shared.getSystemThemeMode() == .dark
        }
    }
    
    static func initUserInterfaceStyleListener(windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        window.frame = CGRectMake(0, 0, 1, 1)
        window.windowLevel = .normal - 1
        window.backgroundColor = .clear
        window.rootViewController = UIUserInterfaceStyleVC()
        window.isHidden = false
        
        AppThemeModeManager.shared.window = window
    }
}

/// 用于监听系统深色模式改变
class UIUserInterfaceStyleVC: BaseViewController {
    open override func colorAppearanceDidChange(from previousTraitCollection: UITraitCollection?) {
        super.colorAppearanceDidChange(from: previousTraitCollection)
        if let previousTraitCollection = previousTraitCollection {
            if AppThemeModeManager.shared.currentMode == .followingSystem && (UIApplication.shared.applicationState == .active || UIApplication.shared.applicationState == .inactive) && traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                AppThemeModeManager.shared.changeKeyWindowUserInterfaceStyle(.unspecified)
            }
        }
    }
}
