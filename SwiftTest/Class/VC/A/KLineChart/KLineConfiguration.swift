//
//  KLineConfiguration.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/9.
//

import UIKit

class KLineConfiguration: NSObject {
    
    // MARK: 颜色配置
    // 上涨颜色
    var upColor: UIColor = UIColor(red: 230/255, green: 40/255, blue: 40/255, alpha: 1.0)
    // 下跌颜色
    var downColor: UIColor = UIColor(red: 40/255, green: 170/255, blue: 60/255, alpha: 1.0)
    
    //
    var gridColor: UIColor = UIColor.lightGray
    
    // 文案颜色
    var textColor: UIColor = .black
    
    // 背景色
    var backgroundColor: UIColor = .white
    
    //
    var crosshairColor: UIColor = UIColor.blue.withAlphaComponent(0.7)
    
    //
    var selectedColor: UIColor = UIColor.yellow.withAlphaComponent(0.2)
    
    // MARK: 显示配置
    // 显示网格
    var showGrid: Bool = true
    
    // 显示成交量
    var showVolume: Bool = true
    
    // 显示
    var showCrosshair: Bool = true
    
    // 显示MA
    var showMA: Bool = true
    
    // 显示时间
    var showDateLabel: Bool = true
    
    // MARK: K线配置
    // 最小线宽
    var minKLineWidth: CGFloat = 1
    // 最大线宽
    var maxKLineWidth: CGFloat = 30
    // 默认线宽
    var defaultKLineWidth: CGFloat = 8
    // K线间隔
    var klineSpacing: CGFloat = 2
    
    // MARK: 指标配置
    var maPeriods: [Int] = [5, 10, 20]
    var maColors: [UIColor] = [.orange, .purple, .cyan]
    
    // MARK: 边距配置
    var topMargin: CGFloat = 40
    var bottomMargin: CGFloat = 30
    var leftMargin: CGFloat = 70
    var rightMargin: CGFloat = 30
    var volumeHeight: CGFloat = 60
}
