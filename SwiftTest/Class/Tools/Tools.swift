//
//  Tools.swift
//  SwiftTest
//
//  Created by yyw on 2025/3/26.
//

import UIKit

public let WidthScreen: CGFloat = UIScreen.main.bounds.width
public let HeightScreen: CGFloat = UIScreen.main.bounds.height

func ChatIMExecuteOnMainThreadIfNeeded(task: @escaping () -> Void) {
    if Thread.isMainThread {
        task()
    } else {
        DispatchQueue.main.async {
            task()
        }
    }
}

func ChatIMExecuteOnMainThreadAndWait(task: @escaping () -> Void) {
    if Thread.isMainThread {
        task()
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            task()
            semaphore.signal()
        }
        semaphore.wait()
    }
}


// ratio (以430的屏宽为基准)
public let Ratio_Scale: CGFloat = WidthScreen / CGFloat(430)
public func UIScale(_ x: CGFloat) -> CGFloat {
    if UIDevice.current.model.contains("iPhone") {
        return x * Ratio_Scale
    } else {
        return x
    }
}
