//
//  MiniAppContainerButtonView.swift
//  CashSAVO
//
//  Created by yyw on 2025/6/11.
//

import UIKit
import SnapKit
import YYKit

/**
 只适配1/2个按钮的样式，其他样式用到了再适配
 */
class MiniAppContainerButtonView: UIView {
    var clickBlock: ((ButtonType)->())?
    let types: [ButtonType]
    var viewWidth: CGFloat = 0
    let viewHeight: CGFloat = 36
    
    init(frame: CGRect, types: [ButtonType]) {
        self.types = types
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        backgroundColor = UIColor.gray
        
        if types.count == 1 {
            viewWidth = 46
            
            let type = types[0]
            let button = UIButton(frame: .zero)
            button.setImage(UIImage(named: type.icon()), for: .normal)
            button.addBlock(for: .touchUpInside) { [weak self] sender in
                guard let weakSelf = self else { return }
                weakSelf.clickBlock?(type)
            }
            addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.centerX.equalToSuperview()
                make.width.height.equalTo(44)
            }
        }
        
        if types.count == 2 {
            viewWidth = 85
            
            do {
                let type = types[0]
                let button = UIButton(frame: .zero)
                button.setImage(UIImage(named: type.icon()), for: .normal)
                button.addBlock(for: .touchUpInside) { [weak self] sender in
                    guard let weakSelf = self else { return }
                    weakSelf.clickBlock?(type)
                }
                addSubview(button)
                button.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.centerX.equalTo(self.snp.left).offset(21)
                    make.width.height.equalTo(44)
                }
            }
            
            do {
                let type = types[1]
                let button = UIButton(frame: .zero)
                button.setImage(UIImage(named: type.icon()), for: .normal)
                button.addBlock(for: .touchUpInside) { [weak self] sender in
                    guard let weakSelf = self else { return }
                    weakSelf.clickBlock?(type)
                }
                addSubview(button)
                button.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.centerX.equalTo(self.snp.right).offset(-21)
                    make.width.height.equalTo(44)
                }
            }
            
            let line = UIView(frame: .zero)
            line.backgroundColor = UIColor.lightGray
            addSubview(line)
            line.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.width.equalTo(1)
                make.height.equalTo(22)
            }
        }
    }
}

extension MiniAppContainerButtonView {
    enum ButtonType {
        case back
        case close
        case down
        case kefu
        case more
        
        func icon() -> String {
            switch self {
            case .back:
                return "miniapp_navi_back"
            case .close:
                return "miniapp_navi_close"
            case .down:
                return "miniapp_navi_down_arrow"
            case .kefu:
                return "miniapp_navi_kefu"
            case .more:
                return "miniapp_navi_more"
            }
        }
    }
}
