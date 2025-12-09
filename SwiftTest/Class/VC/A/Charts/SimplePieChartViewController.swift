//
//  SimplePieChartViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/8.
//

import UIKit
import Charts

class SimplePieChartViewController: BaseViewController {
    
    var pieChartView = PieChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 创建并添加图表视图
        setupPieChartView()
        
        // 2. 准备并设置数据
        setChartData()
    }
    
    func setupPieChartView() {
        pieChartView.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 300)
        view.addSubview(pieChartView)
        
        // 基本样式设置
        pieChartView.legend.enabled = true // 不显示图例[citation:7]
        pieChartView.chartDescription.enabled = true // 不显示描述文字
        pieChartView.drawEntryLabelsEnabled = true // 不在扇区内绘制标签[citation:6]
        pieChartView.usePercentValuesEnabled = true // 以百分比显示[citation:6]
        pieChartView.rotationEnabled = true // 禁止旋转[citation:6]
    }
    
    func setChartData() {
        // 1. 创建数据条目 (扇区)
        let entries = [
            PieChartDataEntry(value: 35, label: "项目A"),
            PieChartDataEntry(value: 25, label: "项目B"),
            PieChartDataEntry(value: 40, label: "项目C")
        ]
        
        // 2. 创建数据集
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = [.systemBlue, .systemGreen, .systemOrange] // 自定义颜色
        dataSet.valueColors = [.black] // 数值文本颜色
        
        // 3. 创建数据对象并赋值给图表
        let data = PieChartData(dataSet: dataSet)
        
        // 设置数值显示格式为百分比
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        formatter.percentSymbol = "%"
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        pieChartView.data = data
        
        // 4. 添加动画
        pieChartView.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
    }
}


class AnimatedPieChartWithLabelsView: UIView {
    // MARK: - 数据属性
    var dataEntries: [PieChartData] = [] {
        didSet {
            resetAnimation()
            createLabelViews()
            setNeedsDisplay()
        }
    }
    
