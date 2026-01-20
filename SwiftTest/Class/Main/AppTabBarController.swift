//
//  AppTabBarController.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/30.
//

import UIKit

protocol AppTabBarController26CacheMiniAppDelgate: NSObjectProtocol {
    var mainView: UIView { get }
    func changeRootVCFrame(isPush: Bool)
}

@available(iOS 26.0, *)
class AppTabBarController26: UITabBarController {
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
        
        let appearance = tabBar.standardAppearance
        // 调整堆叠布局（stacked）的间距
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(
            horizontal: 6,  // 水平偏移
            vertical: -6    // 垂直偏移：负值减少间距，正值增加间距
        )
        
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(
            horizontal: 6,
            vertical: 16
        )
        tabBar.standardAppearance = appearance
        
        MiniAppManager.shared.tabbarVC = self
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

@available(iOS 26.0, *)
extension AppTabBarController26: AppTabBarController26CacheMiniAppDelgate {
    var mainView: UIView {
        return view
    }
    
    func changeRootVCFrame(isPush: Bool) {
        if let window = UIApplication.shared.currentKeyWindow {
            if MiniAppManager.shared.cacheMiniAppVCCount == 0 || isPush {
                UIView.animate(withDuration: 0.25) {
                    MiniAppManager.shared.tabbarVC?.mainView.frame = CGRectMake(0, 0, WidthScreen, HeightScreen)
                    window.rootViewController?.view.frame = CGRectMake(0, 0, WidthScreen, HeightScreen)
                    window.rootViewController?.view.cornerConfiguration = .corners(topLeftRadius: 0, topRightRadius: 0, bottomLeftRadius: 0, bottomRightRadius: 0)
                }
            } else if MiniAppManager.shared.cacheMiniAppVCCount == 1 {
                UIView.animate(withDuration: 0.25) {
                    MiniAppManager.shared.tabbarVC?.mainView.frame = CGRectMake(0, 0, WidthScreen, HeightScreen-62)
                    window.rootViewController?.view.frame = CGRectMake(0, 0, WidthScreen, HeightScreen-62)
                    window.rootViewController?.view.cornerConfiguration = .corners(topLeftRadius: 0, topRightRadius: 0, bottomLeftRadius: 40, bottomRightRadius: 40)
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    MiniAppManager.shared.tabbarVC?.mainView.frame = CGRectMake(0, 0, WidthScreen, HeightScreen-72)
                    window.rootViewController?.view.frame = CGRectMake(0, 0, WidthScreen, HeightScreen-72)
                    window.rootViewController?.view.cornerConfiguration = .corners(topLeftRadius: 0, topRightRadius: 0, bottomLeftRadius: 40, bottomRightRadius: 40)
                }
            }
        }
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

