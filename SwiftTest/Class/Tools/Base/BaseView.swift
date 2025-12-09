//
//  BaseView.swift
//  SwiftTest
//
//  Created by yyw on 2025/7/17.
//

import UIKit

open class BaseView: UIView {
    deinit {
        SLog("[View] - deinit:\(self.className())")
    }
}
