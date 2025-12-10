//
//  KLineConfiguration3.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/10.
//

import UIKit

enum KLineType {
    // 分时
    case realTtime
    // 5日
    case fiveDay
    // 日K
    case dayK
    // 周K
    case weekK
    // 月K
    case monthK
    // 1分
    case minute_1_K
    // 5分
    case minute_5_K
    // 15分
    case minute_15_K
    // 30分
    case minute_30_K
    // 60分
    case minute_60_K
}

open class KLineConfiguration3 {
    // K线图类型
    var kLineType: KLineType = .dayK
    
    // 背景色
    public var backgroundColor: UIColor = .BG_FE2B52_008
    
    
    // 显示X轴
    var showXAxis: Bool = true
    // 显示Y轴
    var showYAxis: Bool = true
    
    
    
    // 显示网格
    var showGrid: Bool = true
    // 网格线条颜色
    var gridColor: UIColor = .Line_E4E5E6_05
    // 网格是否显示虚线
    var gridSisplayDottedLines: Bool = true
    // 网格线宽
    var gridLineWidth: CGFloat = 1.0
    
    // 显示成交量
    var showVolume: Bool = true
    
    
    // 上边距
    var topMargin: CGFloat = 10
    // 下边距
    var bottomMargin: CGFloat = 10
    // 左边距
    var leftMargin: CGFloat = 10
    // 右边距
    var rightMargin: CGFloat = 10
    // 成交量视图高度
    var volumeHeight: CGFloat = 60
    // 成交量视图上边距
    var volumeTopMargin: CGFloat = 10

}
