//
//  KLineChartView.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/9.
//

import UIKit
import CoreGraphics

// MARK: - 数据源协议
protocol KLineChartViewDataSource: AnyObject {
    func loadHistoricalData(before date: Date, count: Int, completion: @escaping ([KLineData]) -> Void)
    func loadRecentData(after date: Date, count: Int, completion: @escaping ([KLineData]) -> Void)
}

// MARK: - 状态枚举
private enum KLineChartViewLoadingState {
    case idle
    case loadingLeft
    case loadingRight
}

// MARK: - 主K线图类
class KLineChartViewXX: UIView {
    // MARK: - 属性
    private var klineDatas: [KLineData] = []
    private var config = KLineConfiguration()
    private weak var dataSource: KLineChartViewDataSource?
    
    // 可见范围计算
    private var visiblePriceMax: CGFloat = 0
    private var visiblePriceMin: CGFloat = 0
    private var visibleVolumeMax: CGFloat = 0
    
    // 视图状态
    private var visibleStartIndex: Int = 0
    private var visibleCount: Int = 0
    private var klineWidth: CGFloat = 8
    private var scale: CGFloat = 1.0
    private var offsetX: CGFloat = 0
    private var lastOffsetX: CGFloat = 0
    
    // 手势状态
    private var panStartX: CGFloat = 0
    private var isDragging = false
    private var isPinching = false
    private var lastPinchScale: CGFloat = 1.0
    private var zoomCenterIndex: Int?
    
    // 无限滚动状态
    private var loadingState: KLineChartViewLoadingState = .idle
    private var hasMoreLeftData = true
    private var hasMoreRightData = true
    private let pageSize = 50
    
    // 十字线
    private var showCrosshair = false
    private var crosshairPoint: CGPoint?
    private var selectedIndex: Int?
    
    // 惯性滚动
    private var displayLink: CADisplayLink?
    private var inertialVelocity: CGFloat = 0
    private let inertialDeceleration: CGFloat = 0.96
    
    // 缓存
    private var maCache: [Int: [CGFloat]] = [:]
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = config.backgroundColor
        klineWidth = config.defaultKLineWidth
        
