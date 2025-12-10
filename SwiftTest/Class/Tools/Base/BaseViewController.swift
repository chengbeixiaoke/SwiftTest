//
//  BaseViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/7/17.
//

import UIKit
import YYKit

open class BaseViewController: UIViewController {
    
    public var viewBackgroundColor: UIColor {
        return .C_White
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                self.wyy_traitCollectionDidChange(previousTraitCollection)
            }
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[VC] viewWillAppear: \(className())")
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[VC] viewDidAppear: \(className())")
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[VC] viewWillDisappear: \(className())")
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("[VC] viewDidDisappear: \(className())")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        print("[VC] viewDidLoad: \(className())")
        
        view.backgroundColor = viewBackgroundColor
        
        navigationItem.hidesBackButton = true
        if navigationController?.children.count ?? 0 <= 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem()
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "normal_back"),
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(backAction))
        }
    }
    
    public func wyy_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
    
    @objc public func backAction() {
        let _ =  navigationController?.popViewController(animated: true)
    }
    
    deinit {
        print("[VC] deinit: \(className())")
    }
}
