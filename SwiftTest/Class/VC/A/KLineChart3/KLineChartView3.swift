//
//  KLineChartView3.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/10.
//

import UIKit

open class KLineChartView3: BaseView {
    private let drawModel: KLineDrawModel
    public init(frame: CGRect, drawModel: KLineDrawModel) {
        self.drawModel = drawModel
        super.init(frame: frame)
        
        backgroundColor = config.backgroundColor
        drawModel.chartView = self
        drawModel.loadData()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var config: KLineConfiguration3 {
        get {
            return drawModel.currentConfig
        }
    }
    
    open override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 清空背景
        context.setFillColor(config.backgroundColor.cgColor)
        context.fill(rect)
        
        // 画网格
        if config.showXAxis {
            drawXAxis(in: context)
        }
        if config.showYAxis {
            drawYAxis(in: context)
        }
        if config.showGrid {
            drawGrid(in: context)
        }
        
        // 画K线
        
    }
}

// MARK: 画网格
extension KLineChartView3 {
    private func drawXAxis(in context: CGContext) {
        context.setStrokeColor(config.xAxisColor.cgColor)
        context.setLineWidth(config.xAxisLineWidth)
        
        if config.xAxisSisplayDottedLines {
            let dashPattern: [CGFloat] = [config.xAxisLineWidth * 2, config.xAxisLineWidth * 2]
            context.setLineDash(phase: 0, lengths: dashPattern)
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }
        
        context.move(to: CGPoint(x: config.kLineChartRect.minX, y: config.kLineChartRect.maxY))
        context.addLine(to: CGPoint(x: config.kLineChartRect.maxX, y: config.kLineChartRect.maxY))
        context.strokePath()
        
        context.setLineDash(phase: 0, lengths: [])
    }
    
    private func drawYAxis(in context: CGContext) {
        context.setStrokeColor(config.yAxisColor.cgColor)
        context.setLineWidth(config.yAxisLineWidth)
        
        if config.yAxisSisplayDottedLines {
            let dashPattern: [CGFloat] = [config.yAxisLineWidth * 2, config.yAxisLineWidth * 2]
            context.setLineDash(phase: 0, lengths: dashPattern)
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }
        
        context.move(to: CGPoint(x: config.kLineChartRect.minX, y: config.kLineChartRect.maxY))
        context.addLine(to: CGPoint(x: config.kLineChartRect.minX, y: config.kLineChartRect.minY))
        context.strokePath()
        
        context.setLineDash(phase: 0, lengths: [])
    }
    
    private func drawGrid(in context: CGContext) {
        // 水平网格线
        context.setStrokeColor(config.gridXColor.cgColor)
        context.setLineWidth(config.gridXLineWidth)
        
        if config.gridXSisplayDottedLines {
            let dashPattern: [CGFloat] = [config.gridXLineWidth * 2, config.gridXLineWidth * 2]
            context.setLineDash(phase: 0, lengths: dashPattern)
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }
        
        let horizontalHeight = config.kLineChartRect.height / CGFloat(config.gridXLines)
        for i in 0...config.gridXLines {
            let y = config.kLineChartRect.minY + CGFloat(i) * horizontalHeight
            if i < config.gridXLines {
                context.move(to: CGPoint(x: config.kLineChartRect.minX, y: y))
                context.addLine(to: CGPoint(x: config.kLineChartRect.maxX, y: y))
                context.strokePath()
            }
        }
        
        // Y轴Title
        for i in 0...config.gridXLines {
            let y = config.kLineChartRect.minY + CGFloat(i) * horizontalHeight
            let price = config.visiblePriceMax - CGFloat(i) * (config.visiblePriceMax - config.visiblePriceMin) / CGFloat(config.gridXLines)
            let priceText = drawModel.formatPrice(price)
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),
                                                             .foregroundColor: config.yAxisTextColor]
            
            let textSize = priceText.size(withAttributes: attributes)
            priceText.draw(at: CGPoint(x: config.kLineChartRect.minX + 5, y: y - textSize.height / 2.0),
                           withAttributes: attributes)
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
        
        for title in config.xAxisTitles {
            context.move(to: CGPoint(x: title.point.x, y: config.kLineChartRect.minY))
            context.addLine(to: CGPoint(x: title.point.x, y: config.kLineChartRect.maxY))
            context.strokePath()
        }
        
        // X轴Title
        for title in config.xAxisTitles {
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),
                                                             .foregroundColor: config.xAxisTextColor]
            
            let textSize = title.title.size(withAttributes: attributes)
            var x = title.point.x - textSize.width / 2.0
            if x < config.kLineChartRect.minX {
                x = config.kLineChartRect.minX
            }
            if x + textSize.width > config.kLineChartRect.maxX {
                x = config.kLineChartRect.maxX - textSize.width
            }
            title.title.draw(at: CGPoint(x: x, y: config.kLineChartRect.maxY + 5),
                             withAttributes: attributes)
        }
    }
}

// MARK: - 画K线
extension KLineChartView3 {
    
    
}
