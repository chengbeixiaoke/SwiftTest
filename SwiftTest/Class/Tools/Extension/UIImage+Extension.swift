//
//  UIImage+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2025/3/26.
//

import UIKit

extension UIImage {
    
    // 改变图片的颜色
    class func withColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
