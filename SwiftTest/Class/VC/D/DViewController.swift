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

class DViewController: BaseViewController {
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "DVC"
        view.backgroundColor = .white
        
        CoreDataManager.shared.initializeCoreData
            .sink { success in
                if success {
                    print("DViewController - 数据库初始化完成")
                }
            }
            .store(in: &cancellables)
    }
}

