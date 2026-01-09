//
//  KLineChartView.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/10.
//

import UIKit

class KLineChartView: BaseView {
    private let viewModel: KLineDrawViewModel
    init(frame: CGRect, viewModel: KLineDrawViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        backgroundColor = viewModel.config.backgroundColor
        viewModel.chartView = self
        viewModel.loadData()
        
        setupGestures()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var config: KLineConfig
    {
        return viewModel.config
    }
    
    public var kChartRect: CGRect
    {
        return viewModel.kLineChartRect
    }
    
    open override func draw(_ rect: CGRect)
    {
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
    
    // MARK: 画网格
    private func drawGrid(in context: CGContext)
    {
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
            
            context.move(to: CGPoint(x: kChartRect.minX, y: kChartRect.maxY))
            context.addLine(to: CGPoint(x: kChartRect.maxX, y: kChartRect.maxY))
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
        
        let horizontalHeight = kChartRect.height / CGFloat(config.gridXLines)
        for i in 0...config.gridXLines {
            let y = kChartRect.minY + CGFloat(i) * horizontalHeight
            if i < config.gridXLines {
                context.move(to: CGPoint(x: kChartRect.minX, y: y))
                context.addLine(to: CGPoint(x: kChartRect.maxX, y: y))
                context.strokePath()
            }
        }
        
        // Y轴Title
        for i in 0...config.gridXLines {
            let y = kChartRect.minY + CGFloat(i) * horizontalHeight
            let price = viewModel.visiblePriceMax - CGFloat(i) * (viewModel.visiblePriceMax - viewModel.visiblePriceMin) / CGFloat(config.gridXLines)
            let priceText = viewModel.formatPrice(price)
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),
                                                             .foregroundColor: config.yAxisTextColor]
            
            let textSize = priceText.size(withAttributes: attributes)
            priceText.draw(at: CGPoint(x: kChartRect.minX + 5, y: y - textSize.height / 2.0),
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
            
            context.move(to: CGPoint(x: kChartRect.minX, y: kChartRect.maxY))
            context.addLine(to: CGPoint(x: kChartRect.minX, y: kChartRect.minY))
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
            context.move(to: CGPoint(x: title.point.x, y: kChartRect.minY))
            context.addLine(to: CGPoint(x: title.point.x, y: kChartRect.maxY))
            context.strokePath()
        }
        
        // X轴Title
        for title in viewModel.xAxisTitles {
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),
                                                             .foregroundColor: config.xAxisTextColor]
            
            let textSize = title.title.size(withAttributes: attributes)
            var x = title.point.x - textSize.width / 2.0
            if x < kChartRect.minX {
                x = kChartRect.minX
            }
            if x + textSize.width > kChartRect.maxX {
                x = kChartRect.maxX - textSize.width
            }
            title.title.draw(at: CGPoint(x: x, y: kChartRect.maxY + 5),
                             withAttributes: attributes)
        }
    }
    
    // MARK: - 画K线
    private func drawKlines(in context: CGContext)
    {
        guard !viewModel.visibleData.isEmpty else { return }
        context.setLineDash(phase: 0, lengths: [])
        
        let chartRect = kChartRect
        let priceRange = viewModel.visiblePriceMax - viewModel.visiblePriceMin
        
        func priceToY(_ price: CGFloat) -> CGFloat {
            if priceRange <= 0 { return chartRect.midY }
            let normalizedPrice = (price - viewModel.visiblePriceMin) / priceRange
            let clampedNormalizedPrice = min(max(normalizedPrice, 0), 1)
            return chartRect.maxY - clampedNormalizedPrice * chartRect.height
        }
        
        for (i, data) in viewModel.visibleData.enumerated() {
            var x = kChartRect.origin.x + CGFloat(i) * viewModel.itemWidth
            if viewModel.offsetX < viewModel.minOffsetX {
                x = x - (viewModel.offsetX - viewModel.minOffsetX)/2.0
            }
            
            // 绘制坐标时间线
            if i > 0, data.date_yyyymm != viewModel.visibleData[i-1].date_yyyymm {
                context.setStrokeColor(config.gridYColor.cgColor)
                context.setLineWidth(config.gridYLineWidth)
                
                if config.gridYSisplayDottedLines {
                    let dashPattern: [CGFloat] = [config.gridYLineWidth * 2, config.gridYLineWidth * 2]
                    context.setLineDash(phase: 0, lengths: dashPattern)
                } else {
                    context.setLineDash(phase: 0, lengths: [])
                }
                
                context.move(to: CGPoint(x: x, y: kChartRect.minY))
                context.addLine(to: CGPoint(x: x, y: kChartRect.maxY))
                context.strokePath()
                
                let timeText = data.date_yyyymm
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10),
                                                                 .foregroundColor: config.yAxisTextColor]
                
                let textSize = timeText.size(withAttributes: attributes)
                let pointX = min(max(x - textSize.width/2.0, 0), kChartRect.maxX - textSize.width)
                let point = CGPoint(x: pointX, y: kChartRect.maxY + 2.0)
                timeText.draw(at: point, withAttributes: attributes)
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
            context.setLineWidth(config.kLineShadowWidth)
            context.setLineDash(phase: 0, lengths: [])
            
            let bodyTop = min(clampedOpenY, clampedCloseY)
            let bodyBottom = max(clampedOpenY, clampedCloseY)
            
            // 上影线
            if clampedHighY < bodyTop {
                context.move(to: CGPoint(x: x + viewModel.kLineWidth/2, y: clampedHighY))
                context.addLine(to: CGPoint(x: x + viewModel.kLineWidth/2, y: bodyTop))
            }
            
            // 下影线
            if clampedLowY > bodyBottom {
                context.move(to: CGPoint(x: x + viewModel.kLineWidth/2, y: bodyBottom))
                context.addLine(to: CGPoint(x: x + viewModel.kLineWidth/2, y: clampedLowY))
            }
            
            context.strokePath()
            
            // 绘制实体
            let bodyHeight = abs(clampedCloseY - clampedOpenY)
            if bodyHeight > 0 {
                let bodyRect = CGRect(x: x, y: min(clampedOpenY, clampedCloseY), width: viewModel.kLineWidth, height: bodyHeight)
                context.setFillColor(color.cgColor)
                context.fill(bodyRect)
            }
            
            // 绘制成交量
            let volumeY = viewModel.volumeChartRect.maxY - data.volumeHeight
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: x,
                                y: volumeY,
                                width: viewModel.kLineWidth,
                                height: data.volumeHeight))
            
        }
    }
}

