//
//  ChatIMGroupRTCAPIss.swift
//  SwiftTest
//
//  Created by yyw on 2025/3/4.
//

import UIKit

extension AppDelegate {
    func addAppThemeModeMonitor() {
        wyyWindow = WYYWindow(frame: CGRectMake(0, 0, 10, 10))
        wyyWindow?.windowLevel = .normal
        wyyWindow?.rootViewController = AppThemeModeMonitorViewController()
        wyyWindow?.makeKeyAndVisible()
    }
    
    func updateTraitCollection(_ type: UIUserInterfaceStyle) {
        self.window?.overrideUserInterfaceStyle = type
    }
}


class WYYWindow: UIWindow {
    
}
class AppThemeModeMonitorViewController: UIViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let previousTraitCollection = previousTraitCollection {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.updateTraitCollection(previousTraitCollection.userInterfaceStyle)
            }
        }
    }
}
