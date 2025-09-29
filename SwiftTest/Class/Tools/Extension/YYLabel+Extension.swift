//
//  YYLabel+Extension.swift
//  CashSAVO
//
//  Created by yyw on 2025/1/10.
//

import UIKit
import YYKit

extension UIColor {
    static func yykit_compatibility_colorWithColor(_ color: UIColor) -> UIColor {
        return UIColor { cc in
            return color.resolvedColor(with: cc)
        }
    }
}

extension YYLabel {
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let attributedText = self.attributedText {
            if let new_attributedText: NSMutableAttributedString = attributedText.mutableCopy() as? NSMutableAttributedString {
                new_attributedText.enumerateAttributes(in: NSRange(location: 0, length: new_attributedText.length), options: []) { attributes, range, _ in
                    if let color = attributes[.foregroundColor] as? UIColor {
                        let color_ = UIColor.yykit_compatibility_colorWithColor(color)
                        new_attributedText.setColor(color_, range: range)
                    }
                }
                self.attributedText = new_attributedText
            }
        }
        else {
            if let textColor = self.textColor {
                let color_ = UIColor.yykit_compatibility_colorWithColor(textColor)
                self.textColor = color_
            }
        }
        self.layer.setNeedsDisplay()
    }
}

extension YYTextView {
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let attributedText = self.attributedText {
            if let new_attributedText: NSMutableAttributedString = attributedText.mutableCopy() as? NSMutableAttributedString {
                new_attributedText.enumerateAttributes(in: NSRange(location: 0, length: new_attributedText.length), options: []) { attributes, range, _ in
                    if let color = attributes[.foregroundColor] as? UIColor {
                        new_attributedText.setColor(UIColor.yykit_compatibility_colorWithColor(color), range: range)
                    }
                }
                self.attributedText = new_attributedText
            }
        }
        else {
            if let textColor = self.textColor {
                self.textColor = UIColor.yykit_compatibility_colorWithColor(textColor)
            }
        }
        self.layer.setNeedsDisplay()
    }
}
