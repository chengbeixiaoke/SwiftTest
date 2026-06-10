//
//  SceneDelegate+Other.swift
//  SwiftTest
//
//  Created by yyw on 2025/3/4.
//

import UIKit

extension SceneDelegate: SavoAppDelegateProtocol {
    func updateTraitCollection(_ type: UIUserInterfaceStyle) {
        self.window?.overrideUserInterfaceStyle = type
    }
}
