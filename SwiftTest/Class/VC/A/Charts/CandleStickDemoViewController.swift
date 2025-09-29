//
//  CandleStickDemoViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/28.
//

import UIKit
import Charts

class CandleStickDemoViewController: BaseViewController {
    
    // MARK: - UI Components
    private let chartView = CandleStickChartView()
    private let timeSegmentedControl = UISegmentedControl(items: ["1D", "1W", "1M", "1Y"])
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Data
    private var klineData: [CandleChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupChart()
        loadData()
    }
    
    private func setupUI() {
        title = "K线图 Demo"
        view.backgroundColor = .systemBackground
        
        // 时间选择器
        timeSegmentedControl.selectedSegmentIndex = 0
        timeSegmentedControl.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
        
        // 布局
        chartView.translatesAutoresizingMaskIntoConstraints = false
        timeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(chartView)
        view.addSubview(timeSegmentedControl)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            timeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            timeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            chartView.topAnchor.constraint(equalTo: timeSegmentedControl.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: chartView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: chartView.centerYAnchor)
        ])
        
        loadingIndicator.hidesWhenStopped = true
    }
    
    private func setupChart() {
        // 基础配置
        chartView.chartDescription.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.maxVisibleCount = 100
        chartView.pinchZoomEnabled = true
        chartView.drawGridBackgroundEnabled = false
        chartView.doubleTapToZoomEnabled = true
        chartView.legend.enabled = false
        
        // X轴配置
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = .systemGray4
        xAxis.labelTextColor = .systemGray
        xAxis.axisLineColor = .systemGray
        xAxis.granularity = 1
        xAxis.labelCount = 6
        xAxis.valueFormatter = DateAxisValueFormatter()
        
        // 左Y轴
        let leftAxis = chartView.leftAxis
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = .systemGray4
        leftAxis.labelTextColor = .systemGray
        leftAxis.axisLineColor = .systemGray
        leftAxis.labelCount = 6
        leftAxis.drawZeroLineEnabled = false
        leftAxis.spaceTop = 0.1
        leftAxis.spaceBottom = 0.1
        
        // 右Y轴
        let rightAxis = chartView.rightAxis
        rightAxis.drawGridLinesEnabled = false
        rightAxis.labelTextColor = .systemGray
        rightAxis.axisLineColor = .systemGray
        rightAxis.labelCount = 6
        
        // 图例
        let legend = chartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.textColor = .systemGray
        
        // 添加标记器
        let marker = ChartMarker()
        marker.chartView = chartView
        chartView.marker = marker
    }
    
    @objc private func timeRangeChanged(_ sender: UISegmentedControl) {
        loadData()
    }
    
    private func loadData() {
        loadingIndicator.startAnimating()
        
        // 模拟网络请求延迟
        DispatchQueue.global().async {
            let mockData = self.generateMockKLineData(count: 100)
            
            DispatchQueue.main.async {
                self.klineData = mockData
                self.updateChart()
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    private func generateMockKLineData(count: Int) -> [CandleChartDataEntry] {
        var data: [CandleChartDataEntry] = []
        var lastClose = 100.0 // 起始价格
        
        for i in 0..<count {
            let volatility = Double.random(in: 1...5) // 波动率
            let change = Double.random(in: -volatility...volatility)
            
            let open = lastClose
            let close = open + change
            let high = max(open, close) + Double.random(in: 0...volatility/2)
            let low = min(open, close) - Double.random(in: 0...volatility/2)
            
            let entry = CandleChartDataEntry(
                x: Double(i),
                shadowH: high,
                shadowL: low,
                open: open,
                close: close,
                data: Date().addingTimeInterval(-Double((count - i) * 3600)) // 时间数据
            )
            
            data.append(entry)
            lastClose = close
        }
        
        return data
    }
    
    private func updateChart() {
        // 创建数据集
        let set = CandleChartDataSet(entries: klineData, label: "价格")
        
        // 颜色配置
        set.increasingColor = .systemRed    // 涨颜色
        set.increasingFilled = true        // 实心
        set.decreasingColor = .systemGreen // 跌颜色
        set.decreasingFilled = true        // 实心
        set.neutralColor = .systemBlue     // 平盘颜色
        
        set.shadowColor = .label           // 影线颜色
        set.shadowWidth = 1.0              // 影线宽度
        set.barSpace = 0.3                 // 蜡烛间距
        set.drawValuesEnabled = false      // 不显示数值
        
        // 设置阴影颜色同实体颜色
        set.shadowColorSameAsCandle = true
        
        // 创建数据
        let data = CandleChartData(dataSet: set)
        data.setValueFont(.systemFont(ofSize: 10))
        data.setValueTextColor(.label)
        
        // 设置数据
        chartView.data = data
        
        // 添加动画
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}

// MARK: - 自定义X轴数值格式化器
class DateAxisValueFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date().addingTimeInterval(-Double(100 - Int(value)) * 3600)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - 自定义标记器
class ChartMarker: MarkerView {
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        guard let candleEntry = entry as? CandleChartDataEntry else { return }
        
        let text = String(format: "O:%.2f H:%.2f\nL:%.2f C:%.2f",
                         candleEntry.open, candleEntry.high,
                         candleEntry.low, candleEntry.close)
        label.text = text
    }
}
