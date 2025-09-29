//
//  UIEdgeInsets+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/29.
//

import UIKit

extension UIEdgeInsets {
    var vertical: CGFloat {
        return top + bottom
    }
    var horizontal: CGFloat {
        return left + right
    }
}
