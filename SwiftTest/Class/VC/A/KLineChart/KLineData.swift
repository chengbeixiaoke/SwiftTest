//
//  KLineData.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/9.
//

import UIKit

class KLineData {
    // 开盘价
    let open: CGFloat
    
    // 收盘价
    let close: CGFloat
    
    // 最高价
    let high: CGFloat
    
    // 最低价
    let low: CGFloat
    
    // 成交量
    let volume: CGFloat
    
    // 日期
    let date: String
    
    // 时间戳
    let timestamp: TimeInterval
    
    // 计算涨跌
    var change: CGFloat {
        return close - open
    }
    
    // 是否是上涨
    var isUp: Bool {
        return change >= 0
    }
    
    init(open: CGFloat, close: CGFloat, high: CGFloat, low: CGFloat, volume: CGFloat, date: String, timestamp: TimeInterval) {
        self.open = open
        self.close = close
        self.high = high
        self.low = low
        self.volume = volume
        self.date = date
        self.timestamp = timestamp
    }
}

// MARK: - 示例数据源实现
class MockKLineDataSource: KLineChartViewDataSource {
    
    private var allData: [KLineData] = []
    private var currentStartIndex = 5000
    private let totalDataCount = 10000
    private let pageSize = 50
    
    init() {
        // 生成所有数据
        generateRealisticStockData()
    }
    
    private func generateRealisticStockData() {
        var data: [KLineData] = []
        
        // 真实的股票初始价格（比如苹果股票）
        var lastClose: CGFloat = 150.0
        
        let startDate = Date().addingTimeInterval(-Double(totalDataCount) * 24 * 3600)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        
        // 模拟股票波动（百分比变化更真实）
        for i in 0..<totalDataCount {
            let date = Date(timeInterval: TimeInterval(i) * 24 * 3600, since: startDate)
            let dateString = dateFormatter.string(from: date)
            
            // 使用百分比变化（更符合实际股票）
            let volatility: CGFloat = 0.02 // 2% 日波动率
            let dailyChange = CGFloat.random(in: -volatility...volatility)
            
            let open = lastClose
            var close = open * (1 + dailyChange)
            
            // 确保价格不为负（虽然实际中股票价格不会为负）
            close = max(0.01, close)
            
            // 日内波动（最高最低价）
            let intradayVolatility = abs(dailyChange) * 1.5 // 日内波动大于日波动
            let high = close * (1 + CGFloat.random(in: 0...intradayVolatility))
            let low = close * (1 - CGFloat.random(in: 0...intradayVolatility/2))
            
            // 确保高低价合理
            let actualHigh = max(open, close, high)
            let actualLow = min(open, close, low)
            
            // 成交量与价格变化正相关
            let baseVolume: CGFloat = 1000000
            let volumeMultiplier = 1 + abs(dailyChange) * 10
            let volume = baseVolume * volumeMultiplier * CGFloat.random(in: 0.8...1.2)
            
            let klineData = KLineData(
                open: open,
                close: close,
                high: actualHigh,
                low: max(0.01, actualLow), // 确保最低价不为负
                volume: volume,
                date: dateString,
                timestamp: date.timeIntervalSince1970
            )
            
            data.append(klineData)
            lastClose = close
        }
        
        allData = data
    }
    
    func loadHistoricalData(before date: Date, count: Int, completion: @escaping ([KLineData]) -> Void) {
        // 模拟网络延迟
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            let filteredData = self.allData.filter { $0.timestamp < date.timeIntervalSince1970 }
            let newData = Array(filteredData.suffix(count))
            
            // 更新索引
            self.currentStartIndex = max(0, self.currentStartIndex - newData.count)
            
            completion(newData)
        }
    }
    
    func loadRecentData(after date: Date, count: Int, completion: @escaping ([KLineData]) -> Void) {
        // 模拟网络延迟
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            let filteredData = self.allData.filter { $0.timestamp > date.timeIntervalSince1970 }
            let newData = Array(filteredData.prefix(count))
            
            // 更新索引
            self.currentStartIndex = min(self.totalDataCount - count, self.currentStartIndex + newData.count)
            
            completion(newData)
        }
    }
    
    func getInitialData(count: Int) -> [KLineData] {
        let start = currentStartIndex
        let end = min(start + count, totalDataCount)
        return Array(allData[start..<end])
    }
}
