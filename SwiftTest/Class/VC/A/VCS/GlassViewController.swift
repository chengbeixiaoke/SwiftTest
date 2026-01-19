//
//  GlassViewController.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/19.
//

import UIKit

class GlassViewController: BaseViewController {
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
    
    var blurView2: TranslucentBlurView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        blurView2.resetDraw()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "首页"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if #available(iOS 26.0, *) {
//            tableView.topEdgeEffect.isHidden = true
        }
        
//        blurView2 = TranslucentBlurView(frame: CGRectMake(0, 0, WidthScreen, 83), style: .systemUltraThinMaterial)
//        blurView2.isUserInteractionEnabled = false
//        blurView2.locations = [0.0, 0.8, 1.0]
//        view.addSubview(blurView2)
        
        if #available(iOS 26.0, *) {
            segmentedControl()
            setupMenuButton()
            setupMenuButton2()
            setupCustomMenu()
            
            
//            do {
//                let glassEffect = UIGlassEffect(style: .regular)
//                glassEffect.isInteractive = true
//                glassEffect.tintColor = UIColor.blue.withAlphaComponent(0.01)
//                
//                let glassView = UIVisualEffectView(effect: glassEffect)
//                glassView.frame = CGRect(x: 50, y: 500, width: 80, height: 44)
//                glassView.setCornerRadius(22)
//                view.addSubview(glassView)
//                
//                let label = UILabel()
//                label.text = "自适应"
//                label.textColor = UIColor(named: "text0000001FFFFFF1")
//                glassView.contentView.addSubview(label)
//                label.snp.makeConstraints { make in
//                    make.centerX.centerY.equalToSuperview()
//                }
//            }
            
            do {
                let glassView = RegularGlassBlurView()
                glassView.frame = CGRect(x: 50, y: 500, width: 80, height: 44)
                glassView.setCornerRadius(22)
                view.addSubview(glassView)
                
                let label = UILabel()
                label.text = "自适应"
                label.textColor = UIColor(named: "text0000001FFFFFF1")
                glassView.contentView.addSubview(label)
                label.snp.makeConstraints { make in
                    make.centerX.centerY.equalToSuperview()
                }
            }
            
            do {
                let glassEffect = UIGlassEffect(style: .clear)
                glassEffect.isInteractive = true
                
                let glassView = UIVisualEffectView(effect: glassEffect)
                glassView.frame = CGRect(x: 140, y: 500, width: 80, height: 44)
                glassView.setCornerRadius(22)
                view.addSubview(glassView)
                
                let label = UILabel()
                label.text = "全透明"
                label.textColor = UIColor.white
                glassView.contentView.addSubview(label)
                label.snp.makeConstraints { make in
                    make.centerX.centerY.equalToSuperview()
                }
            }
        }
    }
}

extension GlassViewController: UITableViewDelegate, UITableViewDataSource {
    class ACell: BaseTableViewCell {
        let xx_imageView = UIImageView(frame: CGRectMake(0, 0, WidthScreen, HeightScreen))

        override func setupUI() {
            super.setupUI()
            
            xx_imageView.contentMode = .scaleAspectFill
            xx_imageView.image = UIImage(named: "test001")
            contentView.addSubview(xx_imageView)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HeightScreen/2.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACell", for: indexPath) as! ACell
        let index = indexPath.row % 3
        if index == 0 {
            cell.xx_imageView.image = UIImage(named: "app_bg_1")
        }
        if index == 1 {
            cell.xx_imageView.image = UIImage(named: "app_bg_2")
        }
        if index == 2 {
            cell.xx_imageView.image = UIImage(named: "app_bg_3")
        }
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
        
    }
}

// 选择条
@available(iOS 26.0, *)
extension GlassViewController {
    func segmentedControl() {
        let glassEffect = UIGlassEffect(style: .regular)
        glassEffect.isInteractive = true
        
        let wwwidth: CGFloat = 300
        let glassView = UIVisualEffectView(effect: glassEffect)
        glassView.cornerConfiguration = .capsule()
        glassView.frame = CGRect(x: (WidthScreen - wwwidth)/2.0, y: 300, width: wwwidth, height: 48)
        view.addSubview(glassView)
        
        // 创建分段控制
        let segmentedControl = UISegmentedControl(items: ["选项1", "选项2", "选项3", "选项4"])
        segmentedControl.frame = glassView.bounds
        
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
extension GlassViewController {
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
extension GlassViewController {
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
        barButton.style = .plain
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
extension GlassViewController {
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
