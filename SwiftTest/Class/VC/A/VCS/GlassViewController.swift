//
//  GlassViewController.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/19.
//

import UIKit
import SnapKit

class GlassViewController: BaseViewController {
    lazy var redView = {
        let view = K24HomeTransactionLeverageSliderView()
        view.updateUI(min: 3, max: 4)
        return view
    }()
    
//    lazy var textFieldView = {
//        let textField = PhoneCustomTextFieldView()
//        return textField
//    }()
    
    private var textFieldView: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textAlignment = .left
        textField.textColor = UIColor.Text_000000_1_FFFFFF_1
        //关闭键盘联想
        textField.autocorrectionType = .no
        //关闭键盘检查
        textField.spellCheckingType = .no
        textField.text = "哈哈哈哈"
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "XXX"
        view.backgroundColor = .BG_F7F7F7_1_181818_1
        
        redView.isHidden = true
        view.addSubview(redView)
        redView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(redView.viewWidth)
            make.height.equalTo(redView.viewHeight)
        }
        redView.valueChangedBlock = { index in
            printLog(index)
        }
        
        textFieldView.text = "哈哈哈哈哈"
//        textFieldView.configCenterText(str: "哈哈哈哈哈")
        view.addSubview(textFieldView)
        textFieldView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(UIScale(200))
            make.height.equalTo(UIScale(30))
        }
    }
}

public extension UITextField {
    var isCombinedInput: Bool {
        if let markedRange = markedTextRange, position(from: markedRange.start, offset: 0) != nil {
            return true
        } else {
            return false
        }
    }
}
