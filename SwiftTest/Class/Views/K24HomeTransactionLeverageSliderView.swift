//
//  K24HomeTransactionLeverageSliderView.swift
//  CashSAVO
//
//  Created by yyw on 2026/5/21.
//

import UIKit
import SnapKit

class K24HomeTransactionLeverageSliderView: BaseView, UIGestureRecognizerDelegate {
    public var valueChangedBlock: ((Int) -> Void)?
    
    // 这里不要用 UIScale(x)
    public let viewWidth = 177.0
    public let viewHeight = 56.0
    
    private var minValue = 1
    private var maxValue = 5
    private var currentValue = 1
    private var currentScaleMarkIndex = 0
    private var dragStartScaleMarkIndex = 0
    
    private var valueLabels: [UILabel] = []
    private var scaleMarks: [UIView] = []
    private var dragStartRulerLeft: CGFloat = 0
    private var currentRulerLeft: CGFloat = 0
    private var dragStartLocationX: CGFloat = 0
    
    private let scaleMarkWidth = 2.0
    private let scaleMarkHeight = 5.0
    private let scaleMarkSpaceing = 6.0
    private let scaleMarkMargin = 16.0
    
    private var scaleMarkStep: CGFloat {
        scaleMarkWidth + scaleMarkSpaceing
    }
    
    private lazy var scaleContainerView = {
        let view = UIView()
        return view
    }()
    
    private lazy var contentView = {
        let view = UIView()
        view.backgroundColor = .BG_FFFFFF_1_181818_1
        view.setCornerRadius(56/2.0)
        view.layer.borderWidth = HeightOfLine
        view.layer.borderLineThemeColor = .BL_F1F1F1_1_464646_05
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var rulerView = {
        let view = UIView()
        return view
    }()
    
    private lazy var glassView = {
        let view = GlassEffectContainerView()
        view.glassViewStyle = .regular
        view.glassViewCornerRadius = 56/2.0
        return view
    }()
    
    private var rulerViewLeft: Constraint?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
//        if #available(iOS 26.0, *) {
//            addSubview(glassView)
//            glassView.snp.makeConstraints { make in
//                make.edges.equalToSuperview()
//            }
//            glassView.s_addSubview(scaleContainerView)
//            scaleContainerView.snp.makeConstraints { make in
//                make.edges.equalToSuperview()
//            }
//        } else {
            addSubview(scaleContainerView)
            scaleContainerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
//            }
        }
        
        scaleContainerView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gesture.minimumPressDuration = 0.05
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        addGestureRecognizer(gesture)
        
