//
//  K24HomeTransactionLeverageSliderView.swift
//  CashSAVO
//
//  Created by yyw on 2026/5/21.
//

import UIKit
import SnapKit

class K24HomeTransactionLeverageSliderView: BaseView {
    public var valueChangedBlock: ((Int) -> Void)?
    
    // 这里不要用 UIScale(x)
    public let viewWidth = 177.0
    public let viewHeight = 56.0
    
    private var minValue = 1
    private var maxValue = 5
    private var currentScaleMarkIndex = 0
    
    private var valueLabels: [UILabel] = []
    private var scaleMarks: [UIView] = []
    private var dragStartRulerLeft: CGFloat = 0
    private var currentRulerLeft: CGFloat = 0
    private var dragStartLocationX: CGFloat = 0
    private var rulerViewLeft: Constraint?
    
    private let scaleMarkWidth = 2.0
    private let scaleMarkHeight = 5.0
    private let scaleMarkSpaceing = 6.0
    private let scaleMarkMargin = 16.0
    
    private var stepLength: CGFloat {
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
    
    lazy var segmentedControl = {
        let view = CustomSystemSegmentedView(frame: .zero)
        view.normalConfig = [.foregroundColor: UIColor.C_Clear, .font: UIFont.systemFont(ofSize: 15)]
        view.selectedConfig = [.foregroundColor: UIColor.C_Clear, .font:UIFont.systemFont(ofSize: 15)]
        view.selectedColor = .clear
        view.updateUI(titles: [""])
        view.selectedIndex = 0
        view.backgroundColor = .clear
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(scaleContainerView)
        scaleContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scaleContainerView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gesture.minimumPressDuration = 0.01
        gesture.cancelsTouchesInView = false
        addGestureRecognizer(gesture)
        
        contentView.addSubview(rulerView)
        rulerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            rulerViewLeft = make.left.equalTo(contentView.snp.left).constraint
            make.width.greaterThanOrEqualTo(10)
            make.height.equalToSuperview()
        }
        
        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(viewWidth * 1.3)
            make.height.equalTo(viewHeight * 1.2)
        }
    }
    
    public func updateUI(min: Int, max: Int) {
        valueLabels.forEach({$0.removeFromSuperview()})
        valueLabels.removeAll()
        
        scaleMarks.forEach({$0.removeFromSuperview()})
        scaleMarks.removeAll()
        
        minValue = min
        maxValue = max
        currentScaleMarkIndex = 0
        
        var last: UIView? = nil
        let totalScaleMarkCount = (maxValue - minValue + 2) * 10 - 1
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
        
        delay(seconds: 0.1) {
            self.updateScaleMarkUI()
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            applyScale(1.4)
            dragStartRulerLeft = currentRulerLeft
            dragStartLocationX = gesture.location(in: self).x
            
        case .changed:
            updateRulerPosition(gesture)
            
        case .ended, .cancelled, .failed:
            correctionRulerPosition()
            applyScale(1.0)
            
        default:
            break
        }
    }
    
    private func updateRulerPosition(_ gesture: UILongPressGestureRecognizer) {
        let translationX = gesture.location(in: self).x - dragStartLocationX
        var nextLeft = dragStartRulerLeft + translationX
        nextLeft = max(nextLeft, (contentView.bounds.width - rulerView.bounds.width))
        nextLeft = min(nextLeft, 0)
        rulerViewLeft?.update(offset: nextLeft)
        currentRulerLeft = nextLeft
        
        contentView.layoutIfNeeded()
        rulerView.layoutIfNeeded()
        let dragStartScaleMarkIndex = Int(-currentRulerLeft / stepLength)
        if dragStartScaleMarkIndex != currentScaleMarkIndex {
            PlaySystemAudioShock()
            currentScaleMarkIndex = dragStartScaleMarkIndex
            updateScaleMarkUI()
        }
    }
    
    private func correctionRulerPosition() {
        let index = currentScaleMarkIndex
        currentScaleMarkIndex = ((index / 10) + ((index % 10) >= 5 ? 1 : 0)) * 10
        currentRulerLeft = -CGFloat(currentScaleMarkIndex) * stepLength
        
        let current = currentScaleMarkIndex / 10 + minValue
        valueChangedBlock?(current)
        
        UIView.animate(withDuration: 0.2) {
            self.rulerViewLeft?.update(offset: self.currentRulerLeft)
            self.contentView.layoutIfNeeded()
        } completion: { _ in
            self.updateScaleMarkUI()
        }
    }
    
    private func applyScale(_ scale: CGFloat) {
        if scale > 1.0 {
            contentView.layer.borderLineThemeColor = .clear
        } else {
            contentView.layer.borderLineThemeColor = .BL_F1F1F1_1_464646_05
        }
        
        UIView.animate(withDuration: 0.15) {
            self.scaleContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func updateScaleMarkUI() {
        scaleMarks.forEach {$0.backgroundColor = .BG_000000_1_FFFFFF_1}
        
        let center = currentScaleMarkIndex + 9
        if scaleMarks.count > center {
            scaleMarks[center].backgroundColor = .ColorFromHex("FF0000")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            contentView.layer.traitCollectionDidChange(previousTraitCollection)
        }
    }
}
