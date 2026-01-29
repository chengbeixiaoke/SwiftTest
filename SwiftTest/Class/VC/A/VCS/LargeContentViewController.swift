//
//  LargeContentViewController.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/20.
//

import SnapKit

class LargeContentViewController: BaseViewController {
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
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "XXX"
        
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        tableView.contentInset = UIEdgeInsets(top: 110, left: 0, bottom: 0, right: 0)
//        
//        if #available(iOS 26.0, *) {
//            tableView.topEdgeEffect.isHidden = true
//            tableView.bottomEdgeEffect.isHidden = true
//        }

        if #available(iOS 26.0, *) {
            segmentedControl()
            
            do {
                let glassView = RegularGlassBlurView()
                glassView.frame = CGRectMake(50, 250, 80, 44)
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
                glassView.frame = CGRectMake(140, 250, 80, 44)
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

extension LargeContentViewController: UITableViewDelegate, UITableViewDataSource {
    class ACell: BaseTableViewCell {
        let xx_imageView = UIImageView(frame: CGRectMake(0, 0, WidthScreen, HeightScreen))

        override func setupUI() {
            super.setupUI()
            
            xx_imageView.contentMode = .scaleToFill
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
extension LargeContentViewController {
    func segmentedControl() {
        let wwwidth: CGFloat = 300
        let frame = CGRect(x: (WidthScreen - wwwidth)/2.0, y: 150, width: wwwidth, height: 48)
        
        let glassEffect = UIGlassEffect(style: .regular)
        glassEffect.isInteractive = true
        glassEffect.tintColor = UIColor.white
        
        let glassView = UIVisualEffectView(effect: glassEffect)
        glassView.cornerConfiguration = .capsule()
        glassView.frame = frame
        view.addSubview(glassView)
        
        // 创建分段控制
        let segmentedControl = UISegmentedControl(items: ["测试", "测试", "测试", "测试"])
//        let segmentedControl = UISegmentedControl()
//        segmentedControl.insertSegment(with: UIImage(color: .white, size: CGSizeMake(30, 30)), at: 0, animated: true)
//        segmentedControl.insertSegment(with: UIImage(color: .white, size: CGSizeMake(30, 30)), at: 1, animated: true)
//        segmentedControl.insertSegment(with: UIImage(color: .white, size: CGSizeMake(30, 30)), at: 2, animated: true)
//        segmentedControl.insertSegment(with: UIImage(color: .white, size: CGSizeMake(30, 30)), at: 3, animated: true)
//        segmentedControl.insertSegment(with: UIImage(color: .white, size: CGSizeMake(30, 30)), at: 4, animated: true)
        
        
        
        segmentedControl.setImage(UIImage(color: .white.withAlphaComponent(0.5), size: CGSizeMake(10, 10)), forSegmentAt: 2)

        segmentedControl.frame = CGRect(x: 4, y: 4, width: wwwidth, height: 40)
        
        // 样式设置
        segmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12),
                                                 .foregroundColor: UIColor.black,
                                                 .backgroundColor: UIColor.white],
                                                for: .normal)
        segmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13),
                                                 .foregroundColor: UIColor.black,
                                                 .backgroundColor: UIColor.white],
                                                for: .selected)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.tintColor = UIColor.white
        segmentedControl.selectedSegmentTintColor = .green
        
        // 添加事件
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        glassView.contentView.addSubview(segmentedControl)
        
        segmentedControl.setWidth(100, forSegmentAt: 2)
        
//        let label = UILabel(frame: CGRectMake(0, 0, 50, 40))
//        label.text = "测试"
//        label.textColor = UIColor.black
//        label.isUserInteractionEnabled = true
//        glassView.contentView.addSubview(label)

        delay(seconds: 1.0) {
            segmentedControl.subviews.forEach { view in
                if let xx = view as? UIImageView {
                    xx.isHidden = true
                    printLog("[WWWW]: \(xx)")
                }
            }
        }
        
//        do {
//            let glassEffect = UIGlassEffect(style: .clear)
//            glassEffect.isInteractive = true
//            
//            let wwwidth: CGFloat = 300
//            let glassView = UIVisualEffectView(effect: glassEffect)
//            glassView.cornerConfiguration = .capsule()
//            glassView.frame = CGRect(x: (WidthScreen - wwwidth)/2.0, y: 200, width: wwwidth, height: 48)
//            view.addSubview(glassView)
//        }
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        print("选中了第 \(sender.selectedSegmentIndex) 个")
    }
}


