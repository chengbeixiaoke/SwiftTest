//
//  Object+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2025/4/3.
//

import UIKit

extension URL {
    var filePath: String {
        get {
            if #available(iOS 16.0, *) {
                return path()
            } else {
                return path
            }
        }
    }
    
    static func FileURL(_ filePath: String) -> URL {
        if #available(iOS 16.0, *) {
            return URL.init(filePath: filePath)
        } else {
            return URL.init(fileURLWithPath: filePath)
        }
    }
    
    static func outputURL(_ name: String,
                          clearOld: Bool = false,
                          createEmptyFile: Bool = false) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let outputFolder = documentsDirectory.appendingPathComponent("Output")
        let outputURL = outputFolder.appendingPathComponent(name)
        
        do {
            if !FileManager.default.fileExists(atPath: outputFolder.filePath) {
                try FileManager.default.createDirectory(at: outputFolder,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }

            if clearOld && FileManager.default.fileExists(atPath: outputURL.filePath) {
                try FileManager.default.removeItem(atPath: outputURL.filePath)
            }
            
            if createEmptyFile {
                /// 预先创建空文件，以便后续文件写入
                try "".write(to: outputURL, atomically: true, encoding: .utf8)
            }
        }
        catch {
            print("[Error] 创建outputURL失败：\(error.localizedDescription)")
        }
        return outputURL
    }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - UIApplication
extension UIApplication {
    
    //但是有一点要注意，如果上一个页面是dismiss，直接调用有可能还是被dismiss页，所以需要在dismiss中的completion中调用
    class func topViewController(
        base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    ) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController,
                  let selected = tab.selectedViewController {
            return topViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    var currentKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return self.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
        } else {
            return self.keyWindow
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    static var current: UIViewController? {
        var current = UIApplication.shared.delegate?.window??.rootViewController
        while (current?.presentedViewController != nil) {
            current = current?.presentedViewController
        }
        if let tabbar = current as? UITabBarController , tabbar.selectedViewController != nil {
            current = tabbar.selectedViewController
        }
        while let navi = current as? UINavigationController , navi.topViewController != nil {
            current = navi.topViewController
        }
        return current
    }
    
    class func nkReplaceSystemPresent() {
        let systemSelector = #selector(UIViewController.present(_:animated:completion:))
        let nkSelector = #selector(UIViewController.newPesent(_:animated:completion:))
        let systemMethod = class_getInstanceMethod(self, systemSelector)
        let nkNewMethod = class_getInstanceMethod(self, nkSelector)
        method_exchangeImplementations(systemMethod!, nkNewMethod!)
    }
    
    @objc func newPesent(_ vcToPresent: UIViewController, animated flag: Bool, completion: (() ->Void)? = nil) {
        if vcToPresent.isKind(of: UIAlertController.self) {
            let alertController = vcToPresent as? UIAlertController
            if alertController?.title == nil && alertController?.message == nil {
                return
            }
        }
        self.newPesent(vcToPresent, animated: flag, completion: completion)
    }    
}

