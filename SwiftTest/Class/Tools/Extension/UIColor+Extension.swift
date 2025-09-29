//
//  UIColor+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2025/1/9.
//

import UIKit

extension UIColor {
    // MARK: - 不会根据主题颜色改变
    static var C_Black = ColorFromHex("000000")
    static var C_White = ColorFromHex("FFFFFF")
    static var C_Clear = ColorFromHex("")
    
    
    
    // MARK: - 背景色
    // 白色
    static let BG_FFFFFF_1                      = ColorFromHex("FFFFFF")
    // 黑色
    static let BG_000000_1                      = ColorFromHex("000000")
    // 灰色
    static let BG_F8F8F8_1                      = ColorFromHex("F8F8F8")
    static let BG_E4E5E6_1                      = ColorFromHex("E4E5E6")

    
    
    // MARK: - 分割线
    static var Line_E4E5E6_1                    = ColorFromHex("E4E5E6")

    
    
    // MARK: - 边框
    static let BL_E8E8E9_1                      = ColorFromHex("E8E8E9")
    static let BL_F1F1F1_1                      = ColorFromHex("F1F1F1")

    
    
    // MARK: - 文案
    // 黑色
    static let Text_000000_1                    = ColorFromHex("000000")

    // 灰色
    static let Text_777790_1                    = ColorFromHex("777790")

    // 蓝色-浅
    static let Text_0091FF_1                    = ColorFromHex("0091FF")
}

extension UIColor {
    static func ColorFromHex (_ hex: String,
                              _ alpha: CGFloat = 1,
                              darkHex: String? = nil,
                              darkAlpha: CGFloat = 1) -> UIColor
    {
        var darkColor: UIColor
        var lightColor: UIColor
        
        if hex.isEmpty {
            lightColor = UIColor.clear
        }
        else if hex.count < 6 {
            lightColor = UIColor.clear
        }
        else {
            lightColor = color(value: hex, alpha: alpha)
        }
        
        var _darkHex = darkHex
        var _darkAlpha = darkAlpha
        if darkHex == nil {
            _darkHex = hex
            _darkAlpha = alpha
        }
        
        if _darkHex!.isEmpty {
            darkColor = UIColor.clear
        }
        else if _darkHex!.count < 6 {
            darkColor = UIColor.clear
        }
        else {
            darkColor = color(value: _darkHex!, alpha: _darkAlpha)
        }
        
        
        return UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == . dark {
                return darkColor
            }
            else {
                return lightColor
            }
        }
    }

    private static func color(value: Any,
                              alpha: CGFloat = 1) -> UIColor
    {
      var color: UIColor
      
      switch value {
        case let hexString as String:
          var hexint: UInt64 = 0

          // Create scanner
          let sanner: Scanner = Scanner(string: hexString)
          // Tell scanner to skip the # character
          sanner.charactersToBeSkipped = CharacterSet.init(charactersIn: "#")
          sanner.scanHexInt64(&hexint)
          color = UIColor.init(red: (CGFloat((hexint & 0xFF0000) >> 16)) / 255.0,
                               green: (CGFloat((hexint & 0xFF00) >> 8)) / 255.0,
                               blue: (CGFloat(hexint & 0xFF)) / 255.0,
                               alpha: CGFloat(alpha))
        
        case let hex as Int:
          let r = CGFloat((hex & 0xff0000) >> 16) / 255, g = CGFloat((hex & 0xff00) >> 8) / 255, b = CGFloat(hex & 0xff) / 255
          color = UIColor(red: r, green: g, blue: b, alpha: alpha)
        
        default:
          color = UIColor(red: 1, green: 1, blue: 1, alpha: alpha)
      }
      
      return color
    }
}
