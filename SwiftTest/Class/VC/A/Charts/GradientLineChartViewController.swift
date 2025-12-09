//
//  GradientLineChartViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/29.
//

import UIKit
import Charts

class GradientLineChartViewController: BaseViewController {
    // MARK: - 属性
    private let chartView = LineChartView()
    private var allDataEntries: [ChartDataEntry] = [] // 存储所有历史数据
    private let displayCount = 20 // 屏幕上固定显示20个点
    private var timer: Timer?
    
    // 新增：滑动相关属性
    private var currentDisplayStartIndex: Int = 0 // 当前显示的第一个点在allDataEntries中的索引
    private var panStartX: CGFloat = 0 // 手势开始时的X坐标
    private var lastTranslationX: CGFloat = 0 // 上次的平移量（用于累积计算）
    private var isDragging = false // 是否正在拖动
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupChart()
        setupGesture() // 新增：设置手势
        loadInitialData()
        startAutoUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoUpdate()
    }
    
    // MARK: - 新增：手势设置
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        chartView.addGestureRecognizer(panGesture)
        
        // 同时允许图表本身的拖拽（用于缩放等）
        chartView.dragEnabled = true
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: chartView)
        
        switch gesture.state {
        case .began:
            isDragging = true
            panStartX = translation.x
            lastTranslationX = 0
            
        case .changed:
            // 计算本次手势的X轴增量
            let deltaX = translation.x - lastTranslationX
            lastTranslationX = translation.x
            
            // 根据拖动距离计算应该滚动多少个数据点
            // 这里假设拖动整个图表宽度相当于滚动displayCount个点
            let chartWidth = chartView.bounds.width
            let pointsPerScreen = CGFloat(displayCount)
            let pointsToScroll = (deltaX / chartWidth) * pointsPerScreen
            
            // 更新显示起始索引（限制在有效范围内）
            let newStartIndex = currentDisplayStartIndex - Int(pointsToScroll)
            currentDisplayStartIndex = min(max(0, newStartIndex), max(0, allDataEntries.count - displayCount))
            
            // 立即更新显示
            updateDisplayedData()
            
        case .ended, .cancelled:
            isDragging = false
            // 可选：添加惯性滚动效果
            let velocity = gesture.velocity(in: chartView)
            if abs(velocity.x) > 100 {
                addInertialScroll(with: velocity.x)
            }
            
        default:
            break
        }
    }
    
    // 新增：惯性滚动
    private func addInertialScroll(with velocityX: CGFloat) {
        let deceleration: CGFloat = 0.9
        var currentVelocity = velocityX
        let chartWidth = chartView.bounds.width
        let pointsPerScreen = CGFloat(displayCount)
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // 计算这一帧应该滚动的点数
            let pointsToScroll = (currentVelocity / chartWidth * 0.016) * pointsPerScreen
            let newStartIndex = self.currentDisplayStartIndex - Int(pointsToScroll)
            self.currentDisplayStartIndex = min(max(0, newStartIndex), max(0, self.allDataEntries.count - self.displayCount))
            
            self.updateDisplayedData()
            
            // 减速
            currentVelocity *= deceleration
            
            // 速度足够小或到达边界时停止
            if abs(currentVelocity) < 5 ||
               self.currentDisplayStartIndex == 0 ||
               self.currentDisplayStartIndex == max(0, self.allDataEntries.count - self.displayCount) {
                timer.invalidate()
            }
        }
    }
    
    // MARK: - 数据管理（修改后的版本）
    private func loadInitialData() {
        // 生成足够多的初始数据（比如50个点）
        let initialCount = 50
        for i in 0..<initialCount {
            let yValue = Double.random(in: 30...70)
            allDataEntries.append(ChartDataEntry(x: Double(i), y: yValue))
        }
        
        // 初始显示最后20个点
        currentDisplayStartIndex = max(0, allDataEntries.count - displayCount)
        updateDisplayedData()
    }
    
    // 修改：定时添加新点的方法
    private func addNewDataPoint() {
        guard !isDragging else {
            // 如果用户正在手动拖动，暂停自动添加
            return
        }
        
        // 生成新数据点
        let newY = generateRealisticYValue()
        let lastX = allDataEntries.last?.x ?? 0
        let newEntry = ChartDataEntry(x: lastX + 1, y: newY)
        allDataEntries.append(newEntry)
        
        // 如果用户没有在查看历史数据（即显示的是最新数据），则自动滚动到最新
        let isViewingLatest = currentDisplayStartIndex >= max(0, allDataEntries.count - displayCount)
        if isViewingLatest {
            currentDisplayStartIndex = max(0, allDataEntries.count - displayCount)
        }
        
        updateDisplayedData()
        
        print("总数据量: \(allDataEntries.count), 显示起始索引: \(currentDisplayStartIndex)")
    }
    
    // 新增：更新显示的数据窗口
    private func updateDisplayedData() {
        // 确保有足够的数据
        guard allDataEntries.count > 0 else { return }
        
        // 计算当前应该显示的数据段
        let start = currentDisplayStartIndex
        let end = min(start + displayCount, allDataEntries.count)
        
        guard start < end else { return }
        
        let displayedEntries = Array(allDataEntries[start..<end])
        
        // 重新计算X值，使其在0到displayCount-1之间（为了固定X轴显示）
        let normalizedEntries = displayedEntries.enumerated().map { index, entry in
            return ChartDataEntry(x: Double(index), y: entry.y)
        }
        
        // 更新图表
        updateChart(with: normalizedEntries)
    }
    
    // 修改：更新图表的方法，接收要显示的数据
    private func updateChart(with entries: [ChartDataEntry]) {
        let dataSet = LineChartDataSet(entries: entries, label: "实时数据")
        
        // 线条样式
        dataSet.colors = [UIColor.systemBlue]
        dataSet.lineWidth = 2.5
        dataSet.mode = .linear
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 3
        dataSet.circleColors = [UIColor.systemBlue]
        dataSet.drawCircleHoleEnabled = false
        
        // 高亮设置
        dataSet.highlightColor = .systemOrange
        dataSet.highlightLineWidth = 1.5
        dataSet.drawValuesEnabled = false
        
        // 渐变填充
        let gradientColors = [
            UIColor.systemBlue.withAlphaComponent(0.6).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.1).cgColor
        ]
        if let gradient = CGGradient(
            colorsSpace: nil,
            colors: gradientColors as CFArray,
            locations: nil
        ) {
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
            dataSet.drawFilledEnabled = true
        }
        
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
        
        // 更新显示范围指示
        updateRangeIndicator()
    }
    
    // 新增：显示当前查看范围的指示器
    private func updateRangeIndicator() {
        let totalPoints = allDataEntries.count
        if totalPoints > displayCount {
            let percentage = Double(currentDisplayStartIndex) / Double(totalPoints - displayCount)
            let infoText = String(format: "查看范围: %d-%d (%.0f%%)",
                                currentDisplayStartIndex,
                                min(currentDisplayStartIndex + displayCount - 1, totalPoints - 1),
                                percentage * 100)
            
            // 可以在这里更新一个状态标签
            print(infoText)
        }
    }
    
    private func generateRealisticYValue() -> Double {
        let lastY = allDataEntries.last?.y ?? 50
        let change = Double.random(in: -8...8)
        return max(20, min(80, lastY + change))
    }
    
    // MARK: - 定时器控制
    private func startAutoUpdate() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.addNewDataPoint()
        }
    }
    
    private func stopAutoUpdate() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - 界面设置（保持你之前的样式）
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "可滑动的实时数据流"
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartView)
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // 添加操作说明标签
        let instructionLabel = UILabel()
        instructionLabel.text = "• 每1秒自动添加新点\n• 水平拖动查看历史数据\n• 松开后可惯性滚动"
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = .secondaryLabel
        instructionLabel.font = .systemFont(ofSize: 14)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupChart() {
        // 保持你之前的图表配置
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.legend.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .secondaryLabel
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = UIColor.systemGray5
        xAxis.axisLineColor = .systemGray3
        xAxis.granularity = 1
        xAxis.labelCount = 6
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = Double(displayCount - 1)
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = .secondaryLabel
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor.systemGray5
        leftAxis.axisLineColor = .systemGray3
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        leftAxis.granularity = 20
        
        chartView.rightAxis.enabled = false
        chartView.chartDescription.enabled = false
    }
}
