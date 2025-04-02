//
//  SwiftNavigationViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/3/26.
//

import UIKit

class SwiftNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationBar.setBackgroundImage(UIImage.withColor(UIColor.clear), for: UIBarMetrics.default)
        navigationBar.backgroundColor = .clear
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.back(self, action: #selector(back))
        }
        
        if children.count > 0 {
            if children.count == 1 {
                viewController.hidesBottomBarWhenPushed = true
            }
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        super.pushViewController(viewController, animated: true)
    }
    
    @objc func back() {
       let _ =  popViewController(animated: true)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if children.count > 1 {
            self.topViewController?.hidesBottomBarWhenPushed = false
        }
        let array = super.popToRootViewController(animated: animated)
        return array
    }
}


extension UIBarButtonItem {
    
    static func back(_ target: Any, action: Selector) -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.addTarget(target, action: action, for: .touchUpInside)
        button.setImage(UIImage(named: "back"), for: .normal)
        return UIBarButtonItem(customView: button)
    }
    
    convenience init(_ title: String, target: Any? , selecteAnction: Selector?) {
        let btn = UIButton(frame: .zero)
        // 设置字体大小
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        if selecteAnction != nil {
            btn.addTarget(target, action: selecteAnction!, for: .touchUpInside)
        }
        btn.sizeToFit()
        self.init(customView: btn)
    }

}
