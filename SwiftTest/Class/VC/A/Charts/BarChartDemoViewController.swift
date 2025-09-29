//
//  BarChartDemoViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/29.
//

import UIKit
import Charts

class BarChartDemoViewController: BaseViewController {
    
    private let barChartView = BarChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBarChart()
        loadBarChartData()
    }
    
    private func setupUI() {
        title = "柱状图 Demo"
        view.backgroundColor = .systemBackground
        
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barChartView)
        
        NSLayoutConstraint.activate([
            barChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            barChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            barChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            barChartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupBarChart() {
        barChartView.chartDescription.enabled = false
        barChartView.dragEnabled = true
        barChartView.setScaleEnabled(true)
        barChartView.pinchZoomEnabled = true
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBarShadowEnabled = false
        
        // X轴
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .systemGray
        xAxis.drawGridLinesEnabled = false
        xAxis.axisLineColor = .systemGray
        xAxis.labelCount = 12
        xAxis.granularity = 1
        xAxis.valueFormatter = MonthAxisValueFormatter()
        
        // 左Y轴
        let leftAxis = barChartView.leftAxis
        leftAxis.labelTextColor = .systemGray
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = .systemGray4
        leftAxis.axisLineColor = .systemGray
        leftAxis.labelCount = 6
        leftAxis.axisMinimum = 0
        
        // 右Y轴
        let rightAxis = barChartView.rightAxis
        rightAxis.enabled = false
        
        // 图例
        let legend = barChartView.legend
        legend.enabled = false
    }
    
    private func loadBarChartData() {
        var entries: [BarChartDataEntry] = []
        let months = ["1月", "2月", "3月", "4月", "5月", "6月",
                     "7月", "8月", "9月", "10月", "11月", "12月"]
        
        for i in 0..<12 {
            let value = Double.random(in: 50...200)
            entries.append(BarChartDataEntry(x: Double(i), y: value, data: months[i]))
        }
        
        let set = BarChartDataSet(entries: entries, label: "月度数据")
        set.colors = ChartColorTemplates.material()
        set.drawValuesEnabled = true
        set.valueTextColor = .label
        set.valueFont = .systemFont(ofSize: 10)
        
        let data = BarChartData(dataSet: set)
        data.barWidth = 0.7  // 柱状图宽度
        
        barChartView.data = data
        barChartView.animate(yAxisDuration: 1.0)
    }
}

class MonthAxisValueFormatter: AxisValueFormatter {
    private let months = ["1月", "2月", "3月", "4月", "5月", "6月",
                         "7月", "8月", "9月", "10月", "11月", "12月"]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value) % months.count
        return months[index]
    }
}
