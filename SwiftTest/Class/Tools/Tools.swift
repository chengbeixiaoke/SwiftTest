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
