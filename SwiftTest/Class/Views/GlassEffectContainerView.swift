//
//  GlassEffectContainerView.swift
//  CashSAVO
//
//  Created by yyw on 2026/1/12.
//

import UIKit
import SnapKit

extension GlassEffectContainerView {
    public enum Style {
        case regular
        case clear
    }
}

open class GlassEffectContainerView: UIView {
    public var clickViewBlock: (()->())?
    
    public var glassEffectIsInteractive: Bool = true
    {
        didSet {
            if #available(iOS 26.0, *), let glassEffect = glassEffect as? UIGlassEffect {
                glassEffect.isInteractive = true
            }
        }
    }
    
    public var glassViewAlpha: CGFloat = 1.0
    {
        didSet {
            glassView?.alpha = glassViewAlpha
        }
    }
    
    public var glassViewCornerRadius: CGFloat = 0.0
    {
        didSet {
            glassView?.layer.cornerRadius = glassViewCornerRadius
        }
    }
    
    public var glassViewTintColor: UIColor = UIColor.clear
    {
        didSet {
            if #available(iOS 26.0, *), let glassEffect = glassEffect as? UIGlassEffect {
                glassEffect.tintColor = glassViewTintColor
                glassView?.effect = glassEffect
            }
        }
    }
    
    public var glassViewStyle: GlassEffectContainerView.Style = .regular
    {
        didSet {
            if #available(iOS 26.0, *) {
                let glassEffect = UIGlassEffect(style: glassViewStyle == .regular ? .regular : .clear)
                glassEffect.tintColor = glassViewTintColor
                glassEffect.isInteractive = glassEffectIsInteractive
                glassView?.effect = glassEffect
                self.glassEffect = glassEffect
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public var glassEffect: UIVisualEffect?
    public var glassView: UIVisualEffectView?
    private var button: UIButton = UIButton(frame: .zero)
    
    private func setupUI() {
        if #available(iOS 26.0, *) {
            let glassEffect = UIGlassEffect(style: .regular)
            glassEffect.isInteractive = glassEffectIsInteractive
            
            let glassView = UIVisualEffectView(effect: glassEffect)
            glassView.layer.cornerCurve = .continuous
            glassView.clipsToBounds = true
            addSubview(glassView)
            glassView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            self.glassEffect = glassEffect
            self.glassView = glassView
            
            glassView.contentView.addSubview(button)
            button.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            button.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        } else {
            addSubview(button)
            button.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            button.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func touchUpInside(_ sender: Any) {
        clickViewBlock?()
    }
    
    public func s_addSubview(_ view: UIView) {
        if #available(iOS 26.0, *) {
            glassView?.contentView.addSubview(view)
        } else {
            addSubview(view)
        }
    }
}