        contentView.addSubview(rulerView)
        rulerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            rulerViewLeft = make.left.equalToSuperview().constraint
            make.width.greaterThanOrEqualTo(10)
            make.height.equalToSuperview()
        }
    }
    
    public func updateUI(min: Int, max: Int, current: Int) {
        valueLabels.forEach({$0.removeFromSuperview()})
        valueLabels.removeAll()
        
        scaleMarks.forEach({$0.removeFromSuperview()})
        scaleMarks.removeAll()
        
        minValue = min
        maxValue = max
        currentValue = current
        currentScaleMarkIndex = scaleMarkIndex(for: currentValue)
        
        var last: UIView? = nil
        let totalScaleMarkCount = (maxValue - minValue + 2) * 10
        for i in 0..<totalScaleMarkCount {
            let scaleMark = UIView()
            scaleMark.tag = i
            scaleMark.backgroundColor = .BG_000000_1_FFFFFF_1
            
            rulerView.addSubview(scaleMark)
            scaleMark.snp.makeConstraints { make in
                make.width.equalTo(Int(scaleMarkWidth))
                make.height.equalTo(Int(scaleMarkHeight))
                make.bottom.equalToSuperview().inset(3)
                if let last {
                    make.left.equalTo(last.snp.right).offset(scaleMarkSpaceing)
                } else {
                    make.left.equalToSuperview().inset(scaleMarkMargin)
                }
                if i == totalScaleMarkCount - 1 {
                    make.right.equalToSuperview().inset(scaleMarkMargin)
                }
            }
            scaleMarks.append(scaleMark)
            last = scaleMark
            
            if (i + 1) % 10 == 0 {
                if i > 0 && i < maxValue * 10 {
                    scaleMark.backgroundColor = .ColorFromHex("#FF0000")
                }
                
                let index = minValue + ((i + 1) / 10) - 1
                if index <= maxValue {
                    let label = UILabel()
                    label.font = .systemFont(ofSize: 30)
                    label.textColor = .Text_000000_1_FFFFFF_1
                    label.text = "\(index)x"
                    rulerView.addSubview(label)
                    label.snp.makeConstraints { make in
                        make.centerX.equalTo(scaleMark.snp.centerX)
                        make.centerY.equalTo(rulerView.snp.top).offset(UIScale(24))
                    }
                    valueLabels.append(label)
                }
            }
        }
    }

    @objc
    private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            applyScale(1.4)
            dragStartRulerLeft = currentRulerLeft
            dragStartScaleMarkIndex = currentScaleMarkIndex
            dragStartLocationX = gesture.location(in: self).x
        case .changed:
            updateRulerPosition(with: gesture)
        case .ended, .cancelled, .failed:
            snapToNearestIntegerScaleMark()
            applyScale(1.0)
        default:
            break
        }
    }
    
    private func updateRulerPosition(with gesture: UILongPressGestureRecognizer) {
        let translationX = gesture.location(in: self).x - dragStartLocationX
        let stepCount = Int(translationX / scaleMarkStep)
        let nextLeft = dragStartRulerLeft + CGFloat(stepCount) * scaleMarkStep
        guard nextLeft < 0 && nextLeft > (contentView.bounds.width - rulerView.bounds.width) else { return }
        guard nextLeft != currentRulerLeft else { return }
        currentRulerLeft = nextLeft
        rulerViewLeft?.update(offset: currentRulerLeft)
        currentScaleMarkIndex = min(max(dragStartScaleMarkIndex - stepCount, 0), scaleMarks.count - 1)
        PlaySystemAudioShock()
        layoutIfNeeded()
    }
    
    private func snapToNearestIntegerScaleMark() {
        let nearestValue = nearestIntegerValueForCurrentCenter()
        currentValue = nearestValue
        animateSnapToScaleMark(scaleMarkIndex(for: nearestValue))
        valueChangedBlock?(nearestValue)
    }
    
    private func alignRulerViewToCurrentScaleMark(animated: Bool) {
        let centerX = contentView.bounds.midX
        let targetLeft = centerX - scaleMarkCenterX(for: currentScaleMarkIndex)
        currentRulerLeft = targetLeft
        rulerViewLeft?.update(offset: targetLeft)
        
        let animations = {
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.18, animations: animations)
        } else {
            animations()
        }
    }
    
    private func animateSnapToScaleMark(_ targetIndex: Int) {
        let stepDirection = targetIndex == currentScaleMarkIndex ? 0 : (targetIndex > currentScaleMarkIndex ? 1 : -1)
        guard stepDirection != 0 else {
            alignRulerViewToCurrentScaleMark(animated: false)
            return
        }
        
        func animateNextStep() {
            guard currentScaleMarkIndex != targetIndex else { return }
            
            currentScaleMarkIndex += stepDirection
            let centerX = contentView.bounds.midX
            let targetLeft = centerX - scaleMarkCenterX(for: currentScaleMarkIndex)
            currentRulerLeft = targetLeft
            rulerViewLeft?.update(offset: targetLeft)
            
            UIView.animate(withDuration: 0.06, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                animateNextStep()
                PlaySystemAudioShock()
            })
        }
        
        animateNextStep()
    }
    
    private func nearestIntegerValueForCurrentCenter() -> Int {
        let centerX = contentView.bounds.midX
        var nearestValue = minValue
        var nearestDistance = CGFloat.greatestFiniteMagnitude
        
        for value in minValue...maxValue {
            let index = scaleMarkIndex(for: value)
            let markCenterX = currentRulerLeft + scaleMarkCenterX(for: index)
            let distance = abs(markCenterX - centerX)
            if distance < nearestDistance {
                nearestDistance = distance
                nearestValue = value
            }
        }
        
        return nearestValue
    }
    
    private func scaleMarkIndex(for value: Int) -> Int {
        (value - minValue + 1) * 10 - 1
    }
    
    private func scaleMarkCenterX(for index: Int) -> CGFloat {
        scaleMarkMargin + scaleMarkWidth / 2.0 + CGFloat(index) * scaleMarkStep
    }
    
    private func applyScale(_ scale: CGFloat) {
        UIView.animate(withDuration: 0.15) {
            self.scaleContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
