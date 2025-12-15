//
//  KLineConfiguration3.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/10.
//

import UIKit

public enum KLineType: CaseIterable {
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

struct KLineXAxisTitleModel {
    let point: CGPoint
    let title: String
}

open class KLineConfiguration3 {
    // K线图类型
    let kLineType: KLineType
    
    public init(kLineType: KLineType) {
        self.kLineType = kLineType
    }
    
    // 数据
    public var dataList: [CandleStickData] = []

    // 背景色
    public var backgroundColor: UIColor = .BG_FE2B52_008
    
    // K线图Rect
    var kLineChartRect: CGRect = .zero
    
    // 显示X轴
    var showXAxis: Bool = true
    // X轴线条颜色
    var xAxisColor: UIColor = .Line_EA293C
    // X轴是否显示虚线
    var xAxisSisplayDottedLines: Bool = false
    // X轴线宽
    var xAxisLineWidth: CGFloat = 1.0
    // X轴文案颜色
    var xAxisTextColor: UIColor = .Text_777790
    // X轴坐标点
    var xAxisTitles: [KLineXAxisTitleModel] = []
    

    // 显示Y轴
    var showYAxis: Bool = true
    // Y轴线条颜色
    var yAxisColor: UIColor = .Line_EA293C
    // Y轴是否显示虚线
    var yAxisSisplayDottedLines: Bool = true
    // Y轴线宽
    var yAxisLineWidth: CGFloat = 1.0
    // Y轴文案颜色
    var yAxisTextColor: UIColor = .Text_777790
    
    
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
    
    // K线宽度
    var kLineWidth: CGFloat = 8.0
    // K线间隔
    var kLineSpacing: CGFloat = 1.0
    
    // 偏移量
    var offsetX: CGFloat = 0
    // 可见K线数量
    var visibleCount: Int = 0
    // 可见K线起始位置
    var visibleStartIndex: Int = 0
    // 可见最高价
    var visiblePriceMax: CGFloat = 0
    // 可见最低价
    var visiblePriceMin: CGFloat = 0
    // 可见数据容量
    var visibleVolumeMax: CGFloat = 0
    
    // 显示成交量
    var showVolume: Bool = true
    
    // 边距
    var margin: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    // 成交量视图高度
    var volumeHeight: CGFloat = 60
    // 成交量视图上边距
    var volumeTopMargin: CGFloat = 10
    
    
    
    
    
    
}


extension KLineConfiguration3 {
    // 计算图表范围
    func calculateChartRect(chartView: KLineChartView3?)
    {
        guard let chartView = chartView else {
            kLineChartRect = .zero
            return
        }
        
        let height = showVolume ?
        chartView.bounds.height - margin.horizontal - volumeHeight - volumeTopMargin :
        chartView.bounds.height - margin.horizontal
        
        let width = chartView.bounds.width - margin.vertical
        kLineChartRect = CGRect(x: margin.left,
                           y: margin.right,
                           width: width,
                           height: height)
    }
    
    // 数据处理
    func calculateVisible()
    {
        let totalWidthPerKline = kLineWidth + kLineSpacing
        
        // 计算可见K线数量
        visibleCount = min(Int(kLineChartRect.width / totalWidthPerKline), dataList.count)
        
        // 计算起始索引
        let totalKlinesWidth = CGFloat(dataList.count) * totalWidthPerKline
        if totalKlinesWidth <= kLineChartRect.width {
            visibleStartIndex = 0
        } else {
            let startIndexFloat = offsetX / totalWidthPerKline
            visibleStartIndex = max(0, Int(floor(startIndexFloat)))
            visibleStartIndex = min(visibleStartIndex, dataList.count - visibleCount)
        }
        
        guard visibleCount > 0 else {
            visiblePriceMax = 0
            visiblePriceMin = 0
            visibleVolumeMax = 0
            return
        }
        
        let endIndex = min(visibleStartIndex + visibleCount, dataList.count)
        let visibleData = Array(dataList[visibleStartIndex..<endIndex])
        
        guard let first = visibleData.first else {
            visiblePriceMax = 0
            visiblePriceMin = 0
            visibleVolumeMax = 0
            return
        }
        
        visiblePriceMax = first.high
        visiblePriceMin = first.low
        visibleVolumeMax = first.volume
        
        for data in visibleData {
            visiblePriceMax = max(visiblePriceMax, data.high)
            visiblePriceMin = min(visiblePriceMin, data.low)
            visibleVolumeMax = max(visibleVolumeMax, data.volume)
        }
        
        // 计算X轴坐标点
        calculateVisibleXAxisTitles()
    }
    
    // 计算X轴日期显示
    func calculateVisibleXAxisTitles() {
        switch kLineType {
        case .realTtime:
            xAxisTitles = [KLineXAxisTitleModel(point: CGPointMake(kLineChartRect.minX, 0), title: "09:30"),
                           KLineXAxisTitleModel(point: CGPointMake(kLineChartRect.minX + kLineChartRect.width / 2.0, 0), title: "11:30/13:00") ,
                           KLineXAxisTitleModel(point: CGPointMake(kLineChartRect.maxX, 0), title: "15:00")]
        case .fiveDay:
            xAxisTitles = []
        case .dayK:
            var list: [KLineXAxisTitleModel] = []
            let subDataList = dataList[visibleStartIndex...(visibleStartIndex + visibleCount)]
            
            var next: CandleStickData? = nil
            for (index, data) in subDataList.enumerated() {
                if let next = next {
                    if next.date_yyyymm != data.date_yyyymm {
                        let x = CGFloat(index) * (kLineWidth + kLineSpacing)
                        list.append(KLineXAxisTitleModel(point: CGPointMake(x, 0), title: next.date_yyyymm))
                    }
                }
                
                next = data
            }
            xAxisTitles = list
            
        case .weekK:
            xAxisTitles = []
        case .monthK:
            xAxisTitles = []
        case .minute_1_K:
            xAxisTitles = []
        case .minute_5_K:
            xAxisTitles = []
        case .minute_15_K:
            xAxisTitles = []
        case .minute_30_K:
            xAxisTitles = []
        case .minute_60_K:
            xAxisTitles = []
        }
    }
}
