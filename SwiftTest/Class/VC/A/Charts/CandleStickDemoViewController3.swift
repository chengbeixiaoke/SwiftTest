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
        let config = KLineConfiguration3(kLineType: .realTtime)
        let drawModel = KLineDrawModel()
        drawModel.dataSource = self
        
        let view = KLineChartView3(frame: rect, drawModel: drawModel)
        return view
    }()
    
    var dataList: [CandleStickData] = []
    var subDataList: [CandleStickData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataList = KLineDataGenerator.generateKLineData(type: .dayK, periods: 10000)
        dataList = dataList.sorted {$0.timestamp > $1.timestamp}
//        test()
        setupUI()
    }
    
    func setupUI() {
        navigationItem.title = "K线图"
        view.addSubview(kLineView)
    }
    
    func test() {
        let count: Int = 61
        loadHistoricalData(lineType: .dayK,
                           before: subDataList.last?.date ?? Date(),
                           count: count)
        { [weak self] list in
            guard let weakSelf = self else { return }
            list.forEach { data in
                printLog(data.date)
            }
            printLog("######################################################")
            weakSelf.subDataList.append(contentsOf: list)
            list.count < count ? nil : weakSelf.test()
        }
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
