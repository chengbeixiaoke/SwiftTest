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
        let viewModel = KLineDrawViewModel(config: KLineConfig(kLineType: .dayK))
        viewModel.dataSource = self
        let view = KLineChartView(frame: rect, viewModel: viewModel)
        return view
    }()
    
    var dataList: [CandleStickData] = []
    var subDataList: [CandleStickData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataList = KLineDataGenerator.generateKLineData(type: .dayK, periods: 10000)
        dataList = dataList.sorted {$0.timestamp > $1.timestamp}
        setupUI()
    }
    
    func setupUI() {
        navigationItem.title = "K线图"
        view.addSubview(kLineView)
    }
}

extension CandleStickDemoViewController3: KLineChartViewDataSource3 {
    func loadHistoricalData(lineType: KLineType, before date: Date, count: Int, completion: @escaping ([CandleStickData]) -> Void)
    {
        guard let firstData = dataList.first else { return }
        if date >= firstData.date {
            if dataList.count <= count {
                completion(dataList)
                return
            }
            
            let subDataList = Array(dataList[0..<count])
            completion(subDataList)
            return
        }

        if let index = dataList.firstIndex(where: { $0.date == date }) {
            if dataList.count < ((index + 1) + count) {
                let subDataList = Array(dataList[(index + 1)...])
                completion(subDataList)
                return
            }
            
            let subDataList = Array(dataList[(index + 1)..<((index + 1) + count)])
            completion(subDataList)
            return
        }
        completion([])
    }
}
