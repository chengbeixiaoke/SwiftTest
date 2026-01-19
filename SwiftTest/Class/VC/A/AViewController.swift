//
//  AViewController.swift
//  SwiftTest
//
//  Created by 王阳洋 on 2024/10/13.
//

import UIKit
import Combine
import Network
import SnapKit
import SwiftyJSON
import CoreStore
import Security
import CryptoKit
import Security
import CommonCrypto
import UIKit
import CombineCocoa
import AVFoundation
import AVKit
import MyPackage
import ffmpegkit
import YYKit

class AViewController: BaseViewController {
    private var cancellables = Set<AnyCancellable>()
    let customMenuView2 = UIView(frame: CGRectMake(50, 250, 200, 200))

    lazy var tableView =  {
        let tableView = BaseTableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = viewBackgroundColor
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ACell.self,
                           forCellReuseIdentifier: "ACell")
        
        tableView.register(A2Cell.self,
                           forCellReuseIdentifier: "A2Cell")
        
        return tableView
    }()
    
    var dataList: [Model] {
        return [Model(title: "主题色", vcClass: AppThemeViewController.self),
                Model(title: "K线图", vcClass: CandleStickDemoViewController.self),
                Model(title: "K线图2", vcClass: CandleStickDemoViewController2.self),
                Model(title: "K线图3", vcClass: CandleStickDemoViewController3.self),
                Model(title: "折线图", vcClass: GradientLineChartViewController.self),
                Model(title: "柱状图", vcClass: BarChartDemoViewController.self),
                Model(title: "组合图", vcClass: CombinedChartDemoViewController.self),
                Model(title: "饼状图", vcClass: SimplePieChartViewController.self),
                Model(title: "饼状图", vcClass: SimplePieChartViewController2.self),
                Model(title: "测试绘图", vcClass: ChatTestViewController.self),
                Model(title: "3D模型", vcClass: Test3DViewController.self),
                Model(title: "主题色", vcClass: AppThemeViewController.self),
                Model(title: "K线图", vcClass: CandleStickDemoViewController.self),
                Model(title: "K线图2", vcClass: CandleStickDemoViewController2.self),
                Model(title: "K线图3", vcClass: CandleStickDemoViewController3.self),
                Model(title: "折线图", vcClass: GradientLineChartViewController.self),
                Model(title: "柱状图", vcClass: BarChartDemoViewController.self),
                Model(title: "组合图", vcClass: CombinedChartDemoViewController.self),
                Model(title: "饼状图", vcClass: SimplePieChartViewController.self),
                Model(title: "饼状图", vcClass: SimplePieChartViewController2.self),
                Model(title: "测试绘图", vcClass: ChatTestViewController.self),
                Model(title: "3D模型", vcClass: Test3DViewController.self)]
    }
    
    var blurView2: TranslucentBlurView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blurView2.fractionComplete = 0.08
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "首页"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if #available(iOS 26.0, *) {
            tableView.topEdgeEffect.isHidden = true
        }
        
        blurView2 = TranslucentBlurView(frame: CGRectMake(0, 0, WidthScreen, 200), style: .systemUltraThinMaterial)
        blurView2.isUserInteractionEnabled = false
        view.addSubview(blurView2)
        
        if #available(iOS 26.0, *) {
            segmentedControl()
            setupMenuButton()
            setupMenuButton2()
            setupCustomMenu()
            setupCustomMenu2()
        }
    }
}

extension AViewController: UITableViewDelegate, UITableViewDataSource {
    struct Model {
        let title: String
        let vcClass: BaseViewController.Type
        
        init(title: String, vcClass: BaseViewController.Type) {
            self.title = title
            self.vcClass = vcClass
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HeightScreen
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACell", for: indexPath) as! ACell
        cell.nameLabel.text = dataList[indexPath.row].title
        cell.messageLabel.text = dataList[indexPath.row].vcClass.className()
        cell.contentView.backgroundColor = .BG_727386
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFLOAT_MIN
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return BaseView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFLOAT_MIN
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return BaseView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let vc = dataList[indexPath.row].vcClass.init()
//        navigationController?.pushViewController(vc, animated: true)
    }
}

// 选择条
@available(iOS 26.0, *)
extension AViewController {
    func segmentedControl() {
        let glassEffect = UIGlassEffect(style: .regular)
        glassEffect.isInteractive = true
        
        let wwwidth: CGFloat = 48
        let glassView = UIVisualEffectView(effect: glassEffect)
        glassView.cornerConfiguration = .capsule()
        glassView.frame = CGRect(x: (WidthScreen - wwwidth)/2.0, y: 300, width: 48, height: 48)
        view.addSubview(glassView)
        
        // 创建分段控制
        let segmentedControl = UISegmentedControl(items: ["选项1"])
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        
        // 样式设置
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = .systemBlue
        segmentedControl.backgroundColor = .systemBlue
        segmentedControl.selectedSegmentTintColor = .systemBlue
        // 添加事件
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        glassView.contentView.addSubview(segmentedControl)
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        print("选中了第 \(sender.selectedSegmentIndex) 个")
    }
}

// 菜单1 - 自定义button
@available(iOS 26.0, *)
extension AViewController {
    private func setupMenuButton() {
        // 创建按钮
        let menuButton = UIButton()
        menuButton.configuration = UIButton.Configuration.prominentClearGlass()
        menuButton.setTitle("选择操作", for: .normal)
        menuButton.frame = CGRect(x: 50, y: 100, width: 120, height: 44)
        
        
        let menu = UIMenu(
            title: "操作菜单",
            children: [
                UIAction(title: "新建文件",
                         image: UIImage(systemName: "doc.badge.plus"),
                         handler: { _ in self.createNewFile() }),
                UIAction(title: "打开文件",
                         image: UIImage(systemName: "folder"),
                         handler: { _ in self.openFile() }),
                UIAction(title: "保存文件",
                         image: UIImage(systemName: "square.and.arrow.down"),
                         handler: { _ in self.saveFile() }),
                UIMenu(title: "更多操作",
                       children: [UIAction(title: "分享",
                                           image: UIImage(systemName: "square.and.arrow.up"),
                                           handler: { _ in self.shareFile() }),
                                  UIAction(title: "打印",
                                           image: UIImage(systemName: "printer"),
                                           handler: { _ in self.printFile() })])
            ])
        
        let barButton = UIBarButtonItem(title: "菜单", image: nil, primaryAction: nil, menu: menu)
        barButton.style = .plain // 设置样式为 prominent，使玻璃背景更突出
        navigationItem.rightBarButtonItem = barButton
        
        // 设置菜单到按钮
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = false  // 点击直接显示菜单
        menuButton.configuration?.indicator = .popup
        
        // 添加按钮到视图
        view.addSubview(menuButton)
    }
    