    var colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemRed]
    var holeRadiusPercent: CGFloat = 0.4
    var animationDuration: TimeInterval = 1.5
    
    // 折线标签配置
    var labelLineLength: CGFloat = 40.0  // 折线第一段长度
    var labelLineHorizontalLength: CGFloat = 20.0  // 折线水平段长度
    var labelFont: UIFont = .systemFont(ofSize: 12)
    var labelTextColor: UIColor = .darkGray
    var lineColor: UIColor = .gray
    var lineWidth: CGFloat = 1.0
    
    // MARK: - 动画状态
    private var animationStartTime: Date?
    private var isAnimating = false
    private var displayLink: CADisplayLink?
    private var animationProgress: CGFloat = 0.0
    private var labelViews: [UILabel] = []
    private var labelLines: [CAShapeLayer] = []
    
    // MARK: - 数据结构
    struct PieChartData {
        let value: Double
        let label: String
        let description: String?
        
        init(value: Double, label: String, description: String? = nil) {
            self.value = value
            self.label = label
            self.description = description ?? label
        }
    }
    
    // MARK: - 开始动画
    func startAnimation() {
        guard !isAnimating else { return }
        
        isAnimating = true
        animationProgress = 0.0
        animationStartTime = Date()
        
        // 隐藏标签和折线，等待动画
        hideLabelsAndLines()
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.stopAnimation()
            // 动画完成后显示标签和折线
            self?.showLabelsAndLines(animated: true)
        }
    }
    
    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        isAnimating = false
        animationProgress = 1.0
        setNeedsDisplay()
    }
    
    func resetAnimation() {
        stopAnimation()
        animationProgress = 0.0
        clearLabelViews()
        clearLabelLines()
    }
    
    // MARK: - 标签管理
    private func createLabelViews() {
        clearLabelViews()
        clearLabelLines()
        
        for data in dataEntries {
            let label = UILabel()
            label.text = data.description
            label.font = labelFont
            label.textColor = labelTextColor
            label.backgroundColor = .white
            label.layer.cornerRadius = 3
            label.layer.masksToBounds = true
            label.layer.borderColor = UIColor.lightGray.cgColor
            label.layer.borderWidth = 0.5
            label.textAlignment = .center
            label.numberOfLines = 0
            label.alpha = 0.0  // 初始隐藏
            label.sizeToFit()
            
            addSubview(label)
            labelViews.append(label)
            
            // 创建折线图层
            let lineLayer = CAShapeLayer()
            lineLayer.strokeColor = lineColor.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = lineWidth
            lineLayer.lineDashPattern = nil
            lineLayer.opacity = 0.0  // 初始隐藏
            
            layer.addSublayer(lineLayer)
            labelLines.append(lineLayer)
        }
    }
    
    private func clearLabelViews() {
        labelViews.forEach { $0.removeFromSuperview() }
        labelViews.removeAll()
    }
    
    private func clearLabelLines() {
        labelLines.forEach { $0.removeFromSuperlayer() }
        labelLines.removeAll()
    }
    
    private func hideLabelsAndLines() {
        labelViews.forEach { $0.alpha = 0.0 }
        labelLines.forEach { $0.opacity = 0.0 }
    }
    
    private func showLabelsAndLines(animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        
        for (index, label) in labelViews.enumerated() {
            UIView.animate(withDuration: duration, delay: Double(index) * 0.05, options: .curveEaseOut) {
                label.alpha = 1.0
            }
            
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = duration
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.05
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            labelLines[index].add(animation, forKey: "fadeIn")
        }
    }
    
    // MARK: - 动画更新
    @objc private func updateAnimation() {
        guard let startTime = animationStartTime else { return }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        animationProgress = min(CGFloat(elapsedTime / animationDuration), 1.0)
        
        setNeedsDisplay()
        
        if animationProgress >= 1.0 {
            stopAnimation()
        }
    }
    
    // MARK: - 绘制饼图和标签
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let totalValue = dataEntries.reduce(0) { $0 + $1.value }
        if totalValue <= 0 { return }
        
        // 计算绘制区域
        let chartRect = rect.insetBy(dx: 20 + labelLineLength + labelLineHorizontalLength, 
                                    dy: 20 + labelLineLength)
        let center = CGPoint(x: chartRect.midX, y: chartRect.midY)
        let radius = min(chartRect.width, chartRect.height) / 2
        
        // 绘制饼图
        var startAngle: CGFloat = -.pi / 2
        var sectorProgresses = calculateSectorProgresses()
        
        for (index, data) in dataEntries.enumerated() {
            let sectorProgress = sectorProgresses[index]
            let finalAngle = 2 * .pi * (data.value / totalValue)
            let currentAngle = finalAngle * sectorProgress
            
            if currentAngle > 0 {
                let endAngle = startAngle + currentAngle
                let midAngle = startAngle + currentAngle / 2
                
                // 绘制扇区
                drawSector(context: context, 
                          center: center, 
                          radius: radius, 
                          startAngle: startAngle, 
                          endAngle: endAngle, 
                          color: colors[index % colors.count])
                
                // 绘制百分比标签
                if sectorProgress > 0.3 && data.value / totalValue > 0.05 {
                    drawPercentageLabel(center: center, 
                                       radius: radius, 
                                       midAngle: midAngle, 
                                       value: data.value, 
                                       totalValue: totalValue)
                }
                
                // 计算并更新外部标签位置
                if animationProgress >= 0.8 { // 饼图基本完成后才开始计算标签位置
                    updateLabelPosition(at: index, 
                                       center: center, 
                                       radius: radius, 
                                       midAngle: midAngle,
                                       totalSectors: dataEntries.count)
                }
                
                startAngle = endAngle
            } else {
                startAngle += finalAngle
            }
        }
        
        // 绘制中心空心区域
        if holeRadiusPercent > 0 {
            drawHole(center: center, radius: radius)
        }
    }
    
    // MARK: - 计算标签位置和绘制折线
    private func updateLabelPosition(at index: Int, 
                                    center: CGPoint, 
                                    radius: CGFloat, 
                                    midAngle: CGFloat,
                                    totalSectors: Int) {
        
        guard index < labelViews.count, index < labelLines.count else { return }
        
        let label = labelViews[index]
        let lineLayer = labelLines[index]
        
        // 1. 计算折线起点（扇形外圆弧中点）
        let startRadius = radius + 5  // 稍微远离扇形边缘
        let lineStartPoint = CGPoint(
            x: center.x + cos(midAngle) * startRadius,
            y: center.y + sin(midAngle) * startRadius
        )
        
        // 2. 计算折线拐点
        let lineMidPoint: CGPoint
        let lineEndPoint: CGPoint
        let labelPosition: CGPoint
        
        // 判断标签应该放在左边还是右边
        let isRightSide = cos(midAngle) >= 0
        
        if isRightSide {
            // 右边：先水平向右，再垂直延伸
            lineMidPoint = CGPoint(
                x: lineStartPoint.x + labelLineLength,
                y: lineStartPoint.y
            )
            
            // 确定垂直方向：避免标签重叠
            let verticalDirection = calculateVerticalDirection(for: index, 
                                                             midAngle: midAngle, 
                                                             totalSectors: totalSectors)
            lineEndPoint = CGPoint(
                x: lineMidPoint.x + labelLineHorizontalLength,
                y: lineMidPoint.y + verticalDirection * 10
            )
            
            // 标签在折线右侧
            labelPosition = CGPoint(
                x: lineEndPoint.x + 5,
                y: lineEndPoint.y - label.bounds.height / 2
            )
        } else {
            // 左边：先水平向左，再垂直延伸
            lineMidPoint = CGPoint(
                x: lineStartPoint.x - labelLineLength,
                y: lineStartPoint.y
            )
            
            // 确定垂直方向
            let verticalDirection = calculateVerticalDirection(for: index, 
                                                             midAngle: midAngle, 
                                                             totalSectors: totalSectors)
            lineEndPoint = CGPoint(
                x: lineMidPoint.x - labelLineHorizontalLength,
                y: lineMidPoint.y + verticalDirection * 10
            )
            
            // 标签在折线左侧（需要左对齐）
            labelPosition = CGPoint(
                x: lineEndPoint.x - label.bounds.width - 5,
                y: lineEndPoint.y - label.bounds.height / 2
            )
        }
        
        // 3. 绘制折线
        let linePath = UIBezierPath()
        linePath.move(to: lineStartPoint)
        linePath.addLine(to: lineMidPoint)
        linePath.addLine(to: lineEndPoint)
        
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = lineWidth
        
        // 4. 更新标签位置
        label.frame = CGRect(origin: labelPosition, size: label.bounds.size)
        
        // 5. 绘制折线末端的小圆点
        drawLineEndDot(at: lineStartPoint)
        drawLineEndDot(at: lineEndPoint)
    }
    
    // MARK: - 辅助方法
    private func calculateSectorProgresses() -> [CGFloat] {
        guard isAnimating && animationProgress < 1.0 else {
            return Array(repeating: 1.0, count: dataEntries.count)
        }
        
        let totalValue = dataEntries.reduce(0) { $0 + $1.value }
        var progresses: [CGFloat] = []
        var cumulativeValue: Double = 0
        
        for data in dataEntries {
            let sectorStartProgress = cumulativeValue / totalValue
            let sectorEndProgress = (cumulativeValue + data.value) / totalValue
            
            let sectorProgress: CGFloat
            if animationProgress >= sectorEndProgress {
                sectorProgress = 1.0
            } else if animationProgress <= sectorStartProgress {
                sectorProgress = 0.0
            } else {
                let progressInSector = (animationProgress - sectorStartProgress) /
                                     (sectorEndProgress - sectorStartProgress)
                sectorProgress = easeOutCubic(progressInSector)
            }
            
            progresses.append(sectorProgress)
            cumulativeValue += data.value
        }
        
        return progresses
    }
    
    private func easeOutCubic(_ t: CGFloat) -> CGFloat {
        return 1 - pow(1 - t, 3)
    }
    
    // 计算标签垂直方向（避免重叠）
    private func calculateVerticalDirection(for index: Int,
                                          midAngle: CGFloat,
                                          totalSectors: Int) -> CGFloat {
        // 根据角度决定默认方向：上半部分向上，下半部分向下
        let defaultDirection = sin(midAngle) > 0 ? -1.0 : 1.0
        
        // 这里可以添加更复杂的重叠检测逻辑
        // 简单实现：交替方向
        return index % 2 == 0 ? defaultDirection : -defaultDirection
    }
    
    private func drawLineEndDot(at point: CGPoint) {
        let dotPath = UIBezierPath(ovalIn: CGRect(
            x: point.x - 2,
            y: point.y - 2,
            width: 4,
            height: 4
        ))
        lineColor.setFill()
        dotPath.fill()
    }
    
    // MARK: - 绘制方法
    private func drawSector(context: CGContext,
                           center: CGPoint,
                           radius: CGFloat,
                           startAngle: CGFloat,
                           endAngle: CGFloat,
                           color: UIColor) {
        
        let path = CGMutablePath()
        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: false)
        path.closeSubpath()
        
        context.setFillColor(color.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        
        context.addPath(path)
        context.fillPath()
        
        context.addPath(path)
        context.strokePath()
    }
    
    private func drawPercentageLabel(center: CGPoint,
                                    radius: CGFloat,
                                    midAngle: CGFloat,
                                    value: Double,
                                    totalValue: Double) {
        
        let labelRadius = radius * 0.7
        let labelPoint = CGPoint(
            x: center.x + cos(midAngle) * labelRadius,
            y: center.y + sin(midAngle) * labelRadius
        )
        
        let percentage = value / totalValue
        let percentageText = String(format: "%.0f%%", percentage * 100)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        
        let textSize = percentageText.size(withAttributes: attributes)
        let textRect = CGRect(
            x: labelPoint.x - textSize.width / 2,
            y: labelPoint.y - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        // 添加文字背景
        let backgroundRect = textRect.insetBy(dx: -4, dy: -2)
        let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: 3)
        UIColor.black.withAlphaComponent(0.3).setFill()
        backgroundPath.fill()
        
        percentageText.draw(in: textRect, withAttributes: attributes)
    }
    
    private func drawHole(center: CGPoint, radius: CGFloat) {
        let holeRadius = radius * holeRadiusPercent
        let holePath = UIBezierPath(ovalIn: CGRect(
            x: center.x - holeRadius,
            y: center.y - holeRadius,
            width: holeRadius * 2,
            height: holeRadius * 2
        ))
        
        UIColor.white.setFill()
        holePath.fill()
        
        // 中心文字
        let totalValue = dataEntries.reduce(0) { $0 + $1.value }
        let totalText = "总计\n\(Int(totalValue))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
        
        let textSize = totalText.size(withAttributes: attributes)
        let textRect = CGRect(
            x: center.x - textSize.width / 2,
            y: center.y - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        totalText.draw(in: textRect, withAttributes: attributes)
    }
    
    // MARK: - 布局更新
    override func layoutSubviews() {
        super.layoutSubviews()
        // 重新计算标签位置
        if animationProgress >= 0.8 {
            setNeedsDisplay()
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}

// MARK: - 使用示例
class SimplePieChartViewController2: BaseViewController {
    let pieChart = AnimatedPieChartWithLabelsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPieChart()
        
        // 添加测试按钮
        let button = UIButton(type: .system)
        button.setTitle("重新开始动画", for: .normal)
        button.frame = CGRect(x: 120, y: 450, width: 120, height: 44)
        button.addTarget(self, action: #selector(restartAnimation), for: .touchUpInside)
        view.addSubview(button)
    }
    
    private func setupPieChart() {
        pieChart.frame = CGRect(x: 20, y: 80, width: 350, height: 350)
        
        // 设置数据
        let data = [
            AnimatedPieChartWithLabelsView.PieChartData(
                value: 150,
                label: "产品A",
                description: "电子产品\n销量：150件"
            ),
            AnimatedPieChartWithLabelsView.PieChartData(
                value: 80,
                label: "产品B",
                description: "服装类\n销量：80件"
            ),
            AnimatedPieChartWithLabelsView.PieChartData(
                value: 120,
                label: "产品C",
                description: "家居用品\n销量：120件"
            ),
            AnimatedPieChartWithLabelsView.PieChartData(
                value: 60,
                label: "产品D",
                description: "食品饮料\n销量：60件"
            ),
            AnimatedPieChartWithLabelsView.PieChartData(
                value: 90,
                label: "产品E",
                description: "图书音像\n销量：90件"
            )
        ]
        
        pieChart.dataEntries = data
        pieChart.holeRadiusPercent = 0.3
        pieChart.backgroundColor = .systemBackground
        pieChart.animationDuration = 2.0
        
        // 自定义标签样式
        pieChart.labelLineLength = 50
        pieChart.labelLineHorizontalLength = 25
        pieChart.labelFont = .systemFont(ofSize: 11, weight: .medium)
        pieChart.lineColor = .systemGray
        pieChart.lineWidth = 1.5
        
        view.addSubview(pieChart)
        
        // 延迟开始动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.pieChart.startAnimation()
        }
    }
    
    @objc private func restartAnimation() {
        pieChart.resetAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pieChart.startAnimation()
        }
    }
}

