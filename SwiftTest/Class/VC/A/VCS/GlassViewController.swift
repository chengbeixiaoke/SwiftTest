//
//  GlassViewController.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/19.
//

import UIKit
import SnapKit

class GlassViewController: BaseViewController {
    lazy var redView = {
        let view = K24HomeTransactionLeverageSliderView()
        view.updateUI(min: 3, max: 4)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "XXX"
        view.backgroundColor = .BG_F7F7F7_1_181818_1
        
        view.addSubview(redView)
        redView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(redView.viewWidth)
            make.height.equalTo(redView.viewHeight)
        }
        redView.valueChangedBlock = { index in
            printLog(index)
        }
    }
}
