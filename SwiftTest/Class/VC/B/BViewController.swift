//
//  BViewController.swift
//  SwiftTest
//
//  Created by 王阳洋 on 2024/10/13.
//

import UIKit
import Combine
import SnapKit
import SwifterSwift

class BViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var listArray: [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    lazy var tableView = {
        let tableView = BaseTableView(frame: .zero, style: .plain)
        // 允许在编辑模式下选择行
        tableView.allowsSelectionDuringEditing = true
        
        tableView.register(BCell.self,
                           forCellReuseIdentifier: "BCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    weak var editingCell: LeftSlideCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "BVC"
        view.backgroundColor = .yellow
        
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
        cell.selectionStyle = .none
        cell.nameLabel.text = listArray[indexPath.row]
        cell.messageLabel.text = "测试\(listArray[indexPath.row])"
        cell.setupLeftSlideView([.delete, .mute, .top])
        cell.changeEditingBlock = { [weak self] _cell in
            guard let weakSelf = self else { return }
            weakSelf.editingCell = _cell
        }
        cell.clickDeleteBlock = { [weak self] in
            guard let weakSelf = self else { return }
            print("删除")
        }
        cell.clickMuteBlock = { [weak self] in
            guard let weakSelf = self else { return }
            print("静音")
        }
        cell.clickTopBlock = { [weak self] in
            guard let weakSelf = self else { return }
            print("置顶")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScale(80)
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
        if let cell = editingCell {
            cell.hideLeftSlideView(0.3) { _ in }
        }
        else {
            if let cell = tableView.cellForRow(at: indexPath) as? BCell {
                cell.hideWyy_backgroundView(0.3)
            }
            
            let alert = UIAlertController(title: "测试", message: "测试Alert弹窗", preferredStyle: .alert)
            alert.addAction(title: "确定", style: .destructive) { _ in }
            alert.addAction(title: "取消", style: .cancel) { _ in }
            present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if editingCell == nil {
            if let cell = tableView.cellForRow(at: indexPath) as? BCell {
                cell.showWyy_backgroundView()
            }
        }
        return true
    }
}
