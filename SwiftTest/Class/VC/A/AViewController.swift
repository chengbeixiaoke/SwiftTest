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
        return [Model(title: "GlassView", vcClass: GlassViewController.self),
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
    
    var glassView: UIView?
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 26.0, *) {
            if let glassView = glassView as? TranslucentGlassBlurView {
                glassView.resetDraw()
            }
        }
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
            
            let glassContainerEffect = UIGlassContainerEffect()
            glassContainerEffect.spacing = 10
            let glassContainerEffectView = UIVisualEffectView(effect: glassContainerEffect)
            glassContainerEffectView.frame = CGRectMake(50, 500, 200, 64)
            view.addSubview(glassContainerEffectView)
            
            do {
                let glassEffect = UIGlassEffect(style: .clear)
                glassEffect.isInteractive = true
                glassEffect.tintColor = UIColor.clear

                let glassView = UIVisualEffectView(effect: glassEffect)
                glassView.frame = CGRect(x: 10, y: 10, width: 80, height: 44)
                glassView.setCornerRadius(22)
                glassContainerEffectView.contentView.addSubview(glassView)
                
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
                glassEffect.tintColor = UIColor.clear
                
                let glassView = UIVisualEffectView(effect: glassEffect)
                glassView.frame = CGRect(x: 100, y: 10, width: 80, height: 44)
                glassView.setCornerRadius(22)
                glassView.contentView.backgroundColor = UIColor.clear
                glassContainerEffectView.contentView.addSubview(glassView)
                
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
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACell", for: indexPath) as! ACell
        cell.nameLabel.text = dataList[indexPath.row].title
        cell.messageLabel.text = dataList[indexPath.row].vcClass.className()
        cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? .white : .black
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
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = dataList[indexPath.row].vcClass.init()
        navigationController?.pushViewController(vc, animated: true)
    }
}
