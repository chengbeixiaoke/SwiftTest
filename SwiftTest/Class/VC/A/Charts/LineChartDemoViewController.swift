//
//  LineChartDemoViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/29.
//

import UIKit
import Charts

class LineChartDemoViewController: BaseViewController {
    
    private let lineChartView = LineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLineChart()
        loadLineChartData()
    }
    
    private func setupUI() {
        title = "折线图 Demo"
        view.backgroundColor = .systemBackground
        
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineChartView)
        
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lineChartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupLineChart() {
        lineChartView.chartDescription.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = true
        lineChartView.drawGridBackgroundEnabled = false
        
        // X轴
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .systemGray
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = .systemGray4
        xAxis.axisLineColor = .systemGray
        xAxis.labelCount = 6
        xAxis.granularity = 1
        
        // 左Y轴
        let leftAxis = lineChartView.leftAxis
        leftAxis.labelTextColor = .systemGray
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = .systemGray4
        leftAxis.axisLineColor = .systemGray
        leftAxis.labelCount = 6
        
        // 右Y轴
        let rightAxis = lineChartView.rightAxis
        rightAxis.enabled = false
        
        // 图例
        let legend = lineChartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.textColor = .systemGray
    }
    
    private func loadLineChartData() {
        var entries: [ChartDataEntry] = []
        
        for i in 0..<50 {
            let value = Double.random(in: 20...100)
            entries.append(ChartDataEntry(x: Double(i), y: value))
        }
        
        let set = LineChartDataSet(entries: entries, label: "折线数据")
        set.mode = .cubicBezier  // 曲线模式
        set.drawCirclesEnabled = false
        set.lineWidth = 2
        set.setColor(.systemBlue)
        set.fillColor = .systemBlue
        set.fillAlpha = 0.1
        set.drawFilledEnabled = true  // 填充区域
        set.drawValuesEnabled = false
        
        let data = LineChartData(dataSet: set)
        lineChartView.data = data
        
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}
