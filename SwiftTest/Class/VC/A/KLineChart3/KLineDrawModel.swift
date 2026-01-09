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
    // 可见K线起始位置
    var visibleStartIndex: Int = 0
    // 可见K线数量
    var visibleCount: Int = 0
    // 可见最高价
    var visiblePriceMax: CGFloat = 0
    // 可见最低价
    var visiblePriceMin: CGFloat = 0
    // 可见数据容量
    var visibleVolumeMax: CGFloat = 0
    
    // X轴坐标点
    var xAxisTitles: [KLineXAxisTitleModel] = []
    // K线图Rect
    var kLineChartRect: CGRect = .zero
    // 成交量Rect
    var volumeChartRect: CGRect = .zero
    
    // 缩放倍数
    var scale: CGFloat = 1.0
    // 偏移量
    var offsetX: CGFloat = 0 {
        didSet {
            printLog("offsetX: \(offsetX)")
        }
    }
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
    // 缩放中心K线
    var zoomCenterIndex: Int?
    // 缩放中心K线X坐标点
    var zoomCenterX: CGFloat?
    
    // 惯性滚动定时器
    var displayLink: CADisplayLink?
    // 惯性速度
    var inertialVelocity: CGFloat = 0
    // 惯性减速系数
    let inertialDeceleration: CGFloat = 0.95
    // 惯性减速比例
    let inertialDecelerationRatio: CGFloat = 0.016
    // 惯性起始偏移量
    var inertialStartOffsetX: CGFloat = 0
    
    // 单条K线宽度
    var kLineWidth: CGFloat = 0
    
    // 单条数据宽度
    var itemWidth: CGFloat {
        return kLineWidth + config.kLineSpacing
    }
    
    // 全部K线总宽度
    var totalWidth: CGFloat {
        return CGFloat(dataList.count) * itemWidth
    }
    
    // 最小偏移量
    var minOffsetX: CGFloat {
        return -(totalWidth - kLineChartRect.width)
    }
    
    // 可见K线数组
    var visibleData: [CandleStickData] {
        return dataList.subArray(from: visibleStartIndex, count: visibleCount)
    }
    
    func calculateRect()
    {
        guard let chartView = chartView else { kLineChartRect = .zero; return }
        
        let height = (chartView.bounds.height - config.margin.horizontal) - (config.showVolume ? (config.volumeHeight + config.volumeTopMargin) : 0)
        let width = chartView.bounds.width - config.margin.vertical
        kLineChartRect = CGRect(x: config.margin.left,
                                y: config.margin.top,
                                width: width,
                                height: height)
        
        volumeChartRect = CGRect(x: config.margin.left,
                                 y: kLineChartRect.maxY + config.volumeTopMargin,
                                 width:width,
                                 height: config.volumeHeight)
    }
    
    func formatPrice(_ price: CGFloat) -> String
    {
        if price >= 100 {
            return String(format: "%.2f", price)
        } else if price >= 10 {
            return String(format: "%.3f", price)
        } else {
            return String(format: "%.4f", price)
        }
    }
    
    func calculateKLineWidth(totalWidth: CGFloat,
                             itemWidth: CGFloat,
                             spacing: CGFloat) -> (Int, CGFloat)
    {
        let roughCount = totalWidth / (itemWidth + spacing)
        
        let lowerCount = max(1, Int(floor(roughCount)))
        let upperCount = Int(ceil(roughCount))
        
        func calculateWidth(for count: Int) -> CGFloat {
            return (totalWidth - CGFloat(count - 1) * spacing) / CGFloat(count)
        }
        
        let lowerWidth = calculateWidth(for: lowerCount)
        let upperWidth = calculateWidth(for: upperCount)
        
        if lowerWidth >= itemWidth * 0.8 && upperWidth >= itemWidth * 0.8 {
            let lowerDiff = abs(lowerWidth - itemWidth)
            let upperDiff = abs(upperWidth - itemWidth)
            return lowerDiff <= upperDiff ? (lowerCount, lowerWidth) : (upperCount, upperWidth)
        } else if lowerWidth >= itemWidth * 0.8 {
            return (lowerCount, lowerWidth)
        } else if upperWidth >= itemWidth * 0.8 {
            return (upperCount, upperWidth)
        } else {
            return lowerWidth >= upperWidth ? (lowerCount, lowerWidth) : (upperCount, upperWidth)
        }
    }
}

// MARK: - 数据源
extension KLineDrawViewModel {
    public func loadData()
    {
        guard let dataSource = dataSource else { return }
        dataSource.loadHistoricalData(lineType: config.kLineType,
                                      before: dataList.first?.date ?? Date(),
                                      count: dataList.count > 0 ? 100 : 50)
        { [weak self] dataList in
            guard let weakSelf = self else { return }
            
            let firstLoad: Bool = weakSelf.dataList.isEmpty
            let dataList_ = dataList.sorted { $0.timestamp < $1.timestamp }
            weakSelf.dataList.insert(contentsOf: dataList_, at: 0)
            
            if firstLoad {
                weakSelf.firstLoadDataReloadUI()
            } else {
                weakSelf.visibleStartIndex = weakSelf.visibleStartIndex + dataList_.count
            }
            weakSelf.calculateVisible()
        }
    }
    
    private func firstLoadDataReloadUI() {
        // 计算可见K线数量
        let (visibleCount_, oneKLineWidth) = calculateKLineWidth(totalWidth: kLineChartRect.width,
                                                                 itemWidth: config.kLineWidth * scale,
                                                                 spacing: config.kLineSpacing)
        visibleCount = visibleCount_
        kLineWidth = oneKLineWidth
        
        visibleStartIndex = dataList.count - visibleCount
        calculateVisible()
    }
}

extension KLineDrawViewModel {
    // 数据处理
    func calculateVisible()
    {
        // 计算可见K线数量
        let (visibleCount_, oneKLineWidth) = calculateKLineWidth(totalWidth: kLineChartRect.width,
                                                                 itemWidth: config.kLineWidth * scale,
                                                                 spacing: config.kLineSpacing)
        visibleCount = visibleCount_
        kLineWidth = oneKLineWidth
        
        guard let first = visibleData.first else {
            visiblePriceMax = 0
            visiblePriceMin = 0
            visibleVolumeMax = 0
            return
        }
        
        let extremes = visibleData.reduce((priceMax: first.high,
                                           priceMin: first.low,
                                           volumeMax: first.volume)) { result, data in
            return (max(result.priceMax, data.high),
                    min(result.priceMin, data.low),
                    max(result.volumeMax, data.volume))
        }
        
        visiblePriceMax = extremes.priceMax
        visiblePriceMin = extremes.priceMin
        visibleVolumeMax = extremes.volumeMax
        
        visibleData.forEach { data in
            data.volumeHeight = volumeChartRect.height * data.volume / visibleVolumeMax
        }
        
        // 重绘
        chartView?.setNeedsDisplay()
    }
    
    // 计算X轴日期显示
    func calculateVisibleXAxisTitles() {
        switch config.kLineType {
        case .realTtime:
            xAxisTitles = []
        case .fiveDay:
            xAxisTitles = []
        case .dayK:
            xAxisTitles = []
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
