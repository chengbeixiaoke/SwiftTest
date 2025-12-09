//
//  AnimatedLineGraphChartView.swift
//  SavoSecuritiesModule
//
//  Created by yyw on 2025/12/5.
//

import UIKit

public class AnimatedLineGraphChartView: BaseView {
    private let lineLayer = CAShapeLayer()
    private var points: [CGPoint] = []
    
    // 容器layer，用于实现整体左移
    private let contentLayer = CALayer()
    private var animationDuration: CFTimeInterval = 1.0
    private var pointSpacing: CGFloat = 2.0
    
    public var lineWidth: CGFloat = 1.0 {
        didSet {
            lineLayer.lineWidth = lineWidth
        }
    }
    public var strokeColor: UIColor = .Line_037F5F {
        didSet {
            lineLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    init(frame: CGRect,
         lineWidth: CGFloat = 1.0,
         pointSpacing: CGFloat = 2.0,
         animationDuration: CFTimeInterval = 1.0)
    {
        self.lineWidth = lineWidth
        self.pointSpacing = pointSpacing
        self.animationDuration = animationDuration
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // 配置容器
        contentLayer.frame = self.bounds
        layer.addSublayer(contentLayer)
        
        // 配置折线图层
        lineLayer.frame = contentLayer.bounds
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.lineWidth = lineWidth
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        lineLayer.strokeEnd = 0.0 // 初始不显示
        contentLayer.addSublayer(lineLayer)
    }
    
    public func setupPoints(_ points_: [CGPoint]) {
        points_.forEach { point in
            let newX = points.isEmpty ? 0 : (points.last!.x + pointSpacing)
            let newPoint = CGPoint(x: newX, y: point.y)
            points.append(newPoint)
            updateLinePath()
        }
        
        startDrawingAnimation()
    }

    /// 开始绘制动画（首次）
    private func startDrawingAnimation() {
        guard !points.isEmpty else { return }
        
        lineLayer.strokeEnd = 0.0
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = animationDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        lineLayer.add(animation, forKey: "lineDraw")
        
        // 动画结束后，strokeEnd需要保持为1
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.lineLayer.strokeEnd = 1.0
            self.lineLayer.removeAnimation(forKey: "lineDraw")
        }
        
        guard let lastPoint = points.last else { return }
        let lastPointInView = contentLayer.convert(lastPoint, to: layer)
        if lastPointInView.x > bounds.width {
            let offset = lastPointInView.x - bounds.width
            self.contentLayer.frame.origin.x -= offset
        }
    }
    
    private func updateLinePath() {
        guard points.count > 0 else { return }
        
        let path = UIBezierPath()
        let maxY = points.max(by: {$0.y < $1.y})!.y
        
        let _points = points.map { point in
            return CGPoint(x: point.x, y: point.y / maxY * bounds.height)
        }
        
        guard let firstPoint = _points.first else { return }
        
        path.move(to: firstPoint)
        for point in _points.dropFirst() {
            path.addLine(to: point)
        }
        
        lineLayer.path = path.cgPath
    }
}

extension AnimatedLineGraphChartView {
    public func addDataPoint(point: CGPoint) {
        let newX = points.isEmpty ? 0 : (points.last!.x + pointSpacing)
        let newPoint = CGPoint(x: newX, y: point.y)
        points.append(newPoint)
        updateLinePath()
        if newX > bounds.width {
            updateChartScroll()
        }
    }
    
    private func updateChartScroll() {
        guard let lastPoint = points.last else { return }
        let lastPointInView = contentLayer.convert(lastPoint, to: layer)
        if lastPointInView.x > bounds.width {
            let offset = lastPointInView.x - bounds.width
            UIView.animate(withDuration: 0.25) {
                self.contentLayer.frame.origin.x -= offset
            }
        }
    }
}
