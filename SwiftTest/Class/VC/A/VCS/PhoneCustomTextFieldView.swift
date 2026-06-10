//
//  PhoneCustomTextFieldView.swift
//  CashSAVO
//
//  Created by caicai on 2024/7/22.
//

import UIKit
import SnapKit
import YYKit

class PhoneCustomTextFieldView: BaseView {
    let allOfHeight = UIScale(79)
    
    private var topLeftLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.Text_777790
        return label
    }()
    
    private var topRightLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.BG_FE2B52
        return label
    }()
    
    private var textBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.BG_FCFCFC_1_FFFFFF_008
        view.layer.borderLineThemeColor = UIColor.BL_E8E8E9_07_464646_05
        view.layer.borderWidth = HeightOfLine
        view.layer.cornerRadius = UIScale(12)
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        return view
    }()
    
    private var textFieldView: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textAlignment = .left
        textField.textColor = UIColor.Text_000000_1_FFFFFF_1
        //关闭键盘联想
        textField.autocorrectionType = .no
        //关闭键盘检查
        textField.spellCheckingType = .no
        return textField
    }()
    
    private var leftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = UIColor.Text_000000_1_FFFFFF_1
        label.text = "+" + "86"
        return label
    }()
    private var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "right_arrow_20*20")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(topLeftLabel)
        topLeftLabel.snp.makeConstraints { make in
            make.left.equalTo(UIScale(2))
            make.height.equalTo(UIScale(26))
            make.top.equalToSuperview()
        }
        
        addSubview(topRightLabel)
        topRightLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(UIScale(2))
            make.top.equalToSuperview()
            make.height.equalTo(UIScale(26))
        }
        
        addSubview(textBgView)
        textBgView.snp.makeConstraints { make in
            make.top.equalTo(topLeftLabel.snp.bottom).offset(UIScale(3))
            make.left.equalToSuperview()
            make.height.equalTo(UIScale(50))
            make.right.equalToSuperview()
        }
        
        textBgView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(UIScale(15))
            make.centerY.equalToSuperview()
        }
        textBgView.addSubview(leftImageView)
        leftImageView.snp.makeConstraints { make in
            make.left.equalTo(leftLabel.snp.right).offset(UIScale(10))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(UIScale(20))
        }
        
        textFieldView.delegate = self
        textFieldView.addTarget(self, action: #selector(selectedTextDidChangeClick), for: .editingChanged)
        textBgView.addSubview(textFieldView)
        textFieldView.snp.makeConstraints { make in
            make.left.equalTo(leftImageView.snp.right).offset(UIScale(10))
            make.right.equalToSuperview().inset(UIScale(15))
            make.centerY.equalToSuperview()
            make.height.equalTo(UIScale(50))
        }
    }
    
    @objc private func selectedTextDidChangeClick() {
        let str = textFieldView.text ?? ""
        if let handler = selectedTextDidChangeHandler {
            handler(str)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setKeyboardType(type: UIKeyboardType) {
        textFieldView.keyboardType = type
    }
    func showInitView(hintStr: String, placeholderStr: String, text: String = "", isHasTopCorner: Bool = false) {
        topLeftLabel.text = hintStr
        let attr = NSMutableAttributedString(string: placeholderStr)
        attr.font = UIFont.systemFont(ofSize: 16)
        attr.color = UIColor.Text_C6C6C6_1_747474_1
        textFieldView.attributedPlaceholder = attr
        configText(valueStr: text)
        updateTextBgColor(isHasTopCorner: isHasTopCorner)
    }
    
    func updatePhonePrefix(str: String) {
        leftLabel.text = "+" + str
        let currentStr = textFieldView.text ?? ""
        configText(valueStr: currentStr)
    }
    func configCenterText(str: String) {
        textFieldView.text = str
    }
    private func configText(valueStr: String) {
        textFieldView.text = valueStr.replacingOccurrences(of: " ", with: "")
    }
    func getTextFieldIsFocused() -> Bool {
        return textFieldView.isEditing
    }
    
    func showErrorView(errorStr: String, isHasErrorImage: Bool = false) {
        if let text = textFieldView.text, !text.isEmpty {
            topRightLabel.isHidden = false
            topRightLabel.text = errorStr
        } else {
            hiddenErrorView()
        }
        if isHasErrorImage {
            showErrorImageView(isHidden: errorStr.isEmpty)
        }
    }
    func hiddenErrorView() {
        topRightLabel.isHidden = false
        topRightLabel.text = ""
    }
    func showErrorImageView(isHidden: Bool) {
        if isHidden {
            textFieldView.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(UIScale(15))
            }
        } else {
            textFieldView.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(UIScale(35))
            }
        }
    }
    func updateIsCanEdit(isCan: Bool) {
        if isCan {
            textFieldView.textColor = UIColor.Text_000000_1_FFFFFF_1
        } else {
            textFieldView.textColor = UIColor.Text_777790
        }
    }
    func updateTextBgColor(isHasTopCorner: Bool) {
        if isHasTopCorner {
            textBgNormalColor = UIColor.BG_FCFCFC_1_FFFFFF_003
        } else {
            textBgNormalColor = UIColor.BG_FCFCFC_1_FFFFFF_008
        }
    }
    private var textBgNormalColor = UIColor.BG_FCFCFC_1_FFFFFF_008
    
    private func noneSpaseString(_ str: String) -> String {
        return str.replacingOccurrences(of: " ", with: "")
    }
    
    var selectedBeginEditHandler: (() -> ())?
    var selectedEndEditHandler: (() -> ())?
    var selectedTextDidChangeHandler: ((String) -> ())?
    var selectedLeftPhoneHandler: (() -> ())?
    
    override func colorAppearanceDidChange(from previousTraitCollection: UITraitCollection?) {
        super.colorAppearanceDidChange(from: previousTraitCollection)
        textBgView.layer.traitCollectionDidChange(previousTraitCollection)
    }
}

extension PhoneCustomTextFieldView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }    
}
