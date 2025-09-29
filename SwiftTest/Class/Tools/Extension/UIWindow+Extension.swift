//
//  UIWindow+Extension.swift
//  SPortal
//
//  Created by yyw on 2025/8/19.
//

import UIKit

extension UIWindow {
    static func keyWindow() -> UIWindow?
    {
        return windows()?.first(where: { $0.isKeyWindow })
    }
    
    static func windows() -> [UIWindow]?
    {
        if #available(iOS 15.0, *) {
            let windows = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })?
                .windows
            if let windows = windows {
                return windows
            }
            else {
                return UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows
            }
        }
        else {
            return UIApplication.shared.windows
        }
    }
}
