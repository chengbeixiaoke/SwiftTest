//
//  AppDelegate.swift
//  SwiftTest
//
//  Created by 王阳洋 on 2024/10/13.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        clearLaunchScreenCache()
        return true
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


