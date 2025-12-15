//
//  KLineDrawModel.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/12.
//

import UIKit

// MARK: - 数据源协议
public protocol KLineChartViewDataSource3: AnyObject {
    func loadHistoricalData(lineType: KLineType,
                            before date: Date,
                            count: Int,
                            completion: @escaping ([CandleStickData]) -> Void)
}

// MARK: - 状态枚举
public enum KLineChartViewLoadingState3 {
    case idle
    case loadingLeft
    case loadingRight
}

public class KLineDrawModel {
    public weak var chartView: KLineChartView3?
    public let configs: [KLineConfiguration3]
    public var currentConfig: KLineConfiguration3
    
    // 数据源
    public var dataSource: KLineChartViewDataSource3?
    
    init() {
        self.configs = [KLineConfiguration3(kLineType: .realTtime),
                        KLineConfiguration3(kLineType: .fiveDay),
                        KLineConfiguration3(kLineType: .dayK),
                        KLineConfiguration3(kLineType: .weekK),
                        KLineConfiguration3(kLineType: .monthK),
                        KLineConfiguration3(kLineType: .minute_1_K),
                        KLineConfiguration3(kLineType: .minute_5_K),
                        KLineConfiguration3(kLineType: .minute_15_K),
                        KLineConfiguration3(kLineType: .minute_30_K),
                        KLineConfiguration3(kLineType: .minute_60_K)]
        self.currentConfig = configs[2]
    }
    
    // 加载数据
    public func loadData() {
        currentConfig.calculateChartRect(chartView: chartView)
        
        guard let dataSource = dataSource else { return }
        dataSource.loadHistoricalData(lineType: currentConfig.kLineType,
                                      before: currentConfig.dataList.last?.date ?? Date(),
                                      count: currentConfig.dataList.count > 0 ? 50 : 100)
        { [weak self] dataList in
            guard let weakSelf = self else { return }
            
            weakSelf.currentConfig.dataList.append(contentsOf: dataList)
            weakSelf.currentConfig.calculateVisible()
            weakSelf.chartView?.setNeedsDisplay()
        }
    }
    
    func formatPrice(_ price: CGFloat) -> String {
        if price >= 100 {
            return String(format: "%.2f", price)
        } else if price >= 10 {
            return String(format: "%.3f", price)
        } else {
            return String(format: "%.4f", price)
        }
    }
}