class CustomSegmentedControlViewController: BaseViewController {
    
    private var customSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupCustomSegmentedControl()
        
        let xxxview = UIView(frame: CGRectMake(100, 340, WidthScreen - 200, 50))
        xxxview.backgroundColor = .red
        view.addSubview(xxxview)
        
//        UIButton.Configuration.glass()
        let items = ["首页", "发现", "消息", "我的"]
        customSegmentedControl = UISegmentedControl(items: items)
        view.addSubview(customSegmentedControl)
        customSegmentedControl.frame = CGRectMake(100, 300, WidthScreen - 200, 50)
        
//        customSegmentedControl.backgroundColor = UIColor.red
        
        customSegmentedControl.tintColor = .white
        customSegmentedControl.selectedSegmentTintColor = UIColor.green
        
        let imagexx = UIImage.init(color: .red, size: CGSize(width: 100, height: 100))
//        customSegmentedControl.setImage(imagexx, forSegmentAt: 1)
//        
        customSegmentedControl.insertSegment(with: UIImage(named: "miniapp_auth_icon_1"), at: 0, animated: true)
        
        let imagexx2 = UIImage.init(color: .red, size: CGSize(width: 100, height: 100))
        let imageView = UIImageView(frame: CGRectMake(100, 440, 100, 100))
        imageView.image = imagexx2
        view.addSubview(imageView)
    }
    
    private func setupCustomSegmentedControl() {
        let items = ["首页", "发现", "消息", "我的"]
        customSegmentedControl = UISegmentedControl(items: items)
        
        if #available(iOS 13.0, *) {
            configureiOS13PlusAppearance()
        } else {
            configureLegacyAppearance()
        }
        
        // 设置位置
        customSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customSegmentedControl)
        
        NSLayoutConstraint.activate([
            customSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            customSegmentedControl.widthAnchor.constraint(equalToConstant: 300),
            customSegmentedControl.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 添加事件
        customSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    
    @available(iOS 13.0, *)
    private func configureiOS13PlusAppearance() {
        // 1. 创建外观配置
        let appearance = UISegmentedControl.appearance()
        
        // 2. 设置选中状态的背景颜色
        let selectedColor = UIColor.systemBlue
        let normalColor = UIColor.systemGray5
        
        // 3. 使用 UISegmentedControl 的新 API
        let backgroundImage = UIImage(color: normalColor, size: CGSize(width: 1, height: 44))
        let selectedBackgroundImage = UIImage(color: selectedColor, size: CGSize(width: 1, height: 44))
        
        // 设置背景
        customSegmentedControl.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        customSegmentedControl.setBackgroundImage(selectedBackgroundImage, for: .selected, barMetrics: .default)
        customSegmentedControl.setBackgroundImage(selectedBackgroundImage, for: [.highlighted, .selected], barMetrics: .default)
        
        // 4. 设置分割线
        let dividerImage = UIImage(color: UIColor.clear, size: CGSize(width: 1, height: 44))
        customSegmentedControl.setDividerImage(dividerImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        // 5. 设置标题样式
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
        
        customSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        customSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        // 6. 设置圆角
        customSegmentedControl.layer.cornerRadius = 22
        customSegmentedControl.layer.masksToBounds = true
        customSegmentedControl.layer.borderWidth = 1
        customSegmentedControl.layer.borderColor = UIColor.systemGray4.cgColor
        
        // 7. 设置选中指示器动画
        customSegmentedControl.selectedSegmentTintColor = selectedColor
    }
    
    private func configureLegacyAppearance() {
        // iOS 12 及以下的自定义
        customSegmentedControl.tintColor = .clear
        customSegmentedControl.backgroundColor = .systemGray5
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
        
        customSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        customSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        // 自定义选中背景
        customSegmentedControl.layer.cornerRadius = 22
        customSegmentedControl.layer.masksToBounds = true
        
        // 设置选中背景
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let segment = self.customSegmentedControl.subviews.first as? UIView {
                segment.backgroundColor = .systemBlue
            }
        }
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        print("选中的 segment: \(sender.selectedSegmentIndex)")
        
        // 添加选中动画
        animateSegmentSelection()
    }
    
    private func animateSegmentSelection() {
        UIView.animate(withDuration: 0.1, animations: {
            self.customSegmentedControl.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.customSegmentedControl.transform = .identity
            }
        }
    }
}

// UIImage 扩展，用于创建纯色图片
extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

// 创建真正的透明图片
extension UIImage {
    static var transparent: UIImage? {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        UIColor.clear.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
