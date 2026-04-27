//
//  LargeContentViewController.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/20.
//

import UIKit
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
        
        if #available(iOS 26.0, *) {
            let segmentedView = CustomSegmentedView(frame: .zero)
            view.addSubview(segmentedView)
            segmentedView.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.width.equalTo(WidthScreen - 36)
                make.height.equalTo(64)
            }
            delay(seconds: 0.25) {
                segmentedView.updateUI(titles: ["测试1", "测试2", "测试3", "测试4", "测试5"])
            }
        }
    }
}

extension LargeContentViewController: UITableViewDelegate, UITableViewDataSource {
    class ACell: BaseTableViewCell {
        let xx_imageView = UIImageView(frame: CGRectMake(0, 0, WidthScreen, HeightScreen))
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
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

@available(iOS 26.0, *)
class CustomSegmentedView: UIView {
    public var clickBlock: ((Int)->())?
    public var selectedIndex: Int = 0 {
        didSet {
            segmentedControl.selectedSegmentIndex = selectedIndex
        }
    }
    
    private lazy var segmentedControl = {
        let view = UISegmentedControl()
        view.backgroundColor = UIColor.clear
        view.selectedSegmentTintColor = UIColor.ColorFromHex("000000", 0.1)
        view.setTitleTextAttributes([.foregroundColor: UIColor.red], for: .normal)
        view.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        view.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        view.addTarget(self, action: #selector(segmentDragInside(_:)), for: .editingDidBegin)

        return view
    }()
    
    private lazy var glassView = {
        let glassEffect = UIGlassEffect(style: .regular)
        glassEffect.isInteractive = true
        glassEffect.tintColor = UIColor.white
        
        let glassView = UIVisualEffectView(effect: glassEffect)
        glassView.cornerConfiguration = .capsule()
        glassView.frame = frame
        return glassView
    }()
    
    var contentViews: [ContntView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI()
    {
        addSubview(glassView)
        glassView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        glassView.contentView.addSubview(segmentedControl)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl)
    {
        clickBlock?(sender.selectedSegmentIndex)
        printLog("点击: \(sender.selectedSegmentIndex)")
    }
    
    @objc private func segmentDragInside(_ sender: UISegmentedControl)
    {
        clickBlock?(sender.selectedSegmentIndex)
        printLog("拖动: \(sender.selectedSegmentIndex)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        segmentedControl.subviews.forEach { view in
            if view is UIImageView {
                view.isHidden = true
            }
        }
        printLog("[WTT] XXX")
        segmentedControl.frame = CGRectMake(2, 2, bounds.width - 4, bounds.height - 4)
    }
    
    public func updateUI(titles: [String])
    {
        segmentedControl.removeAllSegments()
        contentViews.forEach({ $0.removeFromSuperview() })
        contentViews.removeAll()
        
        titles.forEach { title in
            segmentedControl.insertSegment(withTitle: "", at: 0, animated: true)
        }
        
        let width = (bounds.width - 4) / CGFloat(titles.count)

        titles.enumerated().forEach { index, title in
            segmentedControl.setWidth(width, forSegmentAt: index)
        }
        
        var bgView: UIView?
        segmentedControl.subviews.forEach { view in
            if view is UIImageView {
                view.isHidden = true
                bgView = view
            }
        }
        
//        let viewWidth = (WidthScreen - 36) / CGFloat(titles.count)
        let viewHeight = 64.0

        titles.enumerated().forEach { index, title in
            let view = ContntView(frame: CGRectMake(CGFloat(index) * width, 0, width, viewHeight))
            view.isUserInteractionEnabled = false
            view.titleLabel.text = title
            view.imageView.image = UIImage(named: "im_delete")
            self.contentViews.append(view)
            
            if let bgView = bgView {
                self.segmentedControl.insertSubview(view, belowSubview: bgView)
            } else {
                self.segmentedControl.addSubview(view)
            }
        }
        
//        segmentedControl.setContentPositionAdjustment(.init(horizontal: -40, vertical: 0), forSegmentType: .left, barMetrics: .default)
//        segmentedControl.setContentPositionAdjustment(.init(horizontal: -9.5, vertical: 0), forSegmentType: .right, barMetrics: .default)
        
        segmentedControl.setContentOffset(CGSizeMake(20, 0), forSegmentAt: 0)
    }
}

@available(iOS 26.0, *)
extension CustomSegmentedView {
    class ContntView: UIView {
        lazy var imageView = {
            let imageView = UIImageView(frame: .zero)
            return imageView
        }()
        
        lazy var titleLabel = {
            let label = UILabel(frame: .zero)
            label.font = UIFont.boldSystemFont(ofSize: 12)
            label.textColor = UIColor.black
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupUI() {
            let contentView = UIView(frame: .zero)
            addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
            }
            
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.height.equalTo(20)
            }
            
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(5)
                make.centerX.equalToSuperview()
                make.height.equalTo(20)
                make.bottom.equalToSuperview()
            }
        }
    }
}
