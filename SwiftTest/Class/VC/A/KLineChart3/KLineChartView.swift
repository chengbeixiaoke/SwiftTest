//
//  KLineChartView.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/10.
//

import UIKit

class KLineChartView: BaseView {
    let viewModel: KLineDrawViewModel
    init(frame: CGRect, viewModel: KLineDrawViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        backgroundColor = viewModel.config.backgroundColor
        viewModel.chartView = self
        viewModel.loadData()
        
        setupPanGestures()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var config: KLineConfig {
        get {
            return viewModel.config
        }
    }
    
    open override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 清空背景
        context.setFillColor(config.backgroundColor.cgColor)
        context.fill(rect)
        
        // 画网格
        if config.showGrid {
            drawGrid(in: context)
        }
        
        // 画K线
        drawKlines(in: context)
    }
}

// MARK: 画网格
extension KLineChartView {
    func drawGrid(in context: CGContext) {
        // 水平轴
        if config.showXAxis {
            context.setStrokeColor(config.xAxisColor.cgColor)
            context.setLineWidth(config.xAxisLineWidth)
            
            if config.xAxisSisplayDottedLines {
                let dashPattern: [CGFloat] = [config.xAxisLineWidth * 2, config.xAxisLineWidth * 2]
                context.setLineDash(phase: 0, lengths: dashPattern)
            } else {
                context.setLineDash(phase: 0, lengths: [])
            }
            
            context.move(to: CGPoint(x: viewModel.kLineChartRect.minX, y: viewModel.kLineChartRect.maxY))
            context.addLine(to: CGPoint(x: viewModel.kLineChartRect.maxX, y: viewModel.kLineChartRect.maxY))
            context.strokePath()
        }
        
        // 水平网格线
        context.setStrokeColor(config.gridXColor.cgColor)
        context.setLineWidth(config.gridXLineWidth)
        
        if config.gridXSisplayDottedLines {
            let dashPattern: [CGFloat] = [config.gridXLineWidth * 2, config.gridXLineWidth * 2]
            context.setLineDash(phase: 0, lengths: dashPattern)
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }
        
        let horizontalHeight = viewModel.kLineChartRect.height / CGFloat(config.gridXLines)
        for i in 0...config.gridXLines {
            let y = viewModel.kLineChartRect.minY + CGFloat(i) * horizontalHeight
            if i < config.gridXLines {
                context.move(to: CGPoint(x: viewModel.kLineChartRect.minX, y: y))
                context.addLine(to: CGPoint(x: viewModel.kLineChartRect.maxX, y: y))
                context.strokePath()
            }
        }
        
        // Y轴Title
        for i in 0...config.gridXLines {
            let y = viewModel.kLineChartRect.minY + CGFloat(i) * horizontalHeight
            let price = viewModel.visiblePriceMax - CGFloat(i) * (viewModel.visiblePriceMax - viewModel.visiblePriceMin) / CGFloat(config.gridXLines)
            let priceText = viewModel.formatPrice(price)
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),
                                                             .foregroundColor: config.yAxisTextColor]
            
