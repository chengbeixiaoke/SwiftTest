//
//  BViewController.swift
//  SwiftTest
//
//  Created by 王阳洋 on 2024/10/13.
//

import UIKit
import Combine
import SnapKit

class BViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var listArray: [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    let tableView: UITableView =  {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
        
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionHeaderHeight = CGFLOAT_MIN
        tableView.sectionFooterHeight = CGFLOAT_MIN
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.contentInsetAdjustmentBehavior = .always
        
        tableView.register(BCell.self,
                           forCellReuseIdentifier: "BCell")
        
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "UITableViewCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for i in 0..<10 {
            self.listArray.append("\(i)")
        }
        self.tableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.beginUpdates()
        let fromIndexPath = IndexPath(row: 7, section: 0)
        let toIndexPath = IndexPath(row: 3, section: 0)
        
        let xxx = "100_\(listArray[fromIndexPath.row])"
        self.listArray.remove(at: fromIndexPath.row)
        self.listArray.insert(xxx, at: toIndexPath.row)
        self.tableView.moveRow(at: fromIndexPath, to: toIndexPath)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [toIndexPath], with: .none)
        }
        self.tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("")
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        print("")
        return true
    }
    
    deinit {
        print("BViewController")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BCell = tableView.dequeueReusableCell(withIdentifier: "BCell", for: indexPath) as! BCell
        cell.backgroundColor = .white
        cell.nameLabel.text = self.listArray[indexPath.row]
        cell.longPress = {[weak self] view in
            guard let weakSelf = self else { return }
            guard let cell = weakSelf.tableView.cellForRow(at: indexPath) else { return }
            let originFrame = cell.convert(cell.contentView.frame, to: weakSelf.view)
            print(originFrame)
        }
        
        cell.callingButton.tapPublisher
            .sink { [weak self] in
                guard let weakSelf = self else { return }
                
            }
            .store(in: &cancellables)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        
        let deleteAction = UIContextualAction(style:.normal, title: "删除") { [weak self] (action, view, completion) in
            guard let weakSelf = self else { return }
            weakSelf.tableView.setEditing(false, animated: true)
            weakSelf.tableView.reloadRows(at: [indexPath], with: .none)
        }
        deleteAction.backgroundColor = .red
        actions.append(deleteAction)
        
        let silenceAction = UIContextualAction(style:.normal, title: "静音") { [weak self] (action, view, completion) in
            guard let weakSelf = self else { return }
            weakSelf.tableView.setEditing(false, animated: true)
            weakSelf.tableView.reloadRows(at: [indexPath], with: .none)
        }
        silenceAction.backgroundColor = .blue
        actions.append(silenceAction)
        
        let topAction = UIContextualAction(style:.normal, title: "置顶") { [weak self] (action, view, completion) in
            guard let weakSelf = self else { return }
            weakSelf.tableView.setEditing(false, animated: true)
            weakSelf.tableView.reloadRows(at: [indexPath], with: .none)
        }
        topAction.backgroundColor = .green
        actions.append(topAction)
                
        print("置顶")
        
        // 创建UISwipeActionsConfiguration对象并设置其属性
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: actions)
        swipeActionsConfiguration.performsFirstActionWithFullSwipe = false
        return swipeActionsConfiguration
    }
    
    
    
    @objc func longPressAction(_ longPress: UILongPressGestureRecognizer) {
        let point = longPress.location(in: self.tableView)
        switch longPress.state {
        case .began:
            if let indexPath = self.tableView.indexPathForRow(at: point) {
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.setSelected(true, animated: false)
            }
            
        case .ended, .cancelled:
            if let indexPath = self.tableView.indexPathForRow(at: point) {
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.setSelected(false, animated: false)
            }
            
        default:
            break
        }
    }
}
