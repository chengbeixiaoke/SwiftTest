//
//  PublicMacro.swift
//  SPortal
//
//  Created by yyw on 2025/8/19.
//

import UIKit

public let WidthScreen: CGFloat = UIScreen.main.bounds.width
public let HeightScreen: CGFloat = UIScreen.main.bounds.height

public let TabBarHeight: CGFloat = 83.0

public let HeightOfLine: CGFloat = 1.0

public let HeightOfBorderLine: CGFloat = 1.0

public let VCTopMargin: CGFloat = 59.0

public let VCNavighationHeight: CGFloat = 116.0

public let LanguagePlaceholder = "${title}"


//获取状态栏高度
public func getStatusBarHeight() -> CGFloat {
    var statusBarHeight: CGFloat = 0
    let scene = UIApplication.shared.connectedScenes.first
    guard let windowScene = scene as? UIWindowScene else { return 0 }
    guard let statusBarManager = windowScene.statusBarManager else { return 0 }
    statusBarHeight = statusBarManager.statusBarFrame.height
    return statusBarHeight
}

// 顶部安全区高度
public func getSafeDistanceTop() -> CGFloat {
    let scene = UIApplication.shared.connectedScenes.first
    guard let windowScene = scene as? UIWindowScene else { return 0 }
    guard let window = windowScene.windows.first else { return 0 }
    return window.safeAreaInsets.top
}

// 底部安全区高度 34
public func getSafeDistanceBottom() -> CGFloat {
    let scene = UIApplication.shared.connectedScenes.first
    guard let windowScene = scene as? UIWindowScene else { return 0 }
    guard let window = windowScene.windows.first else { return 0 }
    return window.safeAreaInsets.bottom
}

// ratio (以440的屏宽为基准)
public let Ratio_Scale: CGFloat = WidthScreen / CGFloat(440)
public func UIScale(_ x: CGFloat) -> CGFloat {
    if UIDevice.current.model.contains("iPhone") {
        return x * Ratio_Scale
    } else {
        return x
    }
}
