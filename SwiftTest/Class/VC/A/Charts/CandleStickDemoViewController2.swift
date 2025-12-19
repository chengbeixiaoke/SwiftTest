//
//  CandleStickDemoViewController2.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/9.
//

import UIKit
import CoreGraphics

class CandleStickDemoViewController2: BaseViewController {
    private var klineView: KLineChartViewXX!
    private var dataSource: MockKLineDataSource!
    private var statusLabel: UILabel!
    private var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKLineView()
        loadInitialData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "无限滚动K线图Demo"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: 50, width: view.bounds.width, height: 30)
        view.addSubview(titleLabel)
        
        // 状态标签
        statusLabel = UILabel()
        statusLabel.text = "准备中..."
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .gray
        statusLabel.frame = CGRect(x: 0, y: 85, width: view.bounds.width, height: 20)
        view.addSubview(statusLabel)
        
        // 操作说明
        let instructionLabel = UILabel()
        instructionLabel.text = "操作说明：\n• 拖拽：左右滑动查看数据\n• 捏合：缩放K线图\n• 长按：显示详细信息\n• 双击：重置视图\n• 拖动到边界：加载更多数据"
        instructionLabel.font = UIFont.systemFont(ofSize: 12)
        instructionLabel.textAlignment = .left
        instructionLabel.textColor = .darkGray
        instructionLabel.numberOfLines = 0
        instructionLabel.frame = CGRect(x: 20, y: 110, width: view.bounds.width - 40, height: 80)
        view.addSubview(instructionLabel)
        
        // 加载指示器
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = CGPoint(x: view.bounds.width/2, y: 200)
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        // 控制按钮
        setupControlButtons()
    }
    
    private func setupControlButtons() {
        let buttonHeight: CGFloat = 40
        let buttonWidth: CGFloat = 120
        let spacing: CGFloat = 20
        let startY = view.bounds.height - 100
        
        // 重置按钮
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("重置视图", for: .normal)
        resetButton.backgroundColor = .systemOrange
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.frame = CGRect(x: spacing, y: startY, width: buttonWidth, height: buttonHeight)
        resetButton.addTarget(self, action: #selector(resetView), for: .touchUpInside)
        view.addSubview(resetButton)
        
        // 跳转到最新
        let jumpToLatestButton = UIButton(type: .system)
        jumpToLatestButton.setTitle("跳转到最新", for: .normal)
        jumpToLatestButton.backgroundColor = .systemBlue
        jumpToLatestButton.setTitleColor(.white, for: .normal)
        jumpToLatestButton.layer.cornerRadius = 8
        jumpToLatestButton.frame = CGRect(x: view.bounds.width - buttonWidth - spacing,
                                         y: startY,
                                         width: buttonWidth,
                                         height: buttonHeight)
        jumpToLatestButton.addTarget(self, action: #selector(jumpToLatest), for: .touchUpInside)
        view.addSubview(jumpToLatestButton)
    }
    
    private func setupKLineView() {
        let klineHeight: CGFloat = 500
        let klineY: CGFloat = 200
        
        klineView = KLineChartViewXX(frame: CGRect(x: 0, y: klineY,
                                                       width: view.bounds.width,
                                                       height: klineHeight))
        
        // 配置
        let config = KLineConfiguration()
        config.showMA = false
        config.showVolume = true
        config.showCrosshair = true
        config.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        config.gridColor = UIColor(white: 0.9, alpha: 1.0)
        klineView.updateConfig(config)
        
        // 设置数据源
        dataSource = MockKLineDataSource()
        klineView.setDataSource(dataSource)
        
        view.addSubview(klineView)
    }
    
    private func loadInitialData() {
        loadingIndicator.startAnimating()
        statusLabel.text = "加载初始数据..."
        
        // 从数据源获取初始数据
        let initialData = dataSource.getInitialData(count: 100)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadingIndicator.stopAnimating()
            self.klineView.setKLineData(initialData)
            self.statusLabel.text = "已加载 \(initialData.count) 条K线数据"
        }
    }
    
    @objc private func resetView() {
        klineView.resetView()
        statusLabel.text = "视图已重置"
    }
    
    @objc private func jumpToLatest() {
        // 这里可以添加跳转到最新数据的逻辑
        statusLabel.text = "跳转到最新数据..."
        
        // 模拟加载最新数据
        let latestDate = Date()
        dataSource.loadRecentData(after: latestDate, count: 100) { [weak self] newData in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !newData.isEmpty {
                    self.klineView.setKLineData(newData)
                    self.statusLabel.text = "已跳转到最新数据 (\(newData.count)条)"
                } else {
                    self.statusLabel.text = "已经是最新数据"
                }
            }
        }
    }
    
    // MARK: - 设备旋转处理
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { _ in
            // 调整K线图大小
            let klineHeight: CGFloat = 500
            let klineY: CGFloat = 200
            
            self.klineView.frame = CGRect(x: 0, y: klineY,
                                         width: size.width,
                                         height: klineHeight)
            self.klineView.setNeedsDisplay()
        }
    }
}
