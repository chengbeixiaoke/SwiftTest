//
//  BaseNavigationController.swift
//  SwiftTest
//
//  Created by yyw on 2025/3/26.
//

import UIKit

open class BaseNavigationController: UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 创建并配置 appearance
        let appearance = UINavigationBarAppearance()
        
        // 设置为不透明背景（可选）
        appearance.configureWithOpaqueBackground()

        // 2. 设置背景颜色
        appearance.backgroundColor = .white

        // 3. 设置标题颜色
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        // 4. 设置底部分割线（三种选择）
        // 选择1：显示分割线（默认灰色）
        // appearance.shadowColor = .lightGray

        // 选择2：自定义分割线颜色
        appearance.shadowColor = .lightGray.withAlphaComponent(0.6)

        // 选择3：完全隐藏分割线
        // appearance.shadowColor = .clear

        // 5. 应用 appearance 到不同状态
        // 标准状态
        navigationBar.standardAppearance = appearance
        // 大标题滚动时
        navigationBar.scrollEdgeAppearance = appearance
        // 紧凑状态（横屏等）
        navigationBar.compactAppearance = appearance

        // 6. 设置其他导航栏属性
        // 按钮颜色（如返回按钮）
        navigationBar.tintColor = .black
        // 是否启用大标题（根据需求）
        navigationBar.prefersLargeTitles = false

        // 7. 确保手势可用
        interactivePopGestureRecognizer?.isEnabled = true
        interactivePopGestureRecognizer?.delegate = self
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool)
    {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        super.pushViewController(viewController, animated: true)
    }
    
    public override func popToRootViewController(animated: Bool) -> [UIViewController]?
    {
        if children.count > 1 {
            self.topViewController?.hidesBottomBarWhenPushed = false
        }
        
        let array = super.popToRootViewController(animated: animated)
        return array
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}
