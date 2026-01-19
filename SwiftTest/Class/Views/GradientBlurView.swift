//
//  GradientBlurView.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/14.
//

import UIKit

open class TranslucentBlurView: UIView {
    private var animator: UIViewPropertyAnimator?
    
    public var fractionComplete: CGFloat = 0.08
    {
        didSet { resetDraw() }
    }
    
    public var needMaskView: Bool = false
    public var maskAlpha: CGFloat = 0.5
    public var gradientLayerAlpha: CGFloat = 1.0
    
    // locations要么分两段，要么分3段，其他没适配
    public var locations: [NSNumber] = [0.0, 1.0]
    
    private var blurView: UIVisualEffectView?
    private var style: UIBlurEffect.Style = .systemMaterial
    public init(frame: CGRect, style: UIBlurEffect.Style)
    {
        super.init(frame: frame)
        self.style = style
        
        resetDraw()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func resetDraw()
    {
        blurView?.removeFromSuperview()
        blurView = nil
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
        
        let blurView = UIVisualEffectView()
        blurView.frame = bounds
        addSubview(blurView)
                
        
        var colors: [UIColor] = [UIColor.white, UIColor.clear]
        if locations.count == 3 {
            colors = [UIColor.white.withAlphaComponent(gradientLayerAlpha),
                      UIColor.white.withAlphaComponent(gradientLayerAlpha),
                      UIColor.clear]
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map({$0.cgColor})
        gradientLayer.locations = locations
        blurView.layer.mask = gradientLayer
        
        if needMaskView {
            let view = UIView(frame: blurView.bounds)
            view.backgroundColor = UIColor.ColorWhite.withAlphaComponent(maskAlpha)
            blurView.contentView.addSubview(view)
        }
        
        let animator = UIViewPropertyAnimator(duration: 0, curve: .linear) { [weak self] in
            guard let weakSelf = self else { return }
            blurView.effect = UIBlurEffect(style: weakSelf.style)
        }
        animator.startAnimation()
        animator.pauseAnimation()
        animator.fractionComplete = fractionComplete
        
        self.blurView = blurView
        self.animator = animator
    }
    
    @objc private func appWillResignActive() {
        animator?.pauseAnimation()
    }

    @objc private func appWillEnterForeground() {
        resetDraw()
    }
    
    deinit {
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
    }
}

@available(iOS 26.0, *)
open class TranslucentGlassBlurView: UIView {
    private var animator: UIViewPropertyAnimator?
    
    public var fractionComplete: CGFloat = 1.1
    {
        didSet { resetDraw() }
    }

    private var blurView: UIVisualEffectView?
    private var style: UIGlassEffect.Style = .clear
    public init(frame: CGRect, style: UIGlassEffect.Style)
    {
        super.init(frame: frame)
        self.style = style
        
        resetDraw()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func resetDraw()
    {
        blurView?.removeFromSuperview()
        blurView = nil
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
        
        let blurView = UIVisualEffectView()
        blurView.frame = bounds
        blurView.effect = UIGlassEffect(style: style)
        addSubview(blurView)
        
        let animator = UIViewPropertyAnimator(duration: 0, curve: .linear) { [weak self] in
            guard let weakSelf = self else { return }
            blurView.effect = UIGlassEffect(style: weakSelf.style)
        }
        animator.startAnimation()
        animator.pauseAnimation()
        animator.fractionComplete = fractionComplete
        
        self.blurView = blurView
        self.animator = animator
    }
    
    @objc private func appWillResignActive() {
        animator?.pauseAnimation()
    }

    @objc private func appWillEnterForeground() {
        resetDraw()
    }
    
    deinit {
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
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

@available(iOS 26.0, *)
open class RegularGlassBlurView: UIVisualEffectView {
    
    init()
    {
        let xx = UIGlassEffect(style: .regular)
        xx.isInteractive = true
        xx.tintColor = UIColor.white.withAlphaComponent(0.2)
        super.init(effect: xx)
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
            self.wyy_traitCollectionDidChange(previousTraitCollection)
        }
    }
    
    public required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    open func wyy_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            printLog("[RegularGlassBlurView]: \(previousTraitCollection?.userInterfaceStyle)")
        }
    }
}
