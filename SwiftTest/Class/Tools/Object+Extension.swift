//
//  Object+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2025/4/3.
//

import UIKit

extension URL {
    static func FileURL(_ filePath: String) -> URL {
        if #available(iOS 16.0, *) {
            return URL.init(filePath: filePath)
        } else {
            return URL.init(fileURLWithPath: filePath)
        }
    }
}