        setupPanGestures()
        setupPinchGestures()
        setupLongPressGestures()
        setupTapGestures()
    }
    
    // MARK: - 公开接口
    public func setDataSource(_ dataSource: KLineChartViewDataSource) {
        self.dataSource = dataSource
    }
    
    public func setKLineData(_ data: [KLineData]) {
        self.klineDatas = data.sorted { $0.timestamp < $1.timestamp }
        calculateMA()
        resetView()
    }
    
    public func updateConfig(_ config: KLineConfiguration) {
        self.config = config
        backgroundColor = config.backgroundColor
        setNeedsDisplay()
    }
    
    // MARK: - 绘图方法
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 清空背景
        context.setFillColor(config.backgroundColor.cgColor)
        context.fill(rect)
        
        // 绘制网格
        if config.showGrid {
            drawGrid(in: context)
        }
        
        // 绘制成交量
        if config.showVolume {
            drawVolume(in: context)
        }
        
        // 绘制K线
        drawKlines(in: context)
        
        // 绘制MA指标
        if config.showMA {
            drawMA(in: context)
        }
        
        // 绘制加载效果
        drawLoadingEffects(in: context)
        
        // 绘制十字线
        if showCrosshair {
            drawCrosshair(in: context)
        }
    }
    
    private func drawKlines(in context: CGContext) {
        guard visibleCount > 0 else {
            drawEmptyState(in: context)
            return
        }
        
        let chartRect = getChartRect()
        let priceRange = visiblePriceMax - visiblePriceMin
        
        // 确保价格范围有效
        guard priceRange > 0 else {
            // 尝试重新计算价格范围
            recalculateVisibleExtremes()
            let newRange = visiblePriceMax - visiblePriceMin
            guard newRange > 0 else {
                drawPriceError(in: context)
                return
            }
            // 使用重新计算的范围
            return drawKlines(in: context) // 递归调用
        }
        
        let endIndex = min(visibleStartIndex + visibleCount, klineDatas.count)
        
        for i in visibleStartIndex..<endIndex {
            let data = klineDatas[i]
            let x = getXPosition(for: i)
            
            // 安全的价格转换函数
            func priceToY(_ price: CGFloat) -> CGFloat {
                // 确保除数不为0
                if priceRange <= 0 {
                    return chartRect.midY
                }
                
                let normalizedPrice = (price - visiblePriceMin) / priceRange
                // 确保规范化后的价格在合理范围内
                let clampedNormalizedPrice = min(max(normalizedPrice, 0), 1)
                
                return chartRect.maxY - clampedNormalizedPrice * chartRect.height
            }
            
            let openY = priceToY(data.open)
            let closeY = priceToY(data.close)
            let highY = priceToY(data.high)
            let lowY = priceToY(data.low)
            
            // 确保Y坐标在绘图区域内
            let clampedOpenY = min(max(openY, chartRect.minY), chartRect.maxY)
            let clampedCloseY = min(max(closeY, chartRect.minY), chartRect.maxY)
            let clampedHighY = min(max(highY, chartRect.minY), chartRect.maxY)
            let clampedLowY = min(max(lowY, chartRect.minY), chartRect.maxY)
            
            let color = data.isUp ? config.upColor : config.downColor
            
            // 绘制上下影线
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(1)
            
            let bodyTop = min(clampedOpenY, clampedCloseY)
            let bodyBottom = max(clampedOpenY, clampedCloseY)
            
            // 上影线
            if clampedHighY < bodyTop {
                context.move(to: CGPoint(x: x + klineWidth/2, y: clampedHighY))
                context.addLine(to: CGPoint(x: x + klineWidth/2, y: bodyTop))
            }
            
            // 下影线
            if clampedLowY > bodyBottom {
                context.move(to: CGPoint(x: x + klineWidth/2, y: bodyBottom))
                context.addLine(to: CGPoint(x: x + klineWidth/2, y: clampedLowY))
            }
            
            context.strokePath()
            
            // 绘制实体
            let bodyHeight = abs(clampedCloseY - clampedOpenY)
            if bodyHeight > 0 {
                let bodyRect = CGRect(x: x,
                                    y: min(clampedOpenY, clampedCloseY),
                                    width: klineWidth,
                                    height: bodyHeight)
                
                context.setFillColor(color.cgColor)
                context.fill(bodyRect)
                
                // 阴线空心效果
                if !data.isUp {
                    context.setStrokeColor(config.backgroundColor.cgColor)
                    context.setLineWidth(1)
                    context.stroke(bodyRect.insetBy(dx: 1, dy: 0))
                }
            } else {
                // 十字线
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(klineWidth)
                let centerY = clampedOpenY
                context.move(to: CGPoint(x: x + klineWidth/2, y: centerY - 0.5))
                context.addLine(to: CGPoint(x: x + klineWidth/2, y: centerY + 0.5))
                context.strokePath()
            }
        }
    }

    // 添加错误状态绘制
    private func drawEmptyState(in context: CGContext) {
        let chartRect = getChartRect()
        let message = "暂无K线数据"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.gray
        ]
        let textSize = message.size(withAttributes: attributes)
        message.draw(at: CGPoint(x: chartRect.midX - textSize.width/2,
                               y: chartRect.midY - textSize.height/2),
                    withAttributes: attributes)
    }

    private func drawPriceError(in context: CGContext) {
        let chartRect = getChartRect()
        let message = "价格数据异常"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.red
        ]
        let textSize = message.size(withAttributes: attributes)
        message.draw(at: CGPoint(x: chartRect.midX - textSize.width/2,
                               y: chartRect.midY - textSize.height/2),
                    withAttributes: attributes)
    }

    // 添加重新计算价格范围的方法
    private func recalculateVisibleExtremes() {
        guard !klineDatas.isEmpty else {
            visiblePriceMax = 100
            visiblePriceMin = 0
            return
        }
        
        // 使用所有数据重新计算价格范围
        visiblePriceMax = klineDatas.first!.high
        visiblePriceMin = klineDatas.first!.low
        
        for data in klineDatas {
            visiblePriceMax = max(visiblePriceMax, data.high)
            visiblePriceMin = min(visiblePriceMin, data.low)
        }
        
        ensureValidPriceRange()
    }
    
    private func drawVolume(in context: CGContext) {
        guard visibleCount > 0 && visibleVolumeMax > 0 else { return }
        
        let volumeRect = getVolumeRect()
        let endIndex = min(visibleStartIndex + visibleCount, klineDatas.count)
        
        for i in visibleStartIndex..<endIndex {
            let data = klineDatas[i]
            let x = getXPosition(for: i)
            
            let volumeHeight = data.volume / visibleVolumeMax * volumeRect.height
            let volumeY = volumeRect.maxY - volumeHeight
            
            let color = data.isUp ? config.upColor : config.downColor
            
            context.setFillColor(color.withAlphaComponent(0.7).cgColor)
            context.fill(CGRect(x: x,
                                y: volumeY,
                                width: klineWidth,
                                height: volumeHeight))
        }
    }
    
    private func drawMA(in context: CGContext) {
        guard !klineDatas.isEmpty && visibleCount > 0 else { return }
        
        let chartRect = getChartRect()
        let priceRange = visiblePriceMax - visiblePriceMin
        guard priceRange > 0 else { return }
        
        for (idx, period) in config.maPeriods.enumerated() {
            guard let maValues = maCache[period] else { continue }
            
            let color = config.maColors[idx % config.maColors.count]
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(1.5)
            
            var firstPoint = true
            let endIndex = min(visibleStartIndex + visibleCount, klineDatas.count)
            
            for i in visibleStartIndex..<endIndex {
                let maValue = maValues[i]
                guard maValue > 0 else { continue }
                
                let x = getXPosition(for: i) + klineWidth/2
                let y = chartRect.maxY - (maValue - visiblePriceMin) / priceRange * chartRect.height
                
                if firstPoint {
                    context.move(to: CGPoint(x: x, y: y))
                    firstPoint = false
                } else {
                    context.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            context.strokePath()
        }
    }
    
    private func drawLoadingEffects(in context: CGContext) {
        let chartRect = getChartRect()
        
        // 绘制左边界加载效果
        if loadingState == .loadingLeft && offsetX < 0 {
            let effectRect = CGRect(x: chartRect.origin.x - 20,
                                    y: chartRect.origin.y,
                                    width: 20,
                                    height: chartRect.height)
            
            drawLoadingGradient(in: context, rect: effectRect, direction: .loadingLeft)
            
            // 绘制加载文字
            let loadingText = "加载中..."
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: config.loadingColor
            ]
            
            let textSize = loadingText.size(withAttributes: attributes)
            loadingText.draw(at: CGPoint(x: chartRect.origin.x - textSize.width - 25,
                                         y: chartRect.midY - textSize.height/2),
                             withAttributes: attributes)
        }
        
        // 绘制右边界加载效果
        if loadingState == .loadingRight {
            let chartWidth = getChartRect().width
            let totalWidth = CGFloat(klineDatas.count) * (klineWidth + config.klineSpacing)
            let maxOffset = max(0, totalWidth - chartWidth)
            
            if offsetX > maxOffset {
                let effectRect = CGRect(x: chartRect.maxX,
                                        y: chartRect.origin.y,
                                        width: 20,
                                        height: chartRect.height)
                
                drawLoadingGradient(in: context, rect: effectRect, direction: .loadingRight)
                
                // 绘制加载文字
                let loadingText = "加载中..."
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: config.loadingColor
                ]
                
                let textSize = loadingText.size(withAttributes: attributes)
                loadingText.draw(at: CGPoint(x: chartRect.maxX + 25,
                                             y: chartRect.midY - textSize.height/2),
                                 withAttributes: attributes)
            }
        }
    }
    
    private func drawLoadingGradient(in context: CGContext, rect: CGRect, direction: KLineChartViewLoadingState) {
        // 创建渐变
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors: [CGColor] = [
            config.loadingColor.withAlphaComponent(0.2).cgColor,
            config.loadingColor.withAlphaComponent(0.0).cgColor
        ]
        
        let locations: [CGFloat] = direction == .loadingLeft ? [0.0, 1.0] : [1.0, 0.0]
        
        if let gradient = CGGradient(colorsSpace: colorSpace,
                                     colors: colors as CFArray,
                                     locations: locations) {
            let startPoint = direction == .loadingLeft ?
            CGPoint(x: rect.minX, y: rect.midY) :
            CGPoint(x: rect.maxX, y: rect.midY)
            let endPoint = direction == .loadingLeft ?
            CGPoint(x: rect.maxX, y: rect.midY) :
            CGPoint(x: rect.minX, y: rect.midY)
            
            context.saveGState()
            context.addRect(rect)
            context.clip()
            context.drawLinearGradient(gradient,
                                       start: startPoint,
                                       end: endPoint,
                                       options: [])
            context.restoreGState()
        }
    }
    
    private func drawCrosshair(in context: CGContext) {
        guard let point = crosshairPoint,
              let index = selectedIndex,
              index < klineDatas.count else {
            return
        }
        
        let chartRect = getChartRect()
        let data = klineDatas[index]
        
        // 绘制十字线
        context.setStrokeColor(config.crosshairColor.cgColor)
        context.setLineWidth(0.5)
        
        // 垂直线
        context.move(to: CGPoint(x: point.x, y: chartRect.origin.y))
        context.addLine(to: CGPoint(x: point.x, y: chartRect.maxY))
        
        // 水平线
        context.move(to: CGPoint(x: chartRect.origin.x, y: point.y))
        context.addLine(to: CGPoint(x: chartRect.maxX, y: point.y))
        
        context.strokePath()
        
        // 绘制信息框
        let priceRange = visiblePriceMax - visiblePriceMin
        _ = visiblePriceMax - (point.y - chartRect.origin.y) / chartRect.height * priceRange
        
        let infoText = """
        日期: \(data.timestamp)
        开: \(formatPrice(data.open))
        收: \(formatPrice(data.close))
        高: \(formatPrice(data.high))
        低: \(formatPrice(data.low))
        """
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.white
        ]
        
        let textSize = infoText.size(withAttributes: attributes)
        let infoRect = CGRect(x: point.x + 10, y: point.y - textSize.height/2,
                              width: textSize.width + 10, height: textSize.height + 10)
        
        // 背景
        context.setFillColor(UIColor.black.withAlphaComponent(0.7).cgColor)
        context.fill(infoRect)
        
        // 文字
        infoText.draw(in: infoRect.insetBy(dx: 5, dy: 5), withAttributes: attributes)
    }
    
    // MARK: - 辅助方法
    private func getChartRect() -> CGRect {
        let height = config.showVolume ?
        bounds.height - config.topMargin - config.bottomMargin - config.volumeHeight - 10 :
        bounds.height - config.topMargin - config.bottomMargin
        
        return CGRect(x: config.leftMargin,
                      y: config.topMargin,
                      width: bounds.width - config.leftMargin - config.rightMargin,
                      height: height)
    }
    
    private func getVolumeRect() -> CGRect {
        return CGRect(x: config.leftMargin,
                      y: bounds.height - config.bottomMargin - config.volumeHeight,
                      width: bounds.width - config.leftMargin - config.rightMargin,
                      height: config.volumeHeight)
    }
    
    private func getXPosition(for index: Int) -> CGFloat {
        let chartRect = getChartRect()
        let relativeIndex = index - visibleStartIndex
        return chartRect.origin.x + CGFloat(relativeIndex) * (klineWidth + config.klineSpacing)
    }
    
    private func getKlineIndex(at point: CGPoint) -> Int? {
        let chartRect = getChartRect()
        guard chartRect.contains(point) else { return nil }
        
        let xInChart = point.x - chartRect.origin.x
        let relativeIndex = Int(xInChart / (klineWidth + config.klineSpacing))
        let index = visibleStartIndex + relativeIndex
        
        return (index >= 0 && index < klineDatas.count) ? index : nil
    }
    
    private func getSafePinchCenter(for gesture: UIPinchGestureRecognizer) -> CGPoint? {
        guard gesture.numberOfTouches >= 2 else { return nil }
        
        let touchPoint1 = gesture.location(ofTouch: 0, in: self)
        let touchPoint2 = gesture.location(ofTouch: 1, in: self)
        
        return CGPoint(x: (touchPoint1.x + touchPoint2.x) / 2,
                       y: (touchPoint1.y + touchPoint2.y) / 2)
    }
    
    private func performZoom(scaleChange: CGFloat, centerIndex: Int?) {
        guard scaleChange != 1.0 else { return }
        
        let oldKlineWidth = klineWidth
        
        // 更新缩放比例
        var newScale = scale * scaleChange
        newScale = min(max(0.5, newScale), 3.0)
        
        if newScale != scale {
            scale = newScale
            
            // 计算新宽度
            let targetWidth = config.defaultKLineWidth * scale
            klineWidth = min(max(config.minKLineWidth, targetWidth), config.maxKLineWidth)
            
            // 保持中心点位置
            if let centerIndex = centerIndex,
               centerIndex >= 0 && centerIndex < klineDatas.count {
                
                let spacing = config.klineSpacing
                let chartWidth = getChartRect().width
                let totalWidth = CGFloat(klineDatas.count) * (klineWidth + spacing)
                
                // 计算中心点在新旧宽度下的位置
                let oldCenterX = CGFloat(centerIndex) * (oldKlineWidth + spacing)
                let newCenterX = CGFloat(centerIndex) * (klineWidth + spacing)
                
                // 调整偏移量
                offsetX += (newCenterX - oldCenterX)
                
                // 边界检查
                let maxOffset = max(0, totalWidth - chartWidth)
                offsetX = max(0, min(offsetX, maxOffset))
            }
            
            updateVisibleRange()
            setNeedsDisplay()
        }
    }
    
    private func updateVisibleRange() {
        let chartWidth = getChartRect().width
        let totalWidthPerKline = klineWidth + config.klineSpacing
        
        // 计算可见K线数量
        visibleCount = min(Int(chartWidth / totalWidthPerKline), klineDatas.count)
        
        // 计算起始索引
        let totalKlinesWidth = CGFloat(klineDatas.count) * totalWidthPerKline
        if totalKlinesWidth <= chartWidth {
            visibleStartIndex = 0
        } else {
            let startIndexFloat = offsetX / totalWidthPerKline
            visibleStartIndex = max(0, Int(floor(startIndexFloat)))
            visibleStartIndex = min(visibleStartIndex, klineDatas.count - visibleCount)
        }
        
        // 计算可见范围的价格极值
        calculateVisibleExtremes()
    }
    
    private func calculateVisibleExtremes() {
        guard visibleCount > 0 else {
            visiblePriceMax = 0
            visiblePriceMin = 0
            visibleVolumeMax = 0
            return
        }
        
        let endIndex = min(visibleStartIndex + visibleCount, klineDatas.count)
        let visibleData = Array(klineDatas[visibleStartIndex..<endIndex])
        
        guard let first = visibleData.first else {
            visiblePriceMax = 0
            visiblePriceMin = 0
            visibleVolumeMax = 0
            return
        }
        
        // 修复：这里应该用 first.high 初始化 visiblePriceMax，不是 first.low
        visiblePriceMax = first.high  // ✅ 修复：改为 first.high
        visiblePriceMin = first.low
        visibleVolumeMax = first.volume
        
        for data in visibleData {
            visiblePriceMax = max(visiblePriceMax, data.high)
            visiblePriceMin = min(visiblePriceMin, data.low)
            visibleVolumeMax = max(visibleVolumeMax, data.volume)
        }
        
        // 添加边界安全检查
        ensureValidPriceRange()
        
        if visibleVolumeMax > 0 {
            visibleVolumeMax *= 1.1
        }
    }

    // 新增：确保价格范围有效的辅助方法
    private func ensureValidPriceRange() {
        // 如果价格范围无效，进行修正
        if visiblePriceMax <= visiblePriceMin {
            // 如果两个值都是0，设置一个默认范围
            if visiblePriceMax == 0 && visiblePriceMin == 0 {
                visiblePriceMax = 100
                visiblePriceMin = 0
            } else if visiblePriceMax == visiblePriceMin {
                // 如果价格相同，创建一个小的价格范围
                let basePrice = visiblePriceMax
                visiblePriceMax = basePrice * 1.001
                visiblePriceMin = basePrice * 0.999
            } else {
                // 如果最大值小于最小值，交换它们
                let temp = visiblePriceMax
                visiblePriceMax = visiblePriceMin
                visiblePriceMin = temp
            }
        }
        
        // 确保价格范围有足够的间距
        let priceRange = visiblePriceMax - visiblePriceMin
        if priceRange <= 0 {
            // 如果价格范围仍然是0或负数，设置一个合理的范围
            let midPrice = (visiblePriceMax + visiblePriceMin) / 2
            visiblePriceMax = midPrice + 1
            visiblePriceMin = midPrice - 1
        }
        
        // 添加边距
        let finalRange = visiblePriceMax - visiblePriceMin
        if finalRange > 0 {
            visiblePriceMax += finalRange * 0.05
            visiblePriceMin -= finalRange * 0.05
            
            // 确保最低价格不为负（如果是股票价格）
            visiblePriceMin = max(0, visiblePriceMin)
        }
    }
    
    private func calculateMA() {
        guard !klineDatas.isEmpty else { return }
        
        for period in config.maPeriods {
            var maValues: [CGFloat] = []
            
            for i in 0..<klineDatas.count {
                if i < period - 1 {
                    maValues.append(0)
                } else {
                    var sum: CGFloat = 0
                    for j in 0..<period {
                        sum += klineDatas[i - j].close
                    }
                    maValues.append(sum / CGFloat(period))
                }
            }
            
            maCache[period] = maValues
        }
    }
    
    public func resetView() {
        scale = 1.0
        klineWidth = config.defaultKLineWidth
        offsetX = 0
        updateVisibleRange()
        setNeedsDisplay()
    }
    
    private func hideCrosshair() {
        showCrosshair = false
        crosshairPoint = nil
        selectedIndex = nil
        setNeedsDisplay()
    }
    
    private func formatPrice(_ price: CGFloat) -> String {
        if price >= 100 {
            return String(format: "%.2f", price)
        } else if price >= 10 {
            return String(format: "%.3f", price)
        } else {
            return String(format: "%.4f", price)
        }
    }
}

