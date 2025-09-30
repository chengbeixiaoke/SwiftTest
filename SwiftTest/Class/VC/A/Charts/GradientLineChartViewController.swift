//
//  GradientLineChartViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/29.
//

import UIKit
import Charts

class GradientLineChartViewController: BaseViewController {
    
    private let lineChartView = LineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupChart()
        setupGradientLineChart()
    }
    
    private func setupUI() {
        title = "渐变色折线图"
        view.backgroundColor = .systemBackground
        
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineChartView)
        
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lineChartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupChart() {
        lineChartView.chartDescription.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = true
        lineChartView.drawGridBackgroundEnabled = false
        
        // X轴配置
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .systemGray
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = .systemGray5
        xAxis.axisLineColor = .systemGray
        xAxis.labelCount = 6
        xAxis.granularity = 1
        
        // 左Y轴
        let leftAxis = lineChartView.leftAxis
        leftAxis.labelTextColor = .systemGray
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = .systemGray5
        leftAxis.axisLineColor = .systemGray
        leftAxis.labelCount = 6
        leftAxis.axisMinimum = 0
        
        // 右Y轴
        let rightAxis = lineChartView.rightAxis
        rightAxis.enabled = false
        
        // 图例
        let legend = lineChartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = false
    }
    
    private func setupGradientLineChart() {
        // 生成测试数据
        let entries = generateChartData()
        
        // 创建数据集
        let dataSet = LineChartDataSet(entries: entries, label: "渐变折线")
        
        // 1. 设置线条样式
        setupLineStyle(for: dataSet)
        
        // 2. 设置渐变色填充
        setupGradientFill(for: dataSet)
        
        // 3. 创建数据并设置图表
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        
        // 添加动画
        lineChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }
    
    private func generateChartData() -> [ChartDataEntry] {
        var entries: [ChartDataEntry] = []
        let baseValue = 10.0
        
        for i in 0..<50 {
            let fluctuation = Double.random(in: 10...50)
            let value = baseValue + fluctuation
            entries.append(ChartDataEntry(x: Double(i), y: value))
        }
        
        return entries
    }
    
    private func setupLineStyle(for dataSet: LineChartDataSet) {
        // 线条颜色和宽度
        dataSet.colors = [.systemBlue]
        dataSet.lineWidth = 2.0
        
        // 圆点样式
        dataSet.drawCirclesEnabled = false
        dataSet.circleColors = [.systemBlue]
        dataSet.circleRadius = 4.0
        dataSet.circleHoleRadius = 2.0
        dataSet.circleHoleColor = .white
        
        // 曲线模式
        dataSet.mode = .linear
        dataSet.cubicIntensity = 0.2
        
        // 数值显示
        dataSet.drawValuesEnabled = false
    }
    
    private func setupGradientFill(for dataSet: LineChartDataSet) {
        // 启用填充
        dataSet.drawFilledEnabled = true
        
        // 创建渐变色
        let gradientColors: [CGColor] = [UIColor.BG_FFFFFF_1.cgColor,
                                         UIColor.BG_0091FF_05.cgColor]
        
        // 创建颜色空间
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: gradientColors as CFArray,
                                        locations: colorLocations) else { return }
        
        // 设置渐变填充
        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
        dataSet.fillAlpha = 1.0
    }
}

extension GradientLineChartViewController: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // 根据数值返回对应的标签
        let months = ["1月", "2月", "3月", "4月", "5月", "6月"]
        let index = Int(value) % months.count
        return months[index]
    }
}
