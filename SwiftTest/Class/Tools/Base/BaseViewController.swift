//
//  BaseViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/7/17.
//

import UIKit
import YYKit

class BaseViewController: UIViewController {
    
    var viewBackgroundColor: UIColor {
        return .BG_FFFFFF_1
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                self.wyy_traitCollectionDidChange(previousTraitCollection)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[VC] viewWillAppear: \(className())")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[VC] viewDidAppear: \(className())")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[VC] viewWillDisappear: \(className())")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("[VC] viewDidDisappear: \(className())")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[VC] viewDidLoad: \(className())")
        
        view.backgroundColor = viewBackgroundColor
    }
    
    func wyy_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
    
    deinit {
        print("[VC] deinit: \(className())")
    }
}