// MARK: - 绘制虚线网格
extension KLineChartViewXX {
    private func drawGrid(in context: CGContext) {
        let chartRect = getChartRect()
        
        // 设置虚线样式
        context.setStrokeColor(config.gridColor.withAlphaComponent(0.1).cgColor)
        context.setLineWidth(0.5)
        
        // 定义虚线模式：绘制2点，跳过2点
        let dashPattern: [CGFloat] = [2, 2]
        context.setLineDash(phase: 0, lengths: dashPattern)
        
        // 水平虚线网格线
        let horizontalLines = 5
        for i in 0...horizontalLines {
            let y = chartRect.origin.y + CGFloat(i) * chartRect.height / CGFloat(horizontalLines)
            
            // 虚线
            context.move(to: CGPoint(x: chartRect.origin.x, y: y))
            context.addLine(to: CGPoint(x: chartRect.maxX, y: y))
            context.strokePath() // 每条线单独绘制，以便保持虚线样式
            
            // 价格标签
            let price = visiblePriceMax - CGFloat(i) * (visiblePriceMax - visiblePriceMin) / CGFloat(horizontalLines)
            let priceText = formatPrice(price)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular),
                .foregroundColor: config.textColor
            ]
            
            let textSize = priceText.size(withAttributes: attributes)
            priceText.draw(at: CGPoint(x: chartRect.origin.x - textSize.width - 5,
                                     y: y - textSize.height/2),
                         withAttributes: attributes)
        }
        
        // 重置虚线设置，为垂直线做准备
        context.setLineDash(phase: 0, lengths: [])
        
        // 垂直网格线（如果需要也改为虚线，取消下面注释）
         context.setLineDash(phase: 0, lengths: dashPattern)
        
        // 垂直线（日期线）
        guard visibleCount > 0 else { return }
        
        let dateLines = min(3, visibleCount)
        let step = max(1, visibleCount / dateLines)
        
        for i in 0..<dateLines {
            let dataIndex = visibleStartIndex + i * step
            if dataIndex < klineDatas.count {
                let x = getXPosition(for: dataIndex)
                
                context.move(to: CGPoint(x: x, y: chartRect.origin.y))
                context.addLine(to: CGPoint(x: x, y: chartRect.maxY))
                context.strokePath() // 每条线单独绘制
                
                // 日期标签
                if config.showDateLabel {
                    let dateText = String(klineDatas[dataIndex].timestamp)
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 10),
                        .foregroundColor: config.textColor
                    ]
                    
                    let textSize = dateText.size(withAttributes: attributes)
                    dateText.draw(at: CGPoint(x: x - textSize.width/2,
                                            y: chartRect.maxY + 5),
                                withAttributes: attributes)
                }
            }
        }
        
        // 重置虚线设置，为垂直线做准备
        context.setLineDash(phase: 0, lengths: [])
    }
}

