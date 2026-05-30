//
//  GlassViewController.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/19.
//

import UIKit
import SnapKit

class GlassViewController: BaseViewController {
    lazy var segmentedControl = {
        let view = CustomSystemSegmentedView(frame: CGRectMake(UIScale(2), UIScale(1), WidthScreen - UIScale(30 + 4), UIScale(44)))
        view.normalConfig = [.foregroundColor:UIColor.Text_727386, .font: UIFont.systemFont(ofSize: 15)]
        view.selectedConfig = [.foregroundColor:UIColor.ColorBlack, .font:UIFont.systemFont(ofSize: 15)]
        view.selectedColor = .clear
        view.updateUI(titles: [""])
        view.selectedIndex = 0
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var redView = {
        let view = K24HomeTransactionLeverageSliderView()
        view.setCornerRadius(56/2.0)
        view.updateUI(min: 3, max: 9, current: 5)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "XXX"
        
        view.addSubview(redView)
        redView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(56)
        }

//        redView.addSubview(segmentedControl)
//        segmentedControl.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
}
