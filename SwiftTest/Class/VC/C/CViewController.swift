//
//  CViewController.swift
//  SwiftTest
//
//  Created by yyw on 2024/12/31.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa
import CoreStore

class CViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    var idNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setTitle("新增", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 50))
        }
        
        button.tapPublisher
            .sink { [weak self] in
                guard let weakSelf = self else { return }
                let c1VC = C1ViewController()
                c1VC.currentUserId = "500"
                weakSelf.navigationController?.pushViewController(c1VC, animated: true)
            }
            .store(in: &cancellables)
    }
}

extension CViewController {
    func insertUserV3() {
        self.idNumber += 1
        var userModel: UserModel?
        CoreDataManager.shared.coreDataStack.perform { [weak self] transaction in
            guard let weakSelf = self else { return }
            
            let model = UserModel()
            model.createTime = Int64(Date().timeIntervalSince1970 * 1000)
            model.id = "\(weakSelf.idNumber)"
            model.name = "王小3"
            model.sex = 1
            model.car = "测试哈"
            model.color = "yellow"
            model.height = 178.01
            model.dog = DogModel(id: model.id, name: "狗狗V3", color: "green")
            let _ = try transaction.importUniqueObject(Into<EntityUserModelV3>(),
                                                       source: model)
            
            let model2 = UserModel()
            model2.createTime = Int64(Date().timeIntervalSince1970 * 1000)
            model2.id = "\(weakSelf.idNumber)"
            model2.name = "王小3测试"
            model2.sex = 0
            model.car = "测试哈111"
            model.color = "yellow"
            model.height = 178.01
            let user = try transaction.importUniqueObject(Into<EntityUserModelV3>(),
                                                          source: model2)
            user?.dog?.color = "blue"
            
            userModel = model2
        } completion: { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success():
                print("insert success")
                if let userModel {
                    print(userModel.id)
                    
                    if Int(userModel.id) ?? 0 < 1000 {
                        weakSelf.insertUserV3()
                    }
                }
                
            case .failure(let error):
                print("insert error: \(error.localizedDescription)")
            }
        }
    }
}
