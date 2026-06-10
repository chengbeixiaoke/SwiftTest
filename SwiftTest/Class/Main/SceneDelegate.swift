//
//  SceneDelegate.swift
//  TTTTT
//
//  Created by yyw on 2025/9/30.
//

import UIKit
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        clearLaunchScreenCache()
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        /// 初始化暗黑模式监听者
        AppThemeModeManager.initUserInterfaceStyleListener(windowScene: windowScene)
        AppThemeModeManager.shared.appDelegate = self
        window?.overrideUserInterfaceStyle = AppThemeModeManager.shared.userInterfaceStyle()

        if #available(iOS 26.0, *) {
            window?.rootViewController = AppTabBarController26()
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
    
    func clearLaunchScreenCache() {
        let fileManager = FileManager.default
        let libraryPath = NSHomeDirectory() + "/Library"
        let splashBoardPath = libraryPath + "/SplashBoard"
        
        do {
            // 检查缓存目录是否存在
            if fileManager.fileExists(atPath: splashBoardPath) {
                try fileManager.removeItem(atPath: splashBoardPath)
                print("LaunchScreen 缓存清除成功。")
            }
        } catch {
            print("清除缓存失败: \(error)")
        }
    }
}
