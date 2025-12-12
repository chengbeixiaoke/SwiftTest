//
//  KLineConfiguration3.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/10.
//

import UIKit

enum KLineType: CaseIterable {
    // 分时
    case realTtime
    // 5日
    case fiveDay
    // 日K - X轴跨度1个月
    case dayK
    // 周K - X轴跨度6个月
    case weekK
    // 月K - X轴跨度2年
    case monthK
    // 1分 - X轴跨度30分钟
    case minute_1_K
    // 5分 - X轴跨度60分钟/1小时
    case minute_5_K
    // 15分 - X轴跨度2天
    case minute_15_K
    // 30分 - X轴跨度4天
    case minute_30_K
    // 60分 - X轴跨度8天
    case minute_60_K
    
    var description: String {
        switch self {
        case .realTtime: return "分时"
        case .fiveDay: return "五日"
        case .dayK: return "日K"
        case .weekK: return "周K"
        case .monthK: return "月K"
        case .minute_1_K: return "1分钟K"
        case .minute_5_K: return "5分钟K"
        case .minute_15_K: return "15分钟K"
        case .minute_30_K: return "30分钟K"
        case .minute_60_K: return "60分钟K"
        }
    }
    
    // 获取时间间隔（分钟）
    var minuteInterval: Int? {
        switch self {
        case .minute_1_K: return 1
        case .minute_5_K: return 5
        case .minute_15_K: return 15
        case .minute_30_K: return 30
        case .minute_60_K: return 60
        default: return nil
        }
    }
}

open class KLineConfiguration3 {
    // K线图类型
    var kLineType: KLineType = .dayK
    
    // 背景色
    public var backgroundColor: UIColor = .BG_FE2B52_008
    
    
    // 显示X轴
    var showXAxis: Bool = true
    // X轴线条颜色
    var xAxisColor: UIColor = .Line_EA293C
    // X轴是否显示虚线
    var xAxisSisplayDottedLines: Bool = false
    // X轴线宽
    var xAxisLineWidth: CGFloat = 1.0

    
    // 显示Y轴
    var showYAxis: Bool = true
    // Y轴线条颜色
    var yAxisColor: UIColor = .Line_EA293C
    // Y轴是否显示虚线
    var yAxisSisplayDottedLines: Bool = true
    // Y轴线宽
    var yAxisLineWidth: CGFloat = 1.0
    
    
    // 显示网格
    var showGrid: Bool = true
    // 水平网格线条颜色
    var gridXColor: UIColor = .Line_EA293C
    // 水平网格是否显示虚线
    var gridXSisplayDottedLines: Bool = true
    // 水平网格线宽
    var gridXLineWidth: CGFloat = 1.0
    // 水平网格条数
    var gridXLines: Int = 4
    // 垂直网格线条颜色
    var gridYColor: UIColor = .Line_037F5F
    // 垂直网格是否显示虚线
    var gridYSisplayDottedLines: Bool = true
    // 垂直网格线宽
    var gridYLineWidth: CGFloat = 1.0
    // 垂直网格条数
    var gridYLines: Int = 4
    
    
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
