//
//  KLineChartView3.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/10.
//

import UIKit

open class KLineChartView3: BaseView {
    private let config: KLineConfiguration3
    
    public init(frame: CGRect, config: KLineConfiguration3) {
        self.config = config
        super.init(frame: frame)
        
        setupUI()
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = config.backgroundColor
    }
    
    open override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 清空背景
        context.setFillColor(config.backgroundColor.cgColor)
        context.fill(rect)
        
        // 画网格
        drawGrid(in: context)
        
        if config.showXAxis {
            drawXAxis(in: context)
        }
        
        if config.showYAxis {
            
        }
        
        if config.showGrid {
            
        }
    }
    
    private func getChartRect() -> CGRect {
        let height = config.showVolume ?
        bounds.height - config.topMargin - config.bottomMargin - config.volumeHeight - config.volumeTopMargin :
        bounds.height - config.topMargin - config.bottomMargin
        
        return CGRect(x: config.leftMargin,
                      y: config.topMargin,
                      width: bounds.width - config.leftMargin - config.rightMargin,
                      height: height)
    }
    
    private func drawXAxis(in context: CGContext) {
        let chartRect = getChartRect()
        
        
        
    }
    
    private func drawGrid(in context: CGContext) {
        let chartRect = getChartRect()
        
        
        
        
        
        
        
        
        // 设置虚线样式
        context.setStrokeColor(config.gridColor.cgColor)
        context.setLineWidth(config.gridLineWidth)
        
        // 定义虚线模式：绘制2点，跳过2点
        let dashPattern: [CGFloat] = [config.gridLineWidth * 2, config.gridLineWidth * 2]
        context.setLineDash(phase: 0, lengths: dashPattern)
        
        // 水平虚线网格线
        let horizontalHeight = chartRect.height / CGFloat(config.gridHorizontalLines)
        for i in 0...config.gridHorizontalLines {
            let y = chartRect.origin.y + CGFloat(i + 1) * horizontalHeight
            
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
        
        // 重置虚线设置，为垂直线做准备
        context.setLineDash(phase: 0, lengths: [])
    }
}
