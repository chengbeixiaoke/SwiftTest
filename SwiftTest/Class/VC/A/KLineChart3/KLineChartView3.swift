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
        
        backgroundColor = config.backgroundColor
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        context.setStrokeColor(config.xAxisColor.cgColor)
        context.setLineWidth(config.xAxisLineWidth)
        
        if config.xAxisSisplayDottedLines {
            let dashPattern: [CGFloat] = [config.xAxisLineWidth * 2, config.xAxisLineWidth * 2]
            context.setLineDash(phase: 0, lengths: dashPattern)
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }

        context.move(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        context.addLine(to: CGPoint(x: chartRect.maxX, y: chartRect.maxY))
        context.strokePath()
        
        context.setLineDash(phase: 0, lengths: [])
    }
    
    private func drawYAxis(in context: CGContext) {
        let chartRect = getChartRect()
        
        context.setStrokeColor(config.yAxisColor.cgColor)
        context.setLineWidth(config.yAxisLineWidth)
        
        if config.yAxisSisplayDottedLines {
            let dashPattern: [CGFloat] = [config.yAxisLineWidth * 2, config.yAxisLineWidth * 2]
            context.setLineDash(phase: 0, lengths: dashPattern)
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }

        context.move(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        context.addLine(to: CGPoint(x: chartRect.minX, y: chartRect.minY))
        context.strokePath()
        
        context.setLineDash(phase: 0, lengths: [])
    }
    
    private func drawGrid(in context: CGContext) {
        let chartRect = getChartRect()
        
        // 水平网格线
        context.setStrokeColor(config.gridXColor.cgColor)
        context.setLineWidth(config.gridXLineWidth)
        
        if config.gridXSisplayDottedLines {
            let dashPattern: [CGFloat] = [config.gridXLineWidth * 2, config.gridXLineWidth * 2]
            context.setLineDash(phase: 0, lengths: dashPattern)
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }
        
        let horizontalHeight = chartRect.height / CGFloat(config.gridXLines)
        for i in 1...config.gridXLines {
            
            let y = chartRect.maxY - CGFloat(i) * horizontalHeight
            context.move(to: CGPoint(x: chartRect.minX, y: y))
            context.addLine(to: CGPoint(x: chartRect.maxX, y: y))
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
        
        let verticalWidth = chartRect.width / CGFloat(3)
        for i in 0..<3 {
            let x = chartRect.minX + CGFloat(i + 1) * verticalWidth
            
            context.move(to: CGPoint(x: x, y: chartRect.minY))
            context.addLine(to: CGPoint(x: x, y: chartRect.maxY))
            context.strokePath()
        }
    }
}
