//
//  KLineDrawModel.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/12.
//

import UIKit

// MARK: - 数据源协议
protocol KLineChartViewDataSource3: AnyObject {
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

// MARK: - 横坐标点
struct KLineXAxisTitleModel {
    let point: CGPoint
    let title: String
}

// MARK: - 画图逻辑/计算等
class KLineDrawViewModel {
    // 图表配置
    let config: KLineConfig
    init(config: KLineConfig) {
        self.config = config
    }

    // 画图View
    weak var chartView: KLineChartView? {
        didSet {
            calculateRect()
        }
    }
    // 数据源
    weak var dataSource: KLineChartViewDataSource3?
    
    // 数据
    var dataList: [CandleStickData] = []
    // X轴坐标点
    var xAxisTitles: [KLineXAxisTitleModel] = []
    // K线图Rect
    var kLineChartRect: CGRect = .zero
    
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
    
    // 缩放倍数
    var scale: CGFloat = 1.0
    // 偏移量
    var offsetX: CGFloat = 0
    // 最后一次偏移量
    var lastOffsetX: CGFloat = 0
    
    // 平移拖拽手势开始时的位置
    var panStartX: CGFloat = 0
    // 是否正在平移
    var isDragging = false
    // 是否正在缩放
    var isPinching = false
    // 最后缩放的倍数
    var lastPinchScale: CGFloat = 1.0
    //
    var zoomCenterIndex: Int?
    
    // 惯性滚动定时器
    var displayLink: CADisplayLink?
    // 惯性速度
    var inertialVelocity: CGFloat = 0
    // 惯性减速系数
    let inertialDeceleration: CGFloat = 0.95
    
    // 单条数据宽度
    var itemWidth: CGFloat {
        return config.kLineWidth * scale + config.kLineSpacing
    }
    
    // 全部K线总宽度
    var totalWidth: CGFloat {
        return CGFloat(dataList.count) * itemWidth
    }
    
    // 最小偏移量
    var minOffsetX: CGFloat {
        return -(totalWidth - kLineChartRect.width)
    }
    
    func calculateRect() {
        guard let chartView = chartView else {
            kLineChartRect = .zero
            return
        }
        
        let height = (chartView.bounds.height - config.margin.horizontal) - (config.showVolume ? (config.volumeHeight + config.volumeTopMargin) : 0)
        let width = chartView.bounds.width - config.margin.vertical
        kLineChartRect = CGRect(x: config.margin.left,
                                y: config.margin.right,
                                width: width,
                                height: height)
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

// MARK: - 数据源
extension KLineDrawViewModel {
    public func loadData() {
        guard let dataSource = dataSource else { return }
        dataSource.loadHistoricalData(lineType: config.kLineType,
                                      before: dataList.last?.date ?? Date(),
                                      count: dataList.count > 0 ? 100 : 1000)
        { [weak self] dataList in
            guard let weakSelf = self else { return }
            
            let dataList_ = dataList.sorted { $0.timestamp < $1.timestamp }
            weakSelf.dataList.insert(contentsOf: dataList_, at: 0)
                        
            weakSelf.calculateVisible()
            weakSelf.chartView?.setNeedsDisplay()
        }
    }
}

extension KLineDrawViewModel {
    // 数据处理
    func calculateVisible()
    {
        let totalWidthPerKline = config.kLineWidth * scale + config.kLineSpacing
        
        // 计算可见K线数量
        visibleCount = min(Int(kLineChartRect.width / totalWidthPerKline), dataList.count)
        
        // 回调K线图Rect
        let width = totalWidthPerKline * CGFloat(visibleCount)
        kLineChartRect = CGRectMake(kLineChartRect.minX - (width - kLineChartRect.width),
                                    kLineChartRect.minY,
                                    width,
                                    kLineChartRect.height)
        
        // 计算起始索引
        let totalKLinesWidth = CGFloat(dataList.count) * totalWidthPerKline
        if totalKLinesWidth <= kLineChartRect.width {
            visibleStartIndex = 0
        } else {
            let offsetCount = visibleCount - Int(floor(offsetX / totalWidthPerKline))
            visibleStartIndex = max(0, dataList.count - offsetCount)
        }
        
        let endIndex = min(visibleStartIndex + visibleCount, dataList.count-1)
        let visibleData = Array(dataList[max(visibleStartIndex, 0)..<endIndex])
        
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
        switch config.kLineType {
        case .realTtime:
            xAxisTitles = []
            
        case .fiveDay:
            xAxisTitles = []
            
        case .dayK:
            var list: [KLineXAxisTitleModel] = []
            let endIndex = min((visibleStartIndex + visibleCount), dataList.count-1)
            let subDataList = dataList[visibleStartIndex...endIndex]
            
            var next: CandleStickData? = nil
            for (index, data) in subDataList.enumerated() {
                if let next = next {
                    if next.date_yyyymm != data.date_yyyymm {
                        let x = CGFloat(index) * (config.kLineWidth + config.kLineSpacing)
                        list.append(KLineXAxisTitleModel(point: CGPointMake(x, 0), title: data.date_yyyymm))
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
