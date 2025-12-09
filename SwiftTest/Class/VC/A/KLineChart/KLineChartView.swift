//
//  KLineChartView.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/9.
//

import UIKit

class KLineChartView: BaseView {
    // MARK: - 属性
    private var klineDatas: [KLineData] = []
    private var config = KLineConfiguration()
    
    // 可见范围计算
    private var visiblePriceMax: CGFloat = 0
    private var visiblePriceMin: CGFloat = 0
    private var visibleVolumeMax: CGFloat = 0
    
    // 手势状态
    private var visibleStartIndex: Int = 0
    private var visibleCount: Int = 0
    private var klineWidth: CGFloat = 8
    private var scale: CGFloat = 1.0
    private var offsetX: CGFloat = 0
    private var lastOffsetX: CGFloat = 0
    
    // 缩放手势
    private var lastPinchScale: CGFloat = 1.0
    private var zoomCenterIndex: Int?
    private var isPinching = false
    
    // 拖拽手势
    private var panStartX: CGFloat = 0
    private var isDragging = false
    
    // 十字线
    private var showCrosshair = false
    private var crosshairPoint: CGPoint?
    private var selectedIndex: Int?
    
    // 缓存
    private var maCache: [Int: [CGFloat]] = [:]
    private var priceCache: [String: CGFloat] = [:] // 简单缓存
    
    // 惯性动画
    private var displayLink: CADisplayLink?
    private var inertialVelocity: CGFloat = 0
    private var inertialDeceleration: CGFloat = 0.95
    
    // 绘图层
    private let gridLayer = CAShapeLayer()
    private let klineLayer = CAShapeLayer()
    private let volumeLayer = CAShapeLayer()
    private let maLayer = CAShapeLayer()
    private let crosshairLayer = CAShapeLayer()
    private let infoLayer = CATextLayer()
    
    // MARK: - 初始化
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit()
    {
        backgroundColor = config.backgroundColor
        klineWidth = config.defaultKLineWidth
        
        setupLayers()
        
        // 手势
        setupPanGestures()
        setupPinchGestures()
        setupLongGestures()
        setupTapGestures()
    }
    
    private func setupLayers()
    {
        // 网格层
        gridLayer.frame = bounds
        gridLayer.fillColor = nil
        gridLayer.strokeColor = config.gridColor.withAlphaComponent(0.3).cgColor
        gridLayer.lineWidth = 0.5
        layer.addSublayer(gridLayer)
        
        // K线层
        klineLayer.frame = bounds
        klineLayer.fillColor = nil
        layer.addSublayer(klineLayer)
        
        // 成交量层
        volumeLayer.frame = bounds
        volumeLayer.fillColor = nil
        layer.addSublayer(volumeLayer)
        
        // MA指标层
        maLayer.frame = bounds
        maLayer.fillColor = nil
        layer.addSublayer(maLayer)
        
        // 十字线层
        crosshairLayer.frame = bounds
        crosshairLayer.fillColor = nil
        crosshairLayer.strokeColor = config.crosshairColor.cgColor
        crosshairLayer.lineWidth = 0.5
        crosshairLayer.isHidden = true
        layer.addSublayer(crosshairLayer)
        
        // 信息层
        infoLayer.frame = CGRect(x: config.leftMargin, y: 5,
                                 width: 200, height: 30)
        infoLayer.fontSize = 12
        infoLayer.foregroundColor = config.textColor.cgColor
        infoLayer.backgroundColor = UIColor.white.withAlphaComponent(0.8).cgColor
        infoLayer.cornerRadius = 4
        infoLayer.alignmentMode = .left
        infoLayer.isHidden = true
        layer.addSublayer(infoLayer)
    }
    
    // 数据设置
    func setKLineData(_ data: [KLineData])
    {
        self.klineDatas = data.sorted { $0.timestamp < $1.timestamp }
        calculateMA()
        resetView()
    }
    
