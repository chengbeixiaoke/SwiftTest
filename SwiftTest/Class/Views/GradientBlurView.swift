//
//  GradientBlurView.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/14.
//

import UIKit

open class TranslucentBlurView: UIView {
    private var animator: UIViewPropertyAnimator?
    
    public var fractionComplete: CGFloat = 0.2
    {
        didSet { update() }
    }
    
    private var blurView: UIVisualEffectView?
    private var style: UIBlurEffect.Style = .systemMaterial
    public init(frame: CGRect, style: UIBlurEffect.Style)
    {
        super.init(frame: frame)
        self.style = style
        
        update()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update()
    {
        blurView?.removeFromSuperview()
        blurView = nil
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
        
        let blurView = UIVisualEffectView()
        blurView.frame = bounds
        addSubview(blurView)
                
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 0.8, 1.0]
        blurView.layer.mask = gradientLayer
        
        let view = UIView(frame: blurView.bounds)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        blurView.contentView.addSubview(view)

        let animator = UIViewPropertyAnimator(duration: 0, curve: .linear) { [weak self] in
            guard let weakSelf = self else { return }
            blurView.effect = UIBlurEffect(style: weakSelf.style)
        }
        animator.fractionComplete = fractionComplete
        animator.pauseAnimation()
        
        self.blurView = blurView
        self.animator = animator
    }
    
    @objc private func appWillResignActive() {
        animator?.pauseAnimation()
    }

    @objc private func appWillEnterForeground() {
        update()
    }
}


open class GradientBlurView: UIVisualEffectView {
    public var startColor: UIColor = .black
    {
        didSet { updateGradient() }
    }
    
    public var endColor: UIColor = .clear
    {
        didSet { updateGradient() }
    }
    
    public var direction: GradientDirection = .topToBottom
    {
        didSet { updateGradient() }
    }
    
    public enum GradientDirection
    {
        case topToBottom
        case bottomToTop
        case leftToRight
        case rightToLeft
    }
    
    private var gradientLayer: CAGradientLayer!
    
    override init(effect: UIVisualEffect? = UIBlurEffect(style: .regular))
    {
        super.init(effect: effect)
        setupGradient()
    }
    
    public required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient()
    {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: effect as! UIBlurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = CGRect(x: 0, y: 0, width: WidthScreen, height: UIScale(200))
        contentView.addSubview(vibrancyView)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        layer.mask = gradientLayer
        updateGradient()
    }
    
    private func updateGradient()
    {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        switch direction {
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