// MARK: 拖拽手势
extension KLineChartViewXX {
    private func setupPanGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        // 如果正在捏合，则不处理拖拽
        if isPinching {
            return
        }
        
        // 停止惯性动画
        stopInertialScroll()
        
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            isDragging = true
            panStartX = translation.x
            lastOffsetX = offsetX
            
        case .changed:
            let deltaX = translation.x - panStartX
            
            // 允许超出边界拖拽
            let totalWidth = CGFloat(klineDatas.count) * (klineWidth + config.klineSpacing)
            let chartWidth = getChartRect().width
            
            offsetX = lastOffsetX - deltaX
            
            // 检查是否需要加载数据
            checkBoundaryAndLoadData(chartWidth: chartWidth, totalWidth: totalWidth)
            
            updateVisibleRange()
            setNeedsDisplay()
            
        case .ended:
            isDragging = false
            
            // 计算惯性速度
            let velocity = gesture.velocity(in: self).x
            if abs(velocity) > 50 {
                startInertialScroll(velocity: velocity)
            } else {
                // 如果没有惯性，检查是否需要回弹
                checkAndSnapBack()
            }
            
        case .cancelled, .failed:
            isDragging = false
            checkAndSnapBack()
            
        default:
            break
        }
    }
    
    // MARK: - 无限滚动核心逻辑
    private func checkBoundaryAndLoadData(chartWidth: CGFloat, totalWidth: CGFloat) {
        let maxOffset = max(0, totalWidth - chartWidth)
        
        // 检查左边界
        if offsetX < -config.loadingThreshold && loadingState == .idle && hasMoreLeftData {
            loadMoreData(in: .loadingLeft)
        }
        
        // 检查右边界
        if offsetX > maxOffset + config.loadingThreshold && loadingState == .idle && hasMoreRightData {
            loadMoreData(in: .loadingRight)
        }
    }
    private func checkAndSnapBack() {
        let chartWidth = getChartRect().width
        let totalWidth = CGFloat(klineDatas.count) * (klineWidth + config.klineSpacing)
        let maxOffset = max(0, totalWidth - chartWidth)
        
        // 如果没有在加载数据，则回弹到边界内
        if loadingState == .idle {
            if offsetX < 0 {
                offsetX = 0
            } else if offsetX > maxOffset {
                offsetX = maxOffset
            }
            updateVisibleRange()
            setNeedsDisplay()
        }
    }
    
    private func loadMoreData(in direction: KLineChartViewLoadingState) {
        guard let dataSource = dataSource, loadingState == .idle else { return }
        
        loadingState = direction
        
        // 获取最早或最晚的数据时间
        guard let targetDate = getTargetDate(for: direction) else {
            loadingState = .idle
            return
        }
        
        // 定义完成处理
        let handleCompletion = { [weak self] (newData: [KLineData]) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // 在这里根据返回的数据量判断是否还有更多数据
                if direction == .loadingLeft {
                    self.hasMoreLeftData = newData.count >= self.pageSize
                } else {
                    self.hasMoreRightData = newData.count >= self.pageSize
                }
                
                self.handleLoadedData(newData, direction: direction)
            }
        }
        
        if direction == .loadingLeft {
            dataSource.loadHistoricalData(before: targetDate,
                                          count: pageSize,
                                          completion: handleCompletion)
        } else {
            dataSource.loadRecentData(after: targetDate,
                                      count: pageSize,
                                      completion: handleCompletion)
        }
        
        setNeedsDisplay()
    }
    
    private func getTargetDate(for direction: KLineChartViewLoadingState) -> Date? {
        guard !klineDatas.isEmpty else { return nil }
        
        if direction == .loadingLeft {
            // 获取最早的数据日期
            let earliestData = klineDatas.first!
            return Date(timeIntervalSince1970: earliestData.timestamp - 1)
        } else {
            // 获取最新的数据日期
            let latestData = klineDatas.last!
            return Date(timeIntervalSince1970: latestData.timestamp + 1)
        }
    }
    
    private func handleLoadedData(_ newData: [KLineData], direction: KLineChartViewLoadingState) {
        guard !newData.isEmpty else {
            // 没有更多数据
            if direction == .loadingLeft {
                hasMoreLeftData = false
            } else {
                hasMoreRightData = false
            }
            loadingState = .idle
            checkAndSnapBack()
            return
        }
        
        // 根据方向合并数据
        let oldCount = klineDatas.count
        let oldOffsetX = offsetX
        let chartWidth = getChartRect().width
        
        if direction == .loadingLeft {
            // 在开头插入数据
            klineDatas = newData.reversed() + klineDatas
            
            // 调整offsetX以保持视觉位置
            let addedWidth = CGFloat(newData.count) * (klineWidth + config.klineSpacing)
            offsetX = oldOffsetX + addedWidth
            
        } else {
            // 在末尾追加数据
            klineDatas += newData
            
            // offsetX保持不变
        }
        
        // 计算技术指标
        calculateMA()
        
        // 加载完成，回弹到正常位置
        loadingState = .idle
        
        // 如果是从左边界加载的，需要平滑过渡
        if direction == .loadingLeft {
            animateLeftBoundaryTransition(oldOffsetX: oldOffsetX,
                                          oldCount: oldCount,
                                          newCount: klineDatas.count,
                                          chartWidth: chartWidth)
        } else {
            checkAndSnapBack()
        }
        
        updateVisibleRange()
        setNeedsDisplay()
    }
    
    private func animateLeftBoundaryTransition(oldOffsetX: CGFloat,
                                               oldCount: Int,
                                               newCount: Int,
                                               chartWidth: CGFloat) {
        _ = CGFloat(newCount) * (klineWidth + config.klineSpacing)
        
        // 计算目标位置（显示新加载的数据）
        let targetOffset: CGFloat = 0
        
        // 使用动画平滑过渡
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.offsetX = targetOffset
            self.updateVisibleRange()
            self.setNeedsDisplay()
        })
    }
    
    // MARK: - 惯性滚动
    private func startInertialScroll(velocity: CGFloat) {
        inertialVelocity = velocity * 0.3
        
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(updateInertialScroll))
            displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    private func stopInertialScroll() {
        displayLink?.invalidate()
        displayLink = nil
        inertialVelocity = 0
    }
    
    @objc private func updateInertialScroll() {
        guard abs(inertialVelocity) > 0.1 else {
            stopInertialScroll()
            checkAndSnapBack()
            return
        }
        
        // 应用减速
        inertialVelocity *= inertialDeceleration
        
        // 获取边界信息
        let chartWidth = getChartRect().width
        let totalWidth = CGFloat(klineDatas.count) * (klineWidth + config.klineSpacing)
        let maxOffset = max(0, totalWidth - chartWidth)
        
        // 计算新位置
        let deltaX = inertialVelocity * 0.016
        var newOffsetX = offsetX - deltaX
        
        // 检查边界和加载
        var shouldStop = false
        
        if newOffsetX < -config.loadingThreshold && loadingState == .idle && hasMoreLeftData {
            // 触发左边界加载
            loadMoreData(in: .loadingLeft)
            shouldStop = true
        } else if newOffsetX > maxOffset + config.loadingThreshold && loadingState == .idle && hasMoreRightData {
            // 触发右边界加载
            loadMoreData(in: .loadingRight)
            shouldStop = true
        } else if newOffsetX < 0 {
            // 左边界阻尼
            newOffsetX = 0
            inertialVelocity *= 0.3
            shouldStop = abs(inertialVelocity) < 1
        } else if newOffsetX > maxOffset {
            // 右边界阻尼
            newOffsetX = maxOffset
            inertialVelocity *= 0.3
            shouldStop = abs(inertialVelocity) < 1
        }
        
        // 更新位置
        offsetX = newOffsetX
        
        if shouldStop {
            stopInertialScroll()
            checkAndSnapBack()
        }
        
        updateVisibleRange()
        setNeedsDisplay()
    }
}

