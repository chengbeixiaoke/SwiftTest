//
//  CombinedChartDemoViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/29.
//

import UIKit
import Charts

class CombinedChartDemoViewController: BaseViewController {
    
    private let combinedChartView = CombinedChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCombinedChart()
        loadCombinedData()
    }
    
    private func setupUI() {
        title = "组合图表 Demo"
        view.backgroundColor = .systemBackground
        
        combinedChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(combinedChartView)
        
        NSLayoutConstraint.activate([
            combinedChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            combinedChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            combinedChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            combinedChartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupCombinedChart() {
        combinedChartView.chartDescription.enabled = false
        combinedChartView.dragEnabled = true
        combinedChartView.setScaleEnabled(true)
        combinedChartView.pinchZoomEnabled = true
        combinedChartView.drawGridBackgroundEnabled = false
        
        // X轴
        let xAxis = combinedChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .systemGray
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = .systemGray4
        xAxis.axisLineColor = .systemGray
        xAxis.labelCount = 6
        xAxis.granularity = 1
        
        // 左Y轴
        let leftAxis = combinedChartView.leftAxis
        leftAxis.labelTextColor = .systemBlue
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = .systemGray4
        leftAxis.axisLineColor = .systemBlue
        leftAxis.labelCount = 6
        
        // 右Y轴
        let rightAxis = combinedChartView.rightAxis
        rightAxis.labelTextColor = .systemRed
        rightAxis.drawGridLinesEnabled = false
        rightAxis.axisLineColor = .systemRed
        rightAxis.labelCount = 6
        
        // 图例
        let legend = combinedChartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = false
    }
    
    private func loadCombinedData() {
        let combinedData = CombinedChartData()
        
        // 线形数据
        combinedData.lineData = generateLineData()
        
        // 柱状数据
        combinedData.barData = generateBarData()
        
        combinedChartView.data = combinedData
        combinedChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    private func generateLineData() -> LineChartData {
        var entries: [ChartDataEntry] = []
        
        for i in 0..<12 {
            let value = Double.random(in: 20...80)
            entries.append(ChartDataEntry(x: Double(i), y: value))
        }
        
        let set = LineChartDataSet(entries: entries, label: "线形数据")
        set.colors = [.systemBlue]
        set.lineWidth = 2
        set.circleColors = [.systemBlue]
        set.circleRadius = 4
        set.drawCircleHoleEnabled = false
        set.mode = .linear
        
        return LineChartData(dataSet: set)
    }
    
    private func generateBarData() -> BarChartData {
        var entries: [BarChartDataEntry] = []
        
        for i in 0..<12 {
            let value = Double.random(in: 100...300)
            entries.append(BarChartDataEntry(x: Double(i), y: value))
        }
        
        let set = BarChartDataSet(entries: entries, label: "柱状数据")
        set.colors = [.systemRed.withAlphaComponent(0.6)]
        set.valueTextColor = .systemRed
        set.valueFont = .systemFont(ofSize: 10)
        set.axisDependency = .right
        
        return BarChartData(dataSet: set)
    }
}