// MARK: - 手势
extension KLineChartView: UIGestureRecognizerDelegate {
    // 添加手势
    private func setupGestures()
    {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
    }
    
    // 计算偏移量
    private func calculatePanGesture(offsetX: CGFloat)
    {
        if offsetX >= 0 {
            if (offsetX/2.0 - viewModel.offsetX) >= viewModel.itemWidth {
                viewModel.visibleStartIndex = min(viewModel.visibleStartIndex + 1, viewModel.dataList.count)
                viewModel.calculateVisible()
                viewModel.offsetX = CGFloat((viewModel.visibleStartIndex + viewModel.visibleCount) - viewModel.dataList.count) * viewModel.itemWidth
            }
        } else if offsetX >= viewModel.minOffsetX {
            if (viewModel.offsetX - offsetX) >= viewModel.itemWidth {
                viewModel.visibleStartIndex = max(viewModel.visibleStartIndex - 1, 0)
                viewModel.calculateVisible()
                viewModel.offsetX = CGFloat((viewModel.visibleStartIndex + viewModel.visibleCount) - viewModel.dataList.count) * viewModel.itemWidth
            }
            if (offsetX - viewModel.offsetX) >= viewModel.itemWidth {
                viewModel.visibleStartIndex = min(viewModel.visibleStartIndex + 1, viewModel.dataList.count)
                viewModel.calculateVisible()
                viewModel.offsetX = CGFloat((viewModel.visibleStartIndex + viewModel.visibleCount) - viewModel.dataList.count) * viewModel.itemWidth
            }
        } else {
            viewModel.visibleStartIndex = 0
            viewModel.offsetX = offsetX
            viewModel.calculateVisible()
        }
    }
    
    // 边界检查
    func checkAndSnapBack()
    {
        viewModel.inertialStartOffsetX = 0
        
        if (viewModel.visibleStartIndex + viewModel.visibleCount) > viewModel.dataList.count {
            viewModel.visibleStartIndex = viewModel.dataList.count - viewModel.visibleCount
            viewModel.offsetX = 0
            viewModel.calculateVisible()
        }
        
        if viewModel.offsetX < viewModel.minOffsetX {
            let needLoad = viewModel.offsetX < viewModel.minOffsetX - kChartRect.width/3.0
            viewModel.visibleStartIndex = 0
            viewModel.offsetX = viewModel.minOffsetX
            viewModel.calculateVisible()
            
            if needLoad {
                viewModel.loadData()
            }
        }
    }
    
