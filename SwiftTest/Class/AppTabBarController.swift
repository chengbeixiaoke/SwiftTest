//
//  AppTabBarController.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/30.
//

import UIKit
import RDVTabBarController

@available(iOS 26.0, *)
class AppTabBarController18: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabs.append(configTab(AViewController(),
                              title: "首页",
                              imageName: "tabbar_home",
                              identifier: "chats",
                              badgeValue: "3"))
        
        tabs.append(configTab(BViewController(),
                              title: "BVC",
                              imageName: "tabbar_im",
                              identifier: "contacts"))
        
        tabs.append(configTab(CViewController(),
                              title: "CVC",
                              imageName: "tabbar_im_setting",
                              identifier: "discover"))
        
        tabs.append(configTab(DViewController(),
                              title: "DVC",
                              imageName: "tabbar_employee",
                              identifier: "me"))
        
        tabs.append(configTab(EViewController(),
                              title: "EVC",
                              imageName: "tabbar_setting",
                              identifier: "me"))
        selectedTab = tabs.first
        
        // iOS26新增，向下滚动时，只显示第一个与UISearchTab的图标，中间显示辅助UITabAccessory
//        tabBarMinimizeBehavior = .onScrollDown
        // iOS26新增
//        bottomAccessory = UITabAccessory(contentView: UIToolbar())
    }
    
    // MARK: 设置UITab
    func configTab(_ viewController: UIViewController,
                   title: String,
                   imageName: String,
                   identifier: String,
                   badgeValue: String? = nil) -> UITab
    {
        let tab = UITab(title: title, image: UIImage(named: imageName), identifier: identifier) { tab in
            tab.badgeValue = badgeValue
            tab.userInfo = identifier
            return self.configViewController(viewController: viewController, title: title)
        }
        return tab
    }
    
    // MARK: 设置UISearchTab
    func configSearchTab(_ viewController: UIViewController, title: String) -> UISearchTab
    {
        // UISearchTab，从TabBar分离出来单独显示
        let searchTab = UISearchTab { tab in
            viewController.view.backgroundColor = .init(red: .random(in: 0 ... 1), green: .random(in: 0 ... 1), blue: .random(in: 0 ... 1), alpha: 1.0)
            return self.configViewController(viewController: viewController, title: title)
        }
        return searchTab
    }
    
    // MARK: 设置UIViewController
    func configViewController(viewController: UIViewController, title: String) -> BaseNavigationController
    {
        let navigationController = BaseNavigationController(rootViewController: viewController)
        viewController.navigationItem.title = title
        return navigationController
    }
}


class AppTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTabBarController()
    }
    
    func initializeTabBarController() {
        let vc1 = BaseNavigationController.init(rootViewController: AViewController())
        vc1.tabBarItem.title = "首页"
        vc1.tabBarItem.image = UIImage(named: "tabbar_home")
        vc1.tabBarItem.selectedImage = UIImage(named: "tabbar_home_1")
        
        let vc2 = BaseNavigationController.init(rootViewController: BViewController())
        vc2.tabBarItem.title = "BVC"
        vc2.tabBarItem.image = UIImage(named: "tabbar_im")
        vc2.tabBarItem.selectedImage = UIImage(named: "tabbar_im_1")
        
        let vc3 = BaseNavigationController.init(rootViewController: CViewController())
        vc3.tabBarItem.title = "CVC"
        vc3.tabBarItem.image = UIImage(named: "tabbar_im_setting")
        vc3.tabBarItem.selectedImage = UIImage(named: "tabbar_im_setting_1")
        
        let vc4 = BaseNavigationController.init(rootViewController: DViewController())
        vc4.tabBarItem.title = "DVC"
        vc4.tabBarItem.image = UIImage(named: "tabbar_employee")
        vc4.tabBarItem.selectedImage = UIImage(named: "tabbar_employee_1")
        vc4.tabBarItem.badgeValue = ""
        
        let vc5 = BaseNavigationController.init(rootViewController: EViewController())
        vc5.tabBarItem.title = "EVC"
        vc5.tabBarItem.image = UIImage(named: "tabbar_setting")
        vc5.tabBarItem.selectedImage = UIImage(named: "tabbar_setting_1")
        vc5.tabBarItem.badgeValue = "10"
        
        tabBar.backgroundColor = .white
        viewControllers = [vc1, vc2, vc3, vc4, vc5]
    }
}

class AppTabBarController2: RDVTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTabBarController()
    }
    
    func initializeTabBarController() {
        let vc1 = BaseNavigationController.init(rootViewController: AViewController())
        let vc2 = BaseNavigationController.init(rootViewController: BViewController())
        let vc3 = BaseNavigationController.init(rootViewController: CViewController())
        let vc4 = BaseNavigationController.init(rootViewController: DViewController())
        let vc5 = BaseNavigationController.init(rootViewController: EViewController())

        tabBar.backgroundColor = .white
        viewControllers = [vc1, vc2, vc3, vc4, vc5]
        
        for (index, item) in tabBar.items.enumerated() {
            guard let barItem = item as? RDVTabBarItem else { continue }
            
            if index == 0 {
                barItem.title = "首页"
                barItem.setFinishedSelectedImage(UIImage(named: "tabbar_home_1"),
                                                 withFinishedUnselectedImage: UIImage(named: "tabbar_home"))
            }
            
            if index == 1 {
                barItem.title = "BVC"
                barItem.setFinishedSelectedImage(UIImage(named: "tabbar_im_1"),
                                                 withFinishedUnselectedImage: UIImage(named: "tabbar_im"))
            }
            
            if index == 2 {
                barItem.title = "CVC"
                barItem.setFinishedSelectedImage(UIImage(named: "tabbar_im_setting_1"),
                                                 withFinishedUnselectedImage: UIImage(named: "tabbar_im_setting"))
            }
            
            if index == 3 {
                barItem.title = "DVC"
                barItem.setFinishedSelectedImage(UIImage(named: "tabbar_home_1"),
                                                 withFinishedUnselectedImage: UIImage(named: "tabbar_home"))
            }
            
            if index == 4 {
                barItem.title = "EVC"
                barItem.setFinishedSelectedImage(UIImage(named: "tabbar_setting_1"),
                                                 withFinishedUnselectedImage: UIImage(named: "tabbar_setting"))
            }
        }
    }
}

