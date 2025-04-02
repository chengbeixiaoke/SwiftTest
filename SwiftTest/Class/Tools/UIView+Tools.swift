//
//  UIView+Tools.swift
//  SwiftTest
//
//  Created by yyw on 2025/1/21.
//

import UIKit

extension UIView {
    func corner(byRoundingCorners corners: CACornerMask, radii: CGFloat) {
        self.layer.cornerRadius = radii
        self.layer.cornerCurve = .continuous
        self.layer.maskedCorners = corners
        self.clipsToBounds = true
    }
}