            let textSize = priceText.size(withAttributes: attributes)
            priceText.draw(at: CGPoint(x: viewModel.kLineChartRect.minX + 5, y: y - textSize.height / 2.0),
                           withAttributes: attributes)
        }
        
        // Y轴
        if config.showYAxis {
            context.setStrokeColor(config.yAxisColor.cgColor)
            context.setLineWidth(config.yAxisLineWidth)
            
            if config.yAxisSisplayDottedLines {
                let dashPattern: [CGFloat] = [config.yAxisLineWidth * 2, config.yAxisLineWidth * 2]
                context.setLineDash(phase: 0, lengths: dashPattern)
            } else {
                context.setLineDash(phase: 0, lengths: [])
            }
            
            context.move(to: CGPoint(x: viewModel.kLineChartRect.minX, y: viewModel.kLineChartRect.maxY))
            context.addLine(to: CGPoint(x: viewModel.kLineChartRect.minX, y: viewModel.kLineChartRect.minY))
            context.strokePath()
        }
        
        // 垂直网格线
        context.setStrokeColor(config.gridYColor.cgColor)
        context.setLineWidth(config.gridYLineWidth)
        
        if config.gridYSisplayDottedLines {
            let dashPattern: [CGFloat] = [config.gridYLineWidth * 2, config.gridYLineWidth * 2]
            context.setLineDash(phase: 0, lengths: dashPattern)
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }
        
        for title in viewModel.xAxisTitles {
            context.move(to: CGPoint(x: title.point.x, y: viewModel.kLineChartRect.minY))
            context.addLine(to: CGPoint(x: title.point.x, y: viewModel.kLineChartRect.maxY))
            context.strokePath()
        }
        
        // X轴Title
        for title in viewModel.xAxisTitles {
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),
                                                             .foregroundColor: config.xAxisTextColor]
            
            let textSize = title.title.size(withAttributes: attributes)
            var x = title.point.x - textSize.width / 2.0
            if x < viewModel.kLineChartRect.minX {
                x = viewModel.kLineChartRect.minX
            }
            if x + textSize.width > viewModel.kLineChartRect.maxX {
                x = viewModel.kLineChartRect.maxX - textSize.width
            }
            title.title.draw(at: CGPoint(x: x, y: viewModel.kLineChartRect.maxY + 5),
                             withAttributes: attributes)
        }
    }
}

// MARK: - 画K线
extension KLineChartView {
    func drawKlines(in context: CGContext) {
        guard viewModel.visibleCount > 0 else { return }
        context.setLineDash(phase: 0, lengths: [])

        let chartRect = viewModel.kLineChartRect
        let priceRange = viewModel.visiblePriceMax - viewModel.visiblePriceMin
        
        let endIndex = min(viewModel.visibleStartIndex + viewModel.visibleCount, viewModel.dataList.count)
        
        func priceToY(_ price: CGFloat) -> CGFloat {
            if priceRange <= 0 { return chartRect.midY }
            let normalizedPrice = (price - viewModel.visiblePriceMin) / priceRange
            let clampedNormalizedPrice = min(max(normalizedPrice, 0), 1)
            return chartRect.maxY - clampedNormalizedPrice * chartRect.height
        }
        
        for i in viewModel.visibleStartIndex..<endIndex {
            let data = viewModel.dataList[i]
            let x = viewModel.getXPosition(for: i)
            
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
            context.setLineWidth(config.kLineShadowWidth)
            
            let bodyTop = min(clampedOpenY, clampedCloseY)
            let bodyBottom = max(clampedOpenY, clampedCloseY)
            
            // 上影线
            if clampedHighY < bodyTop {
                context.move(to: CGPoint(x: x + config.kLineWidth/2, y: clampedHighY))
                context.addLine(to: CGPoint(x: x + config.kLineWidth/2, y: bodyTop))
            }
            
            // 下影线
            if clampedLowY > bodyBottom {
                context.move(to: CGPoint(x: x + config.kLineWidth/2, y: bodyBottom))
                context.addLine(to: CGPoint(x: x + config.kLineWidth/2, y: clampedLowY))
            }
            
            context.strokePath()
            
            // 绘制实体
            let bodyHeight = abs(clampedCloseY - clampedOpenY)
            if bodyHeight > 0 {
                let bodyRect = CGRect(x: x,
                                    y: min(clampedOpenY, clampedCloseY),
                                    width: config.kLineWidth,
                                    height: bodyHeight)
                
                context.setFillColor(color.cgColor)
                context.fill(bodyRect)
            } else {
                // 十字线
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(config.kLineWidth)
                let centerY = clampedOpenY
                context.move(to: CGPoint(x: x + config.kLineWidth/2, y: centerY - 0.5))
                context.addLine(to: CGPoint(x: x + config.kLineWidth/2, y: centerY + 0.5))
                context.strokePath()
            }
        }
    }
}

// MARK: 滑动/拖动手势
extension KLineChartView {
    func setupPanGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        // 如果正在捏合，则不处理拖拽
        if viewModel.isPinching {
            return
        }
        
