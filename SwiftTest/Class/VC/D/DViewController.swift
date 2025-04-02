//
//  DViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/1/3.
//

import UIKit
import CoreStore
import SnapKit
import Combine

class DViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        CoreDataManager.shared.initializeCoreData
            .sink { [weak self] success in
                guard let weakSelf = self else { return }
                if success {
                    print("DViewController - 数据库初始化完成")
                }
            }
            .store(in: &cancellables)
    }
}

