//
//  AppDelegate.swift
//  SwiftTest
//
//  Created by 王阳洋 on 2024/10/13.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        /// 初始化暗黑模式监听者
        AppThemeModeManager.shared.changeAppThemeMode(.followingSystem)
        AppThemeModeManager.initUserInterfaceStyleListener()
        window?.overrideUserInterfaceStyle = AppThemeModeManager.shared.userInterfaceStyle()
        
        window?.rootViewController = initializeTabBarController()
        window?.makeKeyAndVisible()
        
        let _ = CoreDataManager.shared
        
        return true
    }
    
    @objc func handleDarkModeChange() {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("app即将失活")
    }
    
    func initializeTabBarController() -> UITabBarController {
        let vc1 = BaseNavigationViewController.init(rootViewController: AViewController())
        vc1.tabBarItem.title = "首页"
        
        let vc2 = BaseNavigationViewController.init(rootViewController: BViewController())
        vc2.tabBarItem.title = "BVC"
        
        let vc3 = BaseNavigationViewController.init(rootViewController: CViewController())
        vc3.tabBarItem.title = "CVC"
        
        let vc4 = BaseNavigationViewController.init(rootViewController: DViewController())
        vc4.tabBarItem.title = "DVC"
        
        let vc5 = BaseNavigationViewController.init(rootViewController: EViewController())
        vc5.tabBarItem.title = "EVC"
        
        let tabbarVc = UITabBarController()
        tabbarVc.tabBar.backgroundColor = .white
        tabbarVc.viewControllers = [vc1, vc2, vc3, vc4, vc5]
        
        return tabbarVc
    }
}