    // 更新配置
    func updateConfig(_ config: KLineConfiguration)
    {
        self.config = config
        backgroundColor = config.backgroundColor
        setNeedsDisplay()
    }
    
    // 重置视图
    func resetView()
    {
        scale = 1.0
        klineWidth = config.defaultKLineWidth
        offsetX = 0
        updateVisibleRange()
        redrawAll()
    }
    
    // 更新可显示K线
    private func updateVisibleRange()
    {
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
    
    // 可显示K线边界条件
    private func calculateVisibleExtremes()
    {
        guard visibleCount > 0 else { return }
        
        let endIndex = min(visibleStartIndex + visibleCount, klineDatas.count)
        let visibleData = Array(klineDatas[visibleStartIndex..<endIndex])
        
        guard let first = visibleData.first else { return }
        
        visiblePriceMax = first.high
        visiblePriceMin = first.low
        visibleVolumeMax = first.volume
        
        for data in visibleData {
            visiblePriceMax = max(visiblePriceMax, data.high)
            visiblePriceMin = min(visiblePriceMin, data.low)
            visibleVolumeMax = max(visibleVolumeMax, data.volume)
        }
        
        // 添加边距
        let priceRange = visiblePriceMax - visiblePriceMin
        if priceRange > 0 {
            visiblePriceMax += priceRange * 0.05
            visiblePriceMin = max(0, visiblePriceMin - priceRange * 0.05)
        }
        
        if visibleVolumeMax > 0 {
            visibleVolumeMax *= 1.1
        }
    }
    
    // 技术指标计算
    private func calculateMA()
    {
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
    
    // MARK: - 绘图方法
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 使用Core Graphics重绘
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
    }
    
    private func redrawAll() {
        setNeedsDisplay()
    }
    
    private func drawGrid(in context: CGContext) {
        let chartRect = getChartRect()
        
        context.setStrokeColor(config.gridColor.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(0.5)
        
        // 水平网格线
        let horizontalLines = 5
        for i in 0...horizontalLines {
            let y = chartRect.origin.y + CGFloat(i) * chartRect.height / CGFloat(horizontalLines)
            
            // 网格线
            context.move(to: CGPoint(x: chartRect.origin.x, y: y))
            context.addLine(to: CGPoint(x: chartRect.maxX, y: y))
            
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
        
        // 垂直网格线（日期线）
        guard visibleCount > 0 else { return }
        
        let dateLines = min(5, visibleCount)
        let step = max(1, visibleCount / dateLines)
        
        for i in 0..<dateLines {
            let dataIndex = visibleStartIndex + i * step
            if dataIndex < klineDatas.count {
                let x = getXPosition(for: dataIndex)
                
                context.move(to: CGPoint(x: x, y: chartRect.origin.y))
                context.addLine(to: CGPoint(x: x, y: chartRect.maxY))
                
                // 日期标签
                if config.showDateLabel {
                    let dateText = klineDatas[dataIndex].date
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
        
        context.strokePath()
    }
    
    private func drawKlines(in context: CGContext) {
        guard visibleCount > 0 else { return }
        
        let chartRect = getChartRect()
        let priceRange = visiblePriceMax - visiblePriceMin
        guard priceRange > 0 else { return }
        
        let endIndex = min(visibleStartIndex + visibleCount, klineDatas.count)
        
        for i in visibleStartIndex..<endIndex {
            let data = klineDatas[i]
            let x = getXPosition(for: i)
            
            // 转换价格到坐标
            func priceToY(_ price: CGFloat) -> CGFloat {
                return chartRect.maxY - (price - visiblePriceMin) / priceRange * chartRect.height
            }
            
            let openY = priceToY(data.open)
            let closeY = priceToY(data.close)
            let highY = priceToY(data.high)
            let lowY = priceToY(data.low)
            
            let color = data.isUp ? config.upColor : config.downColor
            
            // 绘制上下影线
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(1)
            
            let bodyTop = min(openY, closeY)
            let bodyBottom = max(openY, closeY)
            
            // 上影线
            if highY < bodyTop {
                context.move(to: CGPoint(x: x + klineWidth/2, y: highY))
                context.addLine(to: CGPoint(x: x + klineWidth/2, y: bodyTop))
            }
            
            // 下影线
            if lowY > bodyBottom {
                context.move(to: CGPoint(x: x + klineWidth/2, y: bodyBottom))
                context.addLine(to: CGPoint(x: x + klineWidth/2, y: lowY))
            }
            
            context.strokePath()
            
            // 绘制实体
            let bodyHeight = abs(closeY - openY)
            if bodyHeight > 0 {
                let bodyRect = CGRect(x: x,
                                      y: min(openY, closeY),
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
                context.move(to: CGPoint(x: x + klineWidth/2, y: openY - 0.5))
                context.addLine(to: CGPoint(x: x + klineWidth/2, y: openY + 0.5))
                context.strokePath()
            }
        }
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
    
    private func hideCrosshair() {
        showCrosshair = false
        crosshairPoint = nil
        selectedIndex = nil
        crosshairLayer.isHidden = true
        infoLayer.isHidden = true
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

// MARK: 拖拽手势
extension KLineChartView {
    private func setupPanGestures()
    {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer)
    {
        // 如果正在捏合缩放，则不处理拖拽
        if isPinching {
            return
        }
        
        switch gesture.state {
        case .began:
            isDragging = true
            panStartX = gesture.translation(in: self).x
            lastOffsetX = offsetX
            
            // 停止惯性动画
            stopInertialScroll()
            
        case .changed:
            let translation = gesture.translation(in: self)
            let deltaX = translation.x - panStartX
            
            // 计算新的偏移量
            let chartWidth = getChartRect().width
            let totalWidth = CGFloat(klineDatas.count) * (klineWidth + config.klineSpacing)
            let maxOffset = max(0, totalWidth - chartWidth)
            
            if maxOffset > 0 {
                offsetX = lastOffsetX - deltaX
                offsetX = min(max(0, offsetX), maxOffset)
                
                updateVisibleRange()
                redrawAll()
            }
            
        case .ended:
            isDragging = false
            
            // 计算惯性速度
            let velocity = gesture.velocity(in: self).x
            if abs(velocity) > 50 {
                startInertialScroll(velocity: velocity)
            }
            
        case .cancelled, .failed:
            isDragging = false
            
        default:
            break
        }
    }
    
    // 惯性滚动
    private func startInertialScroll(velocity: CGFloat)
    {
        inertialVelocity = velocity * 0.5 // 降低速度系数
        
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(updateInertialScroll))
            displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    private func stopInertialScroll()
    {
        displayLink?.invalidate()
        displayLink = nil
        inertialVelocity = 0
    }
    
    @objc private func updateInertialScroll()
    {
        guard abs(inertialVelocity) > 0.5 else {
            stopInertialScroll()
            return
        }
        
        // 应用减速
        inertialVelocity *= inertialDeceleration
        
        // 更新位置
        let chartWidth = getChartRect().width
        let totalWidth = CGFloat(klineDatas.count) * (klineWidth + config.klineSpacing)
        let maxOffset = max(0, totalWidth - chartWidth)
        
        if maxOffset > 0 {
            offsetX -= inertialVelocity * 0.016 // 时间因子
            
            // 边界检查并反弹
            if offsetX < 0 {
                offsetX = 0
                inertialVelocity = -inertialVelocity * 0.3 // 反弹
            } else if offsetX > maxOffset {
                offsetX = maxOffset
                inertialVelocity = -inertialVelocity * 0.3 // 反弹
            }
            
            updateVisibleRange()
            redrawAll()
        } else {
            stopInertialScroll()
        }
    }
}

// MARK: 捏合手势
extension KLineChartView {
    private func setupPinchGestures()
    {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer)
    {
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
            redrawAll()
            
        default:
            break
        }
    }
    
    // 安全获取捏合中心点（修复crash的关键）
    private func getSafePinchCenter(for gesture: UIPinchGestureRecognizer) -> CGPoint?
    {
        let touchCount = gesture.numberOfTouches
        
        guard touchCount >= 2 else {
            return nil
        }
        
        do {
            // 使用try-catch保护
            let touchPoint1 = gesture.location(ofTouch: 0, in: self)
            let touchPoint2 = gesture.location(ofTouch: 1, in: self)
            
            return CGPoint(
                x: (touchPoint1.x + touchPoint2.x) / 2,
                y: (touchPoint1.y + touchPoint2.y) / 2
            )
        } catch {
            // 如果出错，使用手势位置
            return gesture.location(in: self)
        }
    }
    
    // 执行缩放操作
    private func performZoom(scaleChange: CGFloat, centerIndex: Int?)
    {
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
            redrawAll()
        }
    }
}

// MARK: 长按手势
extension KLineChartView {
    private func setupLongGestures()
    {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer)
    {
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
            
            updateCrosshair()
            showSelectedInfo()
            
        case .ended, .cancelled:
            hideCrosshair()
            
        default:
            break
        }
    }
    
    // 十字线
    private func updateCrosshair() {
        guard let point = crosshairPoint else { return }
        
        let chartRect = getChartRect()
        let path = UIBezierPath()
        
        // 垂直线
        path.move(to: CGPoint(x: point.x, y: chartRect.origin.y))
        path.addLine(to: CGPoint(x: point.x, y: chartRect.maxY))
        
        // 水平线
        path.move(to: CGPoint(x: chartRect.origin.x, y: point.y))
        path.addLine(to: CGPoint(x: chartRect.maxX, y: point.y))
        
        crosshairLayer.path = path.cgPath
        crosshairLayer.isHidden = false
    }
    
    //
    private func showSelectedInfo() {
        guard let index = selectedIndex, index < klineDatas.count else { return }
        
        let data = klineDatas[index]
        
        let priceRange = visiblePriceMax - visiblePriceMin
        let chartRect = getChartRect()
        let price = visiblePriceMax - (crosshairPoint?.y ?? 0 - chartRect.origin.y) / chartRect.height * priceRange
        
        let infoText = """
        日期: \(data.date)
        价格: \(formatPrice(price))
        开: \(formatPrice(data.open))  收: \(formatPrice(data.close))
        高: \(formatPrice(data.high))  低: \(formatPrice(data.low))
        涨幅: \(String(format: "%.2f%%", data.change/data.open*100))
        """
        
        infoLayer.string = infoText
        infoLayer.isHidden = false
    }
    
}

// MARK: 点击手势
extension KLineChartView {
    private func setupTapGestures()
    {
        // 双击手势
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        addGestureRecognizer(doubleTapGesture)
        
        // 单击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        tapGesture.require(toFail: doubleTapGesture) // 只有双击失败才识别单击
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer)
    {
        resetView()
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer)
    {
        hideCrosshair()
    }
}


// MARK: - UIGestureRecognizerDelegate
extension KLineChartView: UIGestureRecognizerDelegate {
    // 允许某些手势同时识别
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        
        // 允许拖拽和捏合同时识别
        let isPanAndPinch = (gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) ||
        (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer)
        
        // 允许长按和其他手势同时识别
        let involvesLongPress = gestureRecognizer is UILongPressGestureRecognizer ||
        otherGestureRecognizer is UILongPressGestureRecognizer
        
        return isPanAndPinch || involvesLongPress
    }
    
    // 控制手势是否应该开始
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            // 如果是拖拽手势，检查是否是多指触摸
            if panGesture.numberOfTouches > 1 {
                // 多指触摸时不开始拖拽
                return false
            }
        }
        return true
    }
    
    // 控制手势是否应该接收触摸
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool
    {
        return true
    }
}
