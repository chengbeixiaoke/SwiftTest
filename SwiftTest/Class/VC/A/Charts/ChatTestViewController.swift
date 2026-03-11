//
//  ChatTestViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/9.
//

import UIKit
import SnapKit

class GradientLineChartView: UIView {
    
    // 数据点
    var dataPoints: [CGFloat] = [0.2, 0.5, 0.3, 0.8, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // 线条颜色
    var lineColor: UIColor = .blue
    
    // 渐变起始颜色
    var gradientStartColor: UIColor = .blue
    
    // 渐变结束颜色
    var gradientEndColor: UIColor = .white
    
    // 线条宽度
    var lineWidth: CGFloat = 2.0
    
    // 是否显示数据点
    var showDataPoints: Bool = true
    
    // 数据点半径
    var pointRadius: CGFloat = 4.0
    
    // 数据点颜色
    var pointColor: UIColor = .blue
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 如果没有数据点，直接返回
        guard dataPoints.count > 1 else { return }
        
        // 计算图表区域
        let chartRect = rect.insetBy(dx: 20, dy: 20)
        
        // 计算每个数据点的x坐标
        let stepX = chartRect.width / CGFloat(dataPoints.count - 1)
        
        // 找到数据的最大值和最小值
        let maxValue = dataPoints.max() ?? 1.0
        let minValue = dataPoints.min() ?? 0.0
        
        // 为了避免除零错误
        let valueRange = maxValue - minValue
        let normalizedValueRange = valueRange == 0 ? 1.0 : valueRange
        
        // 创建路径
        let linePath = UIBezierPath()
        
        // 计算第一个点
        var firstPoint = CGPoint(
            x: chartRect.minX,
            y: chartRect.maxY - (dataPoints[0] - minValue) / normalizedValueRange * chartRect.height
        )
        linePath.move(to: firstPoint)
        
        // 存储所有点用于渐变填充
        var points: [CGPoint] = [firstPoint]
        
        // 绘制线条路径
        for i in 1..<dataPoints.count {
            let point = CGPoint(
                x: chartRect.minX + CGFloat(i) * stepX,
                y: chartRect.maxY - (dataPoints[i] - minValue) / normalizedValueRange * chartRect.height
            )
            linePath.addLine(to: point)
            points.append(point)
        }
        
        // 绘制渐变填充
        drawGradientFill(context: context, chartRect: chartRect, points: points, linePath: linePath)
        
        // 绘制折线
        context.saveGState()
        lineColor.setStroke()
        linePath.lineWidth = lineWidth
        linePath.stroke()
        context.restoreGState()
        
        // 绘制数据点
        if showDataPoints {
            drawDataPoints(context: context, points: points)
        }
        
        // 绘制坐标轴（可选）
        drawAxes(in: chartRect)
    }
    
    private func drawGradientFill(context: CGContext, chartRect: CGRect, points: [CGPoint], linePath: UIBezierPath) {
        // 创建渐变填充路径
        let fillPath = UIBezierPath()
        
        // 从第一个点开始
        fillPath.move(to: points[0])
        
        // 添加所有数据点
        for point in points {
            fillPath.addLine(to: point)
        }
        
        // 连接到右下角
        fillPath.addLine(to: CGPoint(x: chartRect.maxX, y: chartRect.maxY))
        
        // 连接到左下角
        fillPath.addLine(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        
        // 闭合路径
        fillPath.close()
        
        // 创建渐变
        let colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) else {
            return
        }
        
        // 保存上下文状态
        context.saveGState()
        
        // 添加裁剪区域
        fillPath.addClip()
        
        // 绘制渐变（从上到下）
        let startPoint = CGPoint(x: chartRect.midX, y: chartRect.minY)
        let endPoint = CGPoint(x: chartRect.midX, y: chartRect.maxY)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        
        // 恢复上下文状态
        context.restoreGState()
    }
    
    private func drawDataPoints(context: CGContext, points: [CGPoint]) {
        context.saveGState()
        
        for point in points {
            let pointRect = CGRect(
                x: point.x - pointRadius,
                y: point.y - pointRadius,
                width: pointRadius * 2,
                height: pointRadius * 2
            )
            
            let pointPath = UIBezierPath(ovalIn: pointRect)
            pointColor.setFill()
            pointPath.fill()
            
            // 添加白色边框
            UIColor.white.setStroke()
            pointPath.lineWidth = 1.0
            pointPath.stroke()
        }
        
        context.restoreGState()
    }
    
    private func drawAxes(in chartRect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        
        // 设置轴线颜色
        UIColor.lightGray.setStroke()
        context.setLineWidth(1.0)
        
        // 绘制X轴
        context.move(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        context.addLine(to: CGPoint(x: chartRect.maxX, y: chartRect.maxY))
        context.strokePath()
        
        // 绘制Y轴
        context.move(to: CGPoint(x: chartRect.minX, y: chartRect.minY))
        context.addLine(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        context.strokePath()
        
        context.restoreGState()
    }
}

// 使用示例
class ChatTestViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建折线图视图
        let chartView = GradientLineChartView(frame: CGRect(x: 20, y: 100, width: 300, height: 200))
        chartView.backgroundColor = .white
        
        // 自定义样式
        chartView.lineColor = .blue
        chartView.gradientStartColor = .blue
        chartView.gradientEndColor = .white
        chartView.lineWidth = 2.5
        chartView.pointColor = .blue
        
        // 设置数据点
        chartView.dataPoints = [0.1, 0.3, 0.6, 0.4, 0.9, 0.7, 0.5, 0.8, 0.3, 0.2]
        
        view.addSubview(chartView)
        
        // 添加说明标签
        let label = UILabel(frame: CGRect(x: 20, y: 320, width: 300, height: 30))
        label.text = "蓝色渐变折线图"
        label.textAlignment = .center
        label.textColor = .darkGray
        view.addSubview(label)
    }
}