    // 菜单项的操作方法
    private func createNewFile() {
        print("创建新文件")
    }
    
    private func openFile() {
        print("打开文件")
    }
    
    private func saveFile() {
        print("保存文件")
    }
    
    private func shareFile() {
        print("分享文件")
    }
    
    private func printFile() {
        print("打印文件")
    }
}

// 菜单2 - UIBarButtonItem
@available(iOS 26.0, *)
extension AViewController {
    private func setupMenuButton2() {
        let menu = UIMenu(
            title: "操作菜单",
            children: [
                UIAction(title: "新建文件",
                         image: UIImage(systemName: "doc.badge.plus"),
                         handler: { _ in self.createNewFile2() }),
                UIAction(title: "打开文件",
                         image: UIImage(systemName: "folder"),
                         handler: { _ in self.openFile2() }),
                UIAction(title: "保存文件",
                         image: UIImage(systemName: "square.and.arrow.down"),
                         handler: { _ in self.saveFile2() }),
                UIMenu(title: "更多操作",
                       children: [UIAction(title: "分享",
                                           image: UIImage(systemName: "square.and.arrow.up"),
                                           handler: { _ in self.shareFile2() }),
                                  UIAction(title: "打印",
                                           image: UIImage(systemName: "printer"),
                                           handler: { _ in self.printFile2() })])
            ])
        
        let barButton = UIBarButtonItem(title: "菜单", image: nil, primaryAction: nil, menu: menu)
        barButton.style = .prominent // 设置样式为 prominent，使玻璃背景更突出
        navigationItem.rightBarButtonItem = barButton
    }
    
    // 菜单项的操作方法
    private func createNewFile2() {
        print("创建新文件")
    }
    
    private func openFile2() {
        print("打开文件")
    }
    
    private func saveFile2() {
        print("保存文件")
    }
    
    private func shareFile2() {
        print("分享文件")
    }
    
    private func printFile2() {
        print("打印文件")
    }
}

// 自定义菜单
@available(iOS 26.0, *)
extension AViewController {
    // 使用 UIViewController 作为菜单内容
    class CustomMenuViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            // 添加自定义视图
        }
    }

    func setupCustomMenu() {
        // 创建按钮
        let menuButton = UIButton()
        menuButton.configuration = UIButton.Configuration.prominentClearGlass()
        menuButton.setTitle("选择操作2", for: .normal)
        menuButton.frame = CGRect(x: 50, y: 150, width: 120, height: 44)
        menuButton.addTarget(self, action: #selector(showCustomMenu(_ :)), for: .touchUpInside)
        // 添加按钮到视图
        view.addSubview(menuButton)
    }
    
    @objc func showCustomMenu(_ sender: UIButton) {
        // 通过 UIPopoverPresentationController 显示
        let customVC = CustomMenuViewController()
        customVC.modalPresentationStyle = .popover
        customVC.popoverPresentationController?.sourceView = sender
        present(customVC, animated: true)
    }
}

@available(iOS 26.0, *)
extension AViewController {
    func setupCustomMenu2() {
        // 创建按钮
        let menuButton = UIButton()
        menuButton.configuration = UIButton.Configuration.prominentClearGlass()
        menuButton.setTitle("选择操作2", for: .normal)
        menuButton.frame = CGRect(x: 50, y: 200, width: 120, height: 44)
        menuButton.addTarget(self, action: #selector(showCustomMenu2), for: .touchUpInside)
        // 添加按钮到视图
        view.addSubview(menuButton)
    }
    
    @objc func showCustomMenu2() {
        view.addSubview(customMenuView2)
        // 1. 准备菜单，初始状态缩小并透明
        customMenuView2.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        customMenuView2.alpha = 0
        customMenuView2.backgroundColor = .red
        customMenuView2.cornerConfiguration = .capsule()

        // 2. 使用弹簧动画显示
        UIView.animate(
            withDuration: 5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.customMenuView2.transform = .identity
                self.customMenuView2.alpha = 1
            },
            completion: nil
        )
    }
}
