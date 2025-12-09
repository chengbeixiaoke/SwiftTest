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
