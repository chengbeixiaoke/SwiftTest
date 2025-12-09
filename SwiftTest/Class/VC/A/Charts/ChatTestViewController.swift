//
//  ChatTestViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/9.
//

import UIKit
import SnapKit

class ChatTestViewController: BaseViewController {
    let chatView = ChatTestView(frame: .zero)
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(chatView)
        chatView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        start()
    }
    
    func start() {
        stop()
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { [weak self] _ in
            guard let weakSelf = self else { return }
            let randomY = CGFloat.random(in: -100...100)
            weakSelf.chatView.points.append(CGPoint(x: CGFloat(weakSelf.chatView.points.count) * UIScale(10), y: randomY + 300))
            weakSelf.chatView.setNeedsDisplay()
        })
    }
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
    }
}

class ChatTestView: BaseView {
    var points: [CGPoint] = {
        var points: [CGPoint] = []
        for i in 0..<300 {
            let randomY = CGFloat.random(in: -100...100)
            points.append(CGPoint(x: CGFloat(points.count) * UIScale(10), y: randomY + 300))
        }
        return points
    }()
    
    var xxxxx: CGFloat = 0
    private var currentScale: CGFloat = 1.0
    private var initialScale: CGFloat = 1.0
    
    // 惯性相关
    private var velocity: CGFloat = 0
    private var lastTranslationTime: TimeInterval = 0
    private var displayLink: CADisplayLink?
    private var decelerationRate: CGFloat = 0.95
    private var minimumVelocity: CGFloat = 0.1
    
    // 缩放相关
    private var lastPinchScale: CGFloat = 1.0
    private var pinchCenter: CGPoint = .zero

    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupGestureRecognizers()
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGestureRecognizers() {
        // 平移手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        // 缩放手势
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)
        
