//
//  WYYUIViewViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/7/17.
//

import UIKit

class WYYUIViewViewController: UIViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func wyy_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
}
