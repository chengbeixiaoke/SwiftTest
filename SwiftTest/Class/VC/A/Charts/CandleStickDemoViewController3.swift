//
//  CandleStickDemoViewController3.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/10.
//

import UIKit

class CandleStickDemoViewController3: BaseViewController {
    
    lazy var kLineView = {
        let rect = CGRectMake(0, 100, WidthScreen, WidthScreen)
        let config = KLineConfiguration3()
        let view = KLineChartView3(frame: rect,
                                   config: config)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        navigationItem.title = "K线图"
        
        view.addSubview(kLineView)
    }
}
