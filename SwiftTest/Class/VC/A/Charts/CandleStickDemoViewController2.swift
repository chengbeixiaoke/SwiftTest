//
//  CandleStickDemoViewController2.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/9.
//

import UIKit
import CoreGraphics

class CandleStickDemoViewController2: BaseViewController {
    
    private var klineView: KLineChartView!
    private var dataCountLabel: UILabel!
    private var operationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "股票K线图Demo"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: 50, width: view.bounds.width, height: 30)
        view.addSubview(titleLabel)
        
        // 操作说明
        operationLabel = UILabel()
        operationLabel.text = "操作：拖拽滑动 | 捏合缩放 | 长按查看详情 | 双击重置"
        operationLabel.font = UIFont.systemFont(ofSize: 12)
        operationLabel.textAlignment = .center
        operationLabel.textColor = .gray
        operationLabel.frame = CGRect(x: 0, y: 85, width: view.bounds.width, height: 20)
        view.addSubview(operationLabel)
        
        // 数据量显示
        dataCountLabel = UILabel()
        dataCountLabel.font = UIFont.systemFont(ofSize: 14)
        dataCountLabel.textAlignment = .center
        dataCountLabel.frame = CGRect(x: 0, y: 110, width: view.bounds.width, height: 20)
        view.addSubview(dataCountLabel)
        
        // 创建K线图
        klineView = KLineChartView(frame: CGRect(x: 0, y: 140,
                                                 width: view.bounds.width,
                                                 height: 500))
        view.addSubview(klineView)
        
        // 控制按钮
        setupControlButtons()
    }
    
    private func setupControlButtons() {
        let buttonHeight: CGFloat = 40
        let buttonWidth: CGFloat = 100
        let spacing: CGFloat = 10
        let startY = klineView.frame.maxY + 20
        
        // 加载更多数据按钮
        let loadMoreButton = UIButton(type: .system)
        loadMoreButton.setTitle("加载更多", for: .normal)
        loadMoreButton.backgroundColor = .systemBlue
        loadMoreButton.setTitleColor(.white, for: .normal)
        loadMoreButton.layer.cornerRadius = 8
        loadMoreButton.frame = CGRect(x: spacing, y: startY, width: buttonWidth, height: buttonHeight)
        loadMoreButton.addTarget(self, action: #selector(loadMoreData), for: .touchUpInside)
        view.addSubview(loadMoreButton)
        
        // 重置按钮
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("重置视图", for: .normal)
        resetButton.backgroundColor = .systemOrange
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.frame = CGRect(x: view.bounds.width - buttonWidth - spacing,
                                   y: startY,
                                   width: buttonWidth,
                                   height: buttonHeight)
        resetButton.addTarget(self, action: #selector(resetView), for: .touchUpInside)
        view.addSubview(resetButton)
    }
    
    private func loadData() {
        // 生成10000个示例数据
        let count = 10000
        let data = generateSampleData(count: count)
        klineView.setKLineData(data)
        
        dataCountLabel.text = "数据量：\(count) 条K线"
    }
    
    @objc private func loadMoreData() {
        // 模拟加载更多数据
        let moreData = generateSampleData(count: 2000)
        // 在实际应用中，这里应该是追加数据到现有数据
        // klineView.appendKLineData(moreData)
        
        let alert = UIAlertController(title: "提示",
                                      message: "已生成2000条新数据",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func resetView() {
        klineView.resetView()
    }
    
    private func generateSampleData(count: Int) -> [KLineData] {
        var data: [KLineData] = []
        var lastClose: CGFloat = 100.0
        
        let startDate = Date().addingTimeInterval(-Double(count) * 24 * 3600)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        
        for i in 0..<count {
            let date = Date(timeInterval: TimeInterval(i) * 24 * 3600, since: startDate)
            let dateString = dateFormatter.string(from: date)
            
            // 模拟股票价格变化
            let volatility: CGFloat = 0.02 // 波动率
            let change = lastClose * volatility * (CGFloat.random(in: -1...1))
            let open = lastClose
            let close = open + change
            
            // 确保高价和低价合理
            let maxChange = abs(change) * 1.5
            let high = max(open, close) + CGFloat.random(in: 0...maxChange)
            let low = min(open, close) - CGFloat.random(in: 0...maxChange)
            
            // 成交量与价格变化相关
            let baseVolume: CGFloat = 10000
            let volume = baseVolume * (1 + abs(change)/open * 10) * CGFloat.random(in: 0.8...1.2)
            
            let klineData = KLineData(
                open: open,
                close: close,
                high: high,
                low: low,
                volume: volume,
                date: dateString,
                timestamp: date.timeIntervalSince1970
            )
            
            data.append(klineData)
            lastClose = close
        }
        
        return data
    }
}