// MARK: 捏合手势
extension KLineChartViewXX {
    private func setupPinchGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPinching = true
            lastPinchScale = gesture.scale
            zoomCenterIndex = nil
            
            // 停止惯性动画
            stopInertialScroll()
            
            // 安全获取缩放中心
            if gesture.numberOfTouches >= 2 {
                if let centerPoint = getSafePinchCenter(for: gesture) {
                    zoomCenterIndex = getKlineIndex(at: centerPoint)
                }
            }
            
        case .changed:
            // 安全检查触摸点数量
            guard gesture.numberOfTouches >= 2 else {
                return
            }
            
            let scaleChange = gesture.scale / lastPinchScale
            lastPinchScale = gesture.scale
            
            // 获取当前缩放中心
            let currentCenterIndex: Int?
            if let centerPoint = getSafePinchCenter(for: gesture) {
                currentCenterIndex = getKlineIndex(at: centerPoint)
            } else {
                currentCenterIndex = nil
            }
            
            // 使用当前中心点或缓存的上一个中心点
            let centerIndex = currentCenterIndex ?? zoomCenterIndex
            
            // 执行缩放
            performZoom(scaleChange: scaleChange, centerIndex: centerIndex)
            
        case .ended, .cancelled, .failed:
            isPinching = false
            zoomCenterIndex = nil
            lastPinchScale = 1.0
            
