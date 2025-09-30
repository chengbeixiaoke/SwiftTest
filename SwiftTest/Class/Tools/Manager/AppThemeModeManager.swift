//
//  AppThemeModeManager.swift
//  CashSAVO
//
//  Created by yyw on 2025/1/8.
//

import UIKit

let keyCacheAppThemeMode = "keyCacheAppThemeMode"

enum AppThemeMode: String {
    /// 跟随系统
    case followingSystem = "0"
    /// 深色
    case dark = "1"
    /// 浅色
    case light = "2"
}

class AppThemeModeManager {
    // MARK: - 单例
    public static let shared: AppThemeModeManager = AppThemeModeManager()
    
    fileprivate var window: UIWindow?
    private init() {}
    
    private var _currentMode: AppThemeMode = AppThemeModeManager.getCurrentModeByCache()
    private(set) var currentMode: AppThemeMode {
        get {
            return _currentMode
        }
        set {
            _currentMode = newValue
        }
    }
    
    func changeAppThemeMode(_ mode: AppThemeMode) {
        if self.currentMode == mode {
            return
        }
        self.currentMode = mode
        
        let defualt = UserDefaults.standard
        defualt.set(mode.rawValue, forKey: keyCacheAppThemeMode)
        
        self.changeKeyWindowUserInterfaceStyle(self.userInterfaceStyle())
    }
    
    private func getSystemThemeMode() -> AppThemeMode {
        var style: AppThemeMode = .light
        
        
        OnMainThreadIfNeeded {
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
    
    func userInterfaceStyle() -> UIUserInterfaceStyle {
        switch self.currentMode {
        case .followingSystem:
            if self.getSystemThemeMode() == .dark {
                return .dark
            }
            else {
                return .light
            }
            
        case .dark:
            return .dark
            
        case .light:
            return .light
        }
    }
    
    fileprivate func changeKeyWindowUserInterfaceStyle(_ type: UIUserInterfaceStyle) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.delegate as? SceneDelegate {
                sceneDelegate.updateTraitCollection(type)
            print("SAVO - [Style] 主题颜色切换为: \(type == .light ? "浅色模式" : "深色模式")")
        }
    }
}

extension AppThemeModeManager {
    private static func getCurrentModeByCache() -> AppThemeMode {
        let defualt = UserDefaults.standard
        if let cache = defualt.value(forKey: keyCacheAppThemeMode) as? String {
            return AppThemeMode.init(rawValue: cache) ?? .followingSystem
        }
        return .followingSystem
    }
    
    static func isDark() -> Bool {
        return AppThemeModeManager.shared.userInterfaceStyle() == .dark
    }
    
    static func initUserInterfaceStyleListener() {
        let window = UIWindow(frame: CGRectMake(0, 0, 10, 10))
        window.rootViewController = UIUserInterfaceStyleVC()
        window.makeKeyAndVisible()
        
        AppThemeModeManager.shared.window = window
    }
}

/// 用于监听系统深色模式改变
class UIUserInterfaceStyleVC: UIViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let previousTraitCollection = previousTraitCollection {
                if AppThemeModeManager.shared.currentMode == .followingSystem && (UIApplication.shared.applicationState == .active || UIApplication.shared.applicationState == .inactive) && UITraitCollection.current.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                    AppThemeModeManager.shared.changeKeyWindowUserInterfaceStyle(UITraitCollection.current.userInterfaceStyle)
                }
            }
        }
    }
}