    // 拖动手势
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer)
    {
        if viewModel.isPinching {
            viewModel.isDragging = false
            return
        }
        stopInertialScroll()
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            viewModel.isDragging = true
            viewModel.panStartX = translation.x
            viewModel.lastOffsetX = viewModel.offsetX
            viewModel.inertialStartOffsetX = 0
            
        case .changed:
            let deltaX = translation.x - viewModel.panStartX
            let offsetX = viewModel.lastOffsetX - deltaX
            calculatePanGesture(offsetX: offsetX)
            
        case .ended:
            viewModel.isDragging = false
            
            let velocity = gesture.velocity(in: self).x
            if abs(velocity) > 50 {
                viewModel.inertialStartOffsetX = viewModel.offsetX
                startInertialScroll(velocity: velocity)
            } else {
                checkAndSnapBack()
            }
            
        case .cancelled, .failed:
            viewModel.isDragging = false
            checkAndSnapBack()
            
        default:
            break
        }
    }
    
    // 开始惯性滚动
    func startInertialScroll(velocity: CGFloat)
    {
        viewModel.inertialVelocity = velocity * 0.3
        
        if viewModel.displayLink == nil {
            viewModel.displayLink = CADisplayLink(target: self, selector: #selector(updateInertialScroll))
            viewModel.displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    // 停止惯性滚动
    func stopInertialScroll()
    {
        viewModel.displayLink?.invalidate()
        viewModel.displayLink = nil
        viewModel.inertialVelocity = 0
    }
    
    // 惯性滚动
    @objc private func updateInertialScroll()
    {
        guard abs(viewModel.inertialVelocity) > 0.1 else {
            stopInertialScroll()
            checkAndSnapBack()
            return
        }
        
        viewModel.inertialVelocity *= viewModel.inertialDeceleration
        let deltaX = viewModel.inertialVelocity * viewModel.inertialDecelerationRatio
        viewModel.inertialStartOffsetX = viewModel.inertialStartOffsetX - deltaX
        calculatePanGesture(offsetX: viewModel.inertialStartOffsetX)
        
        var shouldStop = false
        if viewModel.offsetX > 0 {
            shouldStop = true
        } else if viewModel.offsetX < viewModel.minOffsetX {
            shouldStop = true
        } else {
            shouldStop = abs(viewModel.inertialVelocity) < 1
        }
        
        if shouldStop {
            stopInertialScroll()
            checkAndSnapBack()
        }
    }
    
    // 捏合手势
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        // 安全检查
        guard !viewModel.isDragging, gesture.numberOfTouches >= 2 else {
            resetPinchGesture()
            return
        }
        
        switch gesture.state {
        case .began:
            viewModel.isPinching = true
            viewModel.lastPinchScale = gesture.scale
            viewModel.zoomCenterIndex = nil
            viewModel.zoomCenterX = nil
            stopInertialScroll()
            findZoomCenter(at: gesture)
            
        case .changed:
            let scaleChange = gesture.scale / viewModel.lastPinchScale
            viewModel.lastPinchScale = gesture.scale
            performZoom(scaleChange: scaleChange)
            
        case .ended, .cancelled, .failed:
            resetPinchGesture()
            viewModel.calculateVisible()
        default:
            break
        }
    }
    
    // 重置捏合手势
    private func resetPinchGesture()
    {
        viewModel.isPinching = false
        viewModel.isPinching = false
        viewModel.zoomCenterIndex = nil
        viewModel.zoomCenterX = nil
        viewModel.lastPinchScale = 1.0
    }
    
    // 计算捏合中心
    private func findZoomCenter(at gesture: UIPinchGestureRecognizer)
    {
        guard gesture.numberOfTouches >= 2 else { return }
        
        let touchPoint1 = gesture.location(ofTouch: 0, in: self)
        let touchPoint2 = gesture.location(ofTouch: 1, in: self)
        
        let point = CGPoint(x: (touchPoint1.x + touchPoint2.x) / 2,
                            y: (touchPoint1.y + touchPoint2.y) / 2)
        
        guard kChartRect.contains(point) else { return }
        let relativeIndex = Int(floor(point.x / viewModel.itemWidth))
        viewModel.zoomCenterIndex = viewModel.visibleStartIndex + relativeIndex
        viewModel.zoomCenterX = point.x
    }
    
    // 执行捏合缩放计算
    private func performZoom(scaleChange: CGFloat)
    {
        guard scaleChange != 1.0, let zoomCenterX = viewModel.zoomCenterX else { return }
        
        var newScale = viewModel.scale * scaleChange
        newScale = min(max(config.scaleMin, newScale), config.scaleMax)
        
        if newScale != viewModel.scale {
            viewModel.scale = newScale
            
            let (count, kLineWidth) = viewModel.calculateKLineWidth(totalWidth: kChartRect.width,
                                                                    itemWidth: config.kLineWidth * viewModel.scale,
                                                                    spacing: config.kLineSpacing)
            if count != viewModel.visibleCount {
                if scaleChange >= 1.0 {
                    if zoomCenterX.remainder(dividingBy: kLineWidth) > (kChartRect.width - zoomCenterX).remainder(dividingBy: kLineWidth) {
                        viewModel.visibleStartIndex = viewModel.visibleStartIndex + (viewModel.visibleCount - count)
                    }
                } else {
                    if zoomCenterX.remainder(dividingBy: kLineWidth) > (kChartRect.width - zoomCenterX).remainder(dividingBy: kLineWidth) {
                        viewModel.visibleStartIndex = viewModel.visibleStartIndex - (count - viewModel.visibleCount)
                    }
                }
            }
            
            viewModel.calculateVisible()
            viewModel.offsetX = CGFloat((viewModel.visibleStartIndex + viewModel.visibleCount) - viewModel.dataList.count) * viewModel.itemWidth
            checkAndSnapBack()
        }
    }
    
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
