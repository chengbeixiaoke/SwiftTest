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
        setupPinchGestures()
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
        guard !viewModel.visibleData.isEmpty else { return }
        context.setLineDash(phase: 0, lengths: [])
        
        let chartRect = viewModel.kLineChartRect
        let priceRange = viewModel.visiblePriceMax - viewModel.visiblePriceMin
                
        func priceToY(_ price: CGFloat) -> CGFloat {
            if priceRange <= 0 { return chartRect.midY }
            let normalizedPrice = (price - viewModel.visiblePriceMin) / priceRange
            let clampedNormalizedPrice = min(max(normalizedPrice, 0), 1)
            return chartRect.maxY - clampedNormalizedPrice * chartRect.height
        }
        
        for (i, data) in viewModel.visibleData.enumerated() {
            var x = viewModel.kLineChartRect.origin.x + CGFloat(i) * viewModel.itemWidth
            if (viewModel.offsetX + viewModel.totalWidth - viewModel.kLineChartRect.width) < 0  {
                x = x - (viewModel.offsetX - viewModel.minOffsetX)
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
                let bodyRect = CGRect(x: x,
                                      y: min(clampedOpenY, clampedCloseY),
                                      width: viewModel.kLineWidth,
                                      height: bodyHeight)
                
                context.setFillColor(color.cgColor)
                context.fill(bodyRect)
            } else {
                // 十字线
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(viewModel.kLineWidth)
                let centerY = clampedOpenY
                context.move(to: CGPoint(x: x + viewModel.kLineWidth/2, y: centerY - 0.5))
                context.addLine(to: CGPoint(x: x + viewModel.kLineWidth/2, y: centerY + 0.5))
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
        stopInertialScroll()
        
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            viewModel.isDragging = true
            viewModel.panStartX = translation.x
            viewModel.lastOffsetX = viewModel.offsetX
            
        case .changed:
            let deltaX = translation.x - viewModel.panStartX
            let offsetX = viewModel.lastOffsetX - deltaX
            if offsetX > 0 {
                viewModel.offsetX = offsetX / 2.0
            } else if offsetX < viewModel.minOffsetX {
                viewModel.offsetX = viewModel.minOffsetX - (viewModel.minOffsetX - offsetX) / 2.0
            } else {
                viewModel.offsetX = offsetX
            }
            viewModel.calculateVisible()
            
        case .ended:
            viewModel.isDragging = false
            // 计算惯性速度
            let velocity = gesture.velocity(in: self).x
            if abs(velocity) > 50 {
                startInertialScroll(velocity: velocity)
            } else {
                // 如果没有惯性，检查是否需要回弹
                checkAndSnapBack()
            }
            
        case .cancelled, .failed:
            viewModel.isDragging = false
            checkAndSnapBack()
            
        default:
            break
        }
    }
    
    // 惯性滚动
    func startInertialScroll(velocity: CGFloat) {
        viewModel.inertialVelocity = velocity * 0.3
        
        if viewModel.displayLink == nil {
            viewModel.displayLink = CADisplayLink(target: self, selector: #selector(updateInertialScroll))
            viewModel.displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    func stopInertialScroll() {
        viewModel.displayLink?.invalidate()
        viewModel.displayLink = nil
        viewModel.inertialVelocity = 0
    }
    
    @objc private func updateInertialScroll() {
        guard abs(viewModel.inertialVelocity) > 0.1 else {
            stopInertialScroll()
            checkAndSnapBack()
            return
        }
        
        // 应用减速
        viewModel.inertialVelocity *= viewModel.inertialDeceleration
        printLog(viewModel.inertialVelocity)
        
        // 计算新位置
        let deltaX = viewModel.inertialVelocity * 0.016
        let newOffsetX = viewModel.offsetX - deltaX
        
        // 检查边界和加载
        var shouldStop = false
        if newOffsetX > 0 {
            shouldStop = true
        } else if newOffsetX < viewModel.minOffsetX {
            shouldStop = true
        } else {
            shouldStop = abs(viewModel.inertialVelocity) < 1
        }
        
        // 更新位置
        viewModel.offsetX = newOffsetX
        
        if shouldStop {
            stopInertialScroll()
            checkAndSnapBack()
        }
        
        viewModel.calculateVisible()
    }
    
    func checkAndSnapBack() {
        var needSnapBack = false
        if viewModel.offsetX > 0 {
            needSnapBack = true
            viewModel.offsetX = 0
        }
        
        let needLoadData = viewModel.offsetX < viewModel.minOffsetX - 100
        if viewModel.offsetX < viewModel.minOffsetX {
            needSnapBack = true
            viewModel.offsetX = viewModel.minOffsetX
        }
        
        if needSnapBack {
            viewModel.calculateVisible()
        }
        
        if needLoadData {
            viewModel.loadData()
        }
    }
}
// MARK: 捏合手势
extension KLineChartView {
    private func setupPinchGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        // 拖拽时，不进行缩放
        if viewModel.isDragging {
            viewModel.isPinching = false
            return
        }
        
        // 安全检查触摸点数量
        guard gesture.numberOfTouches >= 2 else {
            viewModel.isPinching = false
            return
        }
        
        switch gesture.state {
        case .began:
            viewModel.isPinching = true
            viewModel.lastPinchScale = gesture.scale
            viewModel.zoomCenterIndex = nil
            viewModel.zoomCenterX = nil

            // 停止惯性动画
            stopInertialScroll()
            
            // 安全获取缩放中心
            findZoomCenter(at: gesture)
            
        case .changed:
            let scaleChange = gesture.scale / viewModel.lastPinchScale
            viewModel.lastPinchScale = gesture.scale
            
            
            // 执行缩放
            performZoom(scaleChange: scaleChange)
            
        case .ended, .cancelled, .failed:
            viewModel.isPinching = false
            viewModel.zoomCenterIndex = nil
            viewModel.zoomCenterX = nil
            viewModel.lastPinchScale = 1.0
            viewModel.calculateVisible()
        default:
            break
        }
    }
    
    private func findZoomCenter(at gesture: UIPinchGestureRecognizer) {
        guard gesture.numberOfTouches >= 2 else { return }
        
        let touchPoint1 = gesture.location(ofTouch: 0, in: self)
        let touchPoint2 = gesture.location(ofTouch: 1, in: self)
        
        let point = CGPoint(x: (touchPoint1.x + touchPoint2.x) / 2,
                       y: (touchPoint1.y + touchPoint2.y) / 2)
        
        guard viewModel.kLineChartRect.contains(point) else { return }
        let relativeIndex = Int(floor(point.x / viewModel.itemWidth))
        viewModel.zoomCenterIndex = viewModel.visibleStartIndex + relativeIndex
        viewModel.zoomCenterX = CGFloat(relativeIndex) * viewModel.itemWidth
    }
    
    private func performZoom(scaleChange: CGFloat) {
        guard scaleChange != 1.0, let zoomCenterIndex = viewModel.zoomCenterIndex, let zoomCenterX = viewModel.zoomCenterX else { return }
        
        var newScale = viewModel.scale * scaleChange
        newScale = min(max(config.scaleMin, newScale), config.scaleMax)

        if newScale != viewModel.scale {
            viewModel.scale = newScale

            let (count, _) = viewModel.calculateKLineWidth(totalWidth: viewModel.kLineChartRect.width,
                                                               itemWidth: config.kLineWidth * viewModel.scale,
                                                               spacing: config.kLineSpacing)
            if count != viewModel.visibleCount {
                let visibleStartIndex = max(zoomCenterIndex - Int(floor(zoomCenterX / viewModel.itemWidth)), 0)
                viewModel.offsetX = min(-CGFloat((viewModel.dataList.count - count) - visibleStartIndex) * viewModel.itemWidth, 0)
            }
            viewModel.calculateVisible()
        }
    }
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