            // 边界检查
            let chartWidth = getChartRect().width
            let totalWidth = CGFloat(klineDatas.count) * (klineWidth + config.klineSpacing)
            
            if totalWidth < chartWidth {
                offsetX = 0
            } else {
                offsetX = min(offsetX, totalWidth - chartWidth)
            }
            
            updateVisibleRange()
            setNeedsDisplay()
            
        default:
            break
        }
    }
}

// MARK: - 长按手势
extension KLineChartViewXX {
    private func setupLongPressGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3
        addGestureRecognizer(longPressGesture)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self)
        let chartRect = getChartRect()
        
        switch gesture.state {
        case .began, .changed:
            guard chartRect.contains(point) else {
                hideCrosshair()
                return
            }
            
            showCrosshair = true
            crosshairPoint = point
            
            // 计算选中的K线
            let xInChart = point.x - chartRect.origin.x
            let relativeIndex = Int(xInChart / (klineWidth + config.klineSpacing))
            selectedIndex = min(visibleStartIndex + relativeIndex, klineDatas.count - 1)
            
            setNeedsDisplay()
            
        case .ended, .cancelled:
            hideCrosshair()
            
        default:
            break
        }
    }
}

// MARK: 点击手势
extension KLineChartViewXX {
    private func setupTapGestures() {
        // 双击手势
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
        
        // 单击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.require(toFail: doubleTapGesture)
        addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        hideCrosshair()
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        resetView()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension KLineChartViewXX: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        // 允许拖拽和捏合同时识别
        let isPanAndPinch = (gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) ||
        (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer)
        
        return isPanAndPinch
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            return panGesture.numberOfTouches <= 1
        }
        return true
    }
}