        // 允许同时识别多个手势
        panGesture.delegate = self
        pinchGesture.delegate = self
    }
    
    @objc func handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            stopInertia()
            lastTranslationTime = CACurrentMediaTime()
            
        case .changed:
            let translation = pan.translation(in: self)
            let currentTime = CACurrentMediaTime()
            let deltaTime = CGFloat(currentTime - lastTranslationTime)
            
            if deltaTime > 0 {
                velocity = translation.x / deltaTime * 0.3
                lastTranslationTime = currentTime
            }
            
            xxxxx += translation.x
            applyBoundaryConstraints()
            setNeedsDisplay()
            pan.setTranslation(.zero, in: self)
            
        case .ended, .cancelled:
            startInertia()
            
        default:
            break
        }
    }
    
    @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began:
            initialScale = currentScale
            lastPinchScale = pinch.scale
            pinchCenter = pinch.location(in: self)
            stopInertia()
            
        case .changed:
            // 直接使用捏合手势的scale属性
            let scale = initialScale * pinch.scale
            let clampedScale = max(0.5, min(scale, 3.0))
            
            // 计算缩放比例
            let scaleRatio = clampedScale / currentScale
            
            // 计算缩放中心在内容坐标系中的位置
            let contentCenterX = (pinchCenter.x - xxxxx) / currentScale
            
            // 更新偏移量，使缩放围绕手势中心
            xxxxx = pinchCenter.x - contentCenterX * clampedScale
            
            // 更新缩放比例
            currentScale = clampedScale
            
            // 应用边界约束
            applyBoundaryConstraints()
            
            setNeedsDisplay()
            
        case .ended, .cancelled:
            // 如果缩放超出范围，添加弹性动画
            if currentScale < 0.6 {
                animateScale(to: 0.5)
            } else if currentScale > 2.9 {
                animateScale(to: 3.0)
            } else {
                // 轻微弹性效果
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                    self.applyBoundaryConstraints()
                    self.setNeedsDisplay()
                }
            }
            
        default:
            break
        }
    }
    
    private func animateScale(to targetScale: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.currentScale = targetScale
            
            // 缩放后重新计算居中
            self.centerLineIfNeeded()
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - 居中显示
    
    private func centerLineIfNeeded() {
        guard !points.isEmpty else { return }
        
        // 计算折线的总宽度
        let lineWidth = points.last!.x - points.first!.x
        let scaledLineWidth = lineWidth * currentScale
        
        // 如果折线比视图窄，则居中显示
        if scaledLineWidth <= bounds.width {
            let viewCenterX = bounds.width / 2
            let lineCenterX = scaledLineWidth / 2
            xxxxx = viewCenterX - lineCenterX
        }
    }
    
    private func applyBoundaryConstraints() {
        guard !points.isEmpty else { return }
        
        // 计算折线的实际宽度
        let lineWidth = points.last!.x - points.first!.x
        let scaledLineWidth = lineWidth * currentScale
        
        // 如果折线比视图窄，则居中显示
        if scaledLineWidth <= bounds.width {
            centerLineIfNeeded()
            return
        }
        
        // 如果折线比视图宽，则限制平移范围
        let minX = bounds.width - scaledLineWidth
        let maxX: CGFloat = 0
        
        xxxxx = min(max(xxxxx, minX), maxX)
    }
    
    // MARK: - 惯性动画
    
    private func startInertia() {
        guard abs(velocity) > minimumVelocity else {
            velocity = 0
            return
        }
        
        stopInertia()
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateInertia))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopInertia() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateInertia() {
        velocity *= decelerationRate
        
        if abs(velocity) < minimumVelocity {
            velocity = 0
            stopInertia()
            return
        }
        
        if let displayLink = displayLink {
            let deltaTime = CGFloat(displayLink.targetTimestamp - displayLink.timestamp)
            let movement = velocity * deltaTime * 0.5
            
            xxxxx += movement
            applyBoundaryConstraints()
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        printLog("[ChatTestView] draw(_ rect: CGRect)")
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        printLog("[ChatTestView] draw(_ layer: CALayer, in ctx: CGContext)")
        
        ctx.saveGState()
        defer { ctx.restoreGState() }
        
        ctx.clear(bounds)
        
        // 绘制白色背景
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(bounds)
        
        // 应用变换：先平移，再缩放
        ctx.translateBy(x: xxxxx, y: 0)
        ctx.scaleBy(x: currentScale, y: currentScale)
        
        // 绘制坐标轴
        drawAxes(in: ctx)
        
        // 绘制折线
        drawLine(in: ctx)
        
        // 添加缩放指示器
        drawScaleIndicator(in: ctx)
    }
    
    private func drawAxes(in ctx: CGContext) {
        // 绘制X轴（水平线）
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        ctx.setLineWidth(1.0 / currentScale)
        
        let yCenter = bounds.height / 2 / currentScale
        ctx.move(to: CGPoint(x: 0, y: yCenter))
        ctx.addLine(to: CGPoint(x: bounds.width / currentScale, y: yCenter))
        ctx.strokePath()
        
        // 绘制Y轴（垂直线）
        let xOffset = -xxxxx / currentScale
        ctx.move(to: CGPoint(x: xOffset, y: 0))
        ctx.addLine(to: CGPoint(x: xOffset, y: bounds.height / currentScale))
        ctx.strokePath()
    }
    
    private func drawLine(in ctx: CGContext) {
        guard let firstPoint = points.first else { return }
        
        let cubicPath = CGMutablePath()
        cubicPath.move(to: firstPoint)
        
        for point in points.dropFirst() {
            cubicPath.addLine(to: point)
        }
        
        ctx.beginPath()
        ctx.addPath(cubicPath)
        ctx.setStrokeColor(UIColor.systemBlue.cgColor)
        ctx.setLineWidth(2.0 / currentScale)
        ctx.strokePath()
        
        // 可选：绘制点标记
        drawPoint(firstPoint, in: ctx, color: .red)
        if let lastPoint = points.last {
            drawPoint(lastPoint, in: ctx, color: .green)
        }
    }
    
    private func drawPoint(_ point: CGPoint, in ctx: CGContext, color: UIColor) {
        let pointSize: CGFloat = 6.0 / currentScale
        let pointRect = CGRect(x: point.x - pointSize/2,
                              y: point.y - pointSize/2,
                              width: pointSize,
                              height: pointSize)
        
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: pointRect)
    }
    
    private func drawScaleIndicator(in ctx: CGContext) {
        // 保存当前变换状态
        ctx.saveGState()
        
        // 重置变换，使指示器固定在屏幕位置
        let transform = ctx.ctm
        ctx.concatenate(CGAffineTransform(
            a: transform.a, b: transform.b,
            c: transform.c, d: transform.d,
            tx: 0, ty: 0
        ))
        
        let indicatorText = String(format: "缩放: %.1fx", currentScale)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray,
            .backgroundColor: UIColor.white.withAlphaComponent(0.7)
        ]
        
        let attributedString = NSAttributedString(string: indicatorText, attributes: attributes)
        let stringSize = attributedString.size()
        
        let point = CGPoint(x: bounds.width - stringSize.width - 10,
                           y: bounds.height - stringSize.height - 10)
        
        UIGraphicsPushContext(ctx)
        attributedString.draw(at: point)
        UIGraphicsPopContext()
        
        ctx.restoreGState()
    }
    
    // MARK: - 重置方法
    
    func resetTransform() {
        UIView.animate(withDuration: 0.3) {
            self.currentScale = 1.0
            self.velocity = 0
            self.centerLineIfNeeded()
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - 工具方法
    
    func getTransformInfo() -> String {
        return String(format: "偏移: %.1f, 缩放: %.2fx", xxxxx, currentScale)
    }
    
    deinit {
        stopInertia()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ChatTestView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
