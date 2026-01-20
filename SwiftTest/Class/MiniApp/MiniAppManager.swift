//
//  MiniAppManager.swift
//  CashSAVO
//
//  Created by yyw on 2025/4/29.
//

import UIKit
import SnapKit

class MiniAppManager {
    private init () { }
    static let shared: MiniAppManager = {
        let queue = DispatchQueue(label: "com.chat.miniapp.singleton")
        var instance: MiniAppManager?
        queue.sync {
            if instance == nil {
                instance = MiniAppManager()
            }
        }
        return instance!
    }()
    
    weak var tabbarVC: AppTabBarController26CacheMiniAppDelgate?
    var cacheMiniAppVCCount: Int = 0
    var cacheMiniAppVC: [MiniAppH5ContainerViewController] = []
    
    lazy var smallMiniAppContentView = {
        let view = UIView(frame: CGRectMake(0, HeightScreen - 80, WidthScreen, 80))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var currentSmallMiniApp: MiniAppH5ContainerSmallView?
        
    // 跳转H5小程序
    func openMiniApp(_ url: String)
    {
        guard let currentVc = UIApplication.topViewController() else { return }
        let vc = MiniAppH5ContainerViewController(url: url)
        vc.transitioningDelegate = vc.savoTransitionDelegate
        vc.modalPresentationStyle = .custom
        vc.savoTransitionDelegate.interactiveTransition.wireToViewController(vc)
        currentVc.present(vc, animated: true)
    }
    
    // 收起小程序
    func downMiniApp(_ vc: MiniAppH5ContainerViewController) {
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
        guard let rootViewController = window.rootViewController else { return }

        if !cacheMiniAppVC.contains(vc) {
            cacheMiniAppVC.append(vc)
        }
        
        if smallMiniAppContentView.superview == nil {
            window.addSubview(smallMiniAppContentView)
            smallMiniAppContentView.frame = CGRectMake(0, HeightScreen - 80, WidthScreen, 80)
        }
        
        let _lastSmallMiniApp = currentSmallMiniApp
        _lastSmallMiniApp?.isUserInteractionEnabled = false
        
        let _currentSmallMiniAppFrame =  CGRectMake(UIScale(20), UIScale(10), WidthScreen - UIScale(40), UIScale(50))
        let _currentSmallMiniApp = MiniAppH5ContainerSmallView(frame: _currentSmallMiniAppFrame)
        smallMiniAppContentView.addSubview(_currentSmallMiniApp)
        _currentSmallMiniApp.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        _currentSmallMiniApp.clickViewBlock = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.clickCurrentSmallMiniApp()
        }
        
        let animationView = vc.view.snapshotView(afterScreenUpdates: true) ?? UIImageView(image: vc.view.snapshotImage())
        window.addSubview(animationView)
        animationView.frame = vc.view.frame
        animationView.layer.cornerRadius = 1
        animationView.clipsToBounds = true
        vc.view.isHidden = true
        
        let frame = smallMiniAppContentView.convert(_currentSmallMiniApp.frame, to: window)
        
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.6) {
                animationView.frame = CGRectMake(frame.midX, frame.midY, 1, 1)
                animationView.layer.cornerRadius = 25
                
                rootViewController.view.frame = CGRect(x: 0, y: 0, width: WidthScreen, height: HeightScreen - 80)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                if let _lastSmallMiniApp = _lastSmallMiniApp {
                    _lastSmallMiniApp.transform = CGAffineTransform(scaleX: 0.98, y: 1.0)
                    _lastSmallMiniApp.frame = _lastSmallMiniApp.frame.offsetBy(dx: 0, dy: -6)
                }
                _currentSmallMiniApp.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        } completion: { _ in
            animationView.isHidden = true
            animationView.removeFromSuperview()
            vc.dismiss(animated: false)
            self.currentSmallMiniApp = _currentSmallMiniApp
            
            self.smallMiniAppContentView.subviews.forEach { view in
                if view != _currentSmallMiniApp && view != _lastSmallMiniApp {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    func restoration() {
        smallMiniAppContentView.removeFromSuperview()
        smallMiniAppContentView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        currentSmallMiniApp = nil
        cacheMiniAppVC.removeAll()
        
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
        guard let rootViewController = window.rootViewController else { return }
        UIView.animate(withDuration: 0.25) {
            rootViewController.view.frame = CGRect(x: 0, y: 0, width: WidthScreen, height: HeightScreen)
        }
    }
    
    func clickCurrentSmallMiniApp() {
        if cacheMiniAppVC.count == 1 {
            showMiniAppFromSmalMiniApp()
            restoration()
        }
        else {
            let view = MiniAppTestView(frame: CGRectMake(0, 0, WidthScreen, HeightScreen), count: 10)
            view.show()
        }
    }
    
    func showMiniAppFromSmalMiniApp() {
        guard let vc = cacheMiniAppVC.first else { return }
        guard let currentVc = UIApplication.topViewController() else { return }
        vc.view.isHidden = false
        currentVc.present(vc, animated: true)
    }
}
