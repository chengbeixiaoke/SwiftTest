//
//  SceneDelegate.swift
//  TTTTT
//
//  Created by yyw on 2025/9/30.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        /// 初始化暗黑模式监听者
        AppThemeModeManager.shared.changeAppThemeMode(.followingSystem)
        AppThemeModeManager.initUserInterfaceStyleListener()
        window?.overrideUserInterfaceStyle = AppThemeModeManager.shared.userInterfaceStyle()
        
        if #available(iOS 26.0, *) {
            window?.rootViewController = AppTabBarController2()
        } else {
            window?.rootViewController = AppTabBarController()
        }
        window?.makeKeyAndVisible()
        
        let _ = CoreDataManager.shared
    }

    func sceneDidDisconnect(_ scene: UIScene)
    {
        printLog("[App] - app即将失活")
    }

    func sceneDidBecomeActive(_ scene: UIScene)
    {
        printLog("[App] - app已经进入活跃状态")
    }

    func sceneWillResignActive(_ scene: UIScene)
    {
        printLog("[App] - app即将进入非活跃状态")
    }

    func sceneWillEnterForeground(_ scene: UIScene)
    {
        printLog("[App] - app即将进入活跃状态")
    }

    func sceneDidEnterBackground(_ scene: UIScene)
    {
        printLog("[App] - app已经进入后台")
    }
}