        // 停止惯性动画
//        stopInertialScroll()
        
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            viewModel.isDragging = true
            viewModel.panStartX = translation.x
            viewModel.lastOffsetX = viewModel.offsetX
            
        case .changed:
            let deltaX = translation.x - viewModel.panStartX
            
            viewModel.offsetX = viewModel.lastOffsetX - deltaX
            
            printLog(viewModel.offsetX)
            
            viewModel.calculateVisible()
            setNeedsDisplay()
            
        case .ended:
            viewModel.isDragging = false
            
        case .cancelled, .failed:
            viewModel.isDragging = false
            
        default:
            break
        }
    }
    
//    // MARK: - 无限滚动核心逻辑
//    private func checkBoundaryAndLoadData(chartWidth: CGFloat, totalWidth: CGFloat) {
//        let maxOffset = max(0, totalWidth - chartWidth)
//        
//        // 检查左边界
//        if offsetX < -config.loadingThreshold && loadingState == .idle && hasMoreLeftData {
//            loadMoreData(in: .loadingLeft)
//        }
//        
//        // 检查右边界
//        if offsetX > maxOffset + config.loadingThreshold && loadingState == .idle && hasMoreRightData {
//            loadMoreData(in: .loadingRight)
//        }
//    }
//    private func checkAndSnapBack() {
//        let chartWidth = getChartRect().width
//        let totalWidth = CGFloat(klineDatas.count) * (klineWidth + config.klineSpacing)
//        let maxOffset = max(0, totalWidth - chartWidth)
//        
//        // 如果没有在加载数据，则回弹到边界内
//        if loadingState == .idle {
//            if offsetX < 0 {
//                offsetX = 0
//            } else if offsetX > maxOffset {
//                offsetX = maxOffset
//            }
//            updateVisibleRange()
//            setNeedsDisplay()
//        }
//    }
//    
//    private func loadMoreData(in direction: KLineChartViewLoadingState) {
//        guard let dataSource = dataSource, loadingState == .idle else { return }
//        
//        loadingState = direction
//        
//        // 获取最早或最晚的数据时间
//        guard let targetDate = getTargetDate(for: direction) else {
//            loadingState = .idle
//            return
//        }
//        
//        // 定义完成处理
//        let handleCompletion = { [weak self] (newData: [KLineData]) in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                // 在这里根据返回的数据量判断是否还有更多数据
//                if direction == .loadingLeft {
//                    self.hasMoreLeftData = newData.count >= self.pageSize
//                } else {
//                    self.hasMoreRightData = newData.count >= self.pageSize
//                }
//                
//                self.handleLoadedData(newData, direction: direction)
//            }
//        }
//        
//        if direction == .loadingLeft {
//            dataSource.loadHistoricalData(before: targetDate,
//                                          count: pageSize,
//                                          completion: handleCompletion)
//        } else {
//            dataSource.loadRecentData(after: targetDate,
//                                      count: pageSize,
//                                      completion: handleCompletion)
//        }
//        
//        setNeedsDisplay()
//    }
//    
//    private func getTargetDate(for direction: KLineChartViewLoadingState) -> Date? {
//        guard !klineDatas.isEmpty else { return nil }
//        
//        if direction == .loadingLeft {
//            // 获取最早的数据日期
//            let earliestData = klineDatas.first!
//            return Date(timeIntervalSince1970: earliestData.timestamp - 1)
//        } else {
//            // 获取最新的数据日期
//            let latestData = klineDatas.last!
//            return Date(timeIntervalSince1970: latestData.timestamp + 1)
//        }
//    }
//    
//    private func handleLoadedData(_ newData: [KLineData], direction: KLineChartViewLoadingState) {
//        guard !newData.isEmpty else {
//            // 没有更多数据
//            if direction == .loadingLeft {
//                hasMoreLeftData = false
//            } else {
//                hasMoreRightData = false
//            }
//            loadingState = .idle
//            checkAndSnapBack()
//            return
//        }
//        
//        // 根据方向合并数据
//        let oldCount = klineDatas.count
//        let oldOffsetX = offsetX
//        let chartWidth = getChartRect().width
//        
//        if direction == .loadingLeft {
//            // 在开头插入数据
//            klineDatas = newData.reversed() + klineDatas
//            
//            // 调整offsetX以保持视觉位置
//            let addedWidth = CGFloat(newData.count) * (klineWidth + config.klineSpacing)
//            offsetX = oldOffsetX + addedWidth
//            
//        } else {
//            // 在末尾追加数据
//            klineDatas += newData
//            
//            // offsetX保持不变
//        }
//        
//        // 计算技术指标
//        calculateMA()
//        
//        // 加载完成，回弹到正常位置
//        loadingState = .idle
//        
//        // 如果是从左边界加载的，需要平滑过渡
//        if direction == .loadingLeft {
//            animateLeftBoundaryTransition(oldOffsetX: oldOffsetX,
//                                          oldCount: oldCount,
//                                          newCount: klineDatas.count,
//                                          chartWidth: chartWidth)
//        } else {
//            checkAndSnapBack()
//        }
//        
//        updateVisibleRange()
//        setNeedsDisplay()
//    }
//    
//    private func animateLeftBoundaryTransition(oldOffsetX: CGFloat,
//                                               oldCount: Int,
//                                               newCount: Int,
//                                               chartWidth: CGFloat) {
//        let totalWidth = CGFloat(newCount) * (klineWidth + config.klineSpacing)
//        
//        // 计算目标位置（显示新加载的数据）
//        let targetOffset: CGFloat = 0
//        
//        // 使用动画平滑过渡
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
//            self.offsetX = targetOffset
//            self.updateVisibleRange()
//            self.setNeedsDisplay()
//        })
//    }
//    
//    // MARK: - 惯性滚动
//    private func startInertialScroll(velocity: CGFloat) {
//        inertialVelocity = velocity * 0.3
//        
//        if displayLink == nil {
//            displayLink = CADisplayLink(target: self, selector: #selector(updateInertialScroll))
//            displayLink?.add(to: .main, forMode: .common)
//        }
//    }
//    
//    private func stopInertialScroll() {
//        displayLink?.invalidate()
//        displayLink = nil
//        inertialVelocity = 0
//    }
//    
//    @objc private func updateInertialScroll() {
//        guard abs(inertialVelocity) > 0.1 else {
//            stopInertialScroll()
//            checkAndSnapBack()
//            return
//        }
//        
//        // 应用减速
//        inertialVelocity *= inertialDeceleration
//        
//        // 获取边界信息
//        let chartWidth = getChartRect().width
//        let totalWidth = CGFloat(klineDatas.count) * (klineWidth + config.klineSpacing)
//        let maxOffset = max(0, totalWidth - chartWidth)
//        
//        // 计算新位置
//        let deltaX = inertialVelocity * 0.016
//        var newOffsetX = offsetX - deltaX
//        
//        // 检查边界和加载
//        var shouldStop = false
//        
//        if newOffsetX < -config.loadingThreshold && loadingState == .idle && hasMoreLeftData {
//            // 触发左边界加载
//            loadMoreData(in: .loadingLeft)
//            shouldStop = true
//        } else if newOffsetX > maxOffset + config.loadingThreshold && loadingState == .idle && hasMoreRightData {
//            // 触发右边界加载
//            loadMoreData(in: .loadingRight)
//            shouldStop = true
//        } else if newOffsetX < 0 {
//            // 左边界阻尼
//            newOffsetX = 0
//            inertialVelocity *= 0.3
//            shouldStop = abs(inertialVelocity) < 1
//        } else if newOffsetX > maxOffset {
//            // 右边界阻尼
//            newOffsetX = maxOffset
//            inertialVelocity *= 0.3
//            shouldStop = abs(inertialVelocity) < 1
//        }
//        
//        // 更新位置
//        offsetX = newOffsetX
//        
//        if shouldStop {
//            stopInertialScroll()
//            checkAndSnapBack()
//        }
//        
//        updateVisibleRange()
//        setNeedsDisplay()
//    }
}


// MARK: - UIGestureRecognizerDelegate
extension KLineChartView: UIGestureRecognizerDelegate {
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
