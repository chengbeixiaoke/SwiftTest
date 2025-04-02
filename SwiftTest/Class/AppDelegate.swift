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
    var wyyWindow: WYYWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = initializeTabBarController()
        window?.makeKeyAndVisible()
        
        let _ = CoreDataManager.shared
        
        addAppThemeModeMonitor()
        
        return true
    }
    
    @objc func handleDarkModeChange() {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("app即将失活")
    }
    
    func initializeTabBarController() -> UITabBarController {
        let vc1 = SwiftNavigationViewController.init(rootViewController: ViewController())
        vc1.tabBarItem.title = "首页"
        
        let vc2 = SwiftNavigationViewController.init(rootViewController: BViewController())
        vc2.tabBarItem.title = "BVC"
        
        
        let vc3 = SwiftNavigationViewController.init(rootViewController: CViewController())
        vc3.tabBarItem.title = "CVC"
        
        let vc4 = SwiftNavigationViewController.init(rootViewController: DViewController())
        vc4.tabBarItem.title = "DVC"
        
        let vc5 = SwiftNavigationViewController.init(rootViewController: EViewController())
        vc5.tabBarItem.title = "EVC"
        
        let tabbarVc = UITabBarController()
        tabbarVc.tabBar.backgroundColor = .brown
        tabbarVc.viewControllers = [vc1, vc2, vc3, vc4, vc5]
        
        return tabbarVc
    }
}


