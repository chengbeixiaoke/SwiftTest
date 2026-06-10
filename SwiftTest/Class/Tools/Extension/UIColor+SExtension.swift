//
//  UIColor+SExtension.swift
//  SavoUIKit
//
//  Created by yyw on 2025/11/6.
//

import UIKit

public extension UIColor {
    /// 根据RGBA生成颜色
    /// - Parameters:
    ///   - red: 红色
    ///   - green: 绿色
    ///   - blue: 蓝色
    ///   - alpha: 透明度
    /// - Returns: Color
    class func initWithRGB(_ red: CGFloat,
                           _ green: CGFloat,
                           _ blue: CGFloat,
                           alpha: CGFloat) -> UIColor
    {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    
    /// 根据RGBA生成颜色
    /// - Parameters:
    ///   - red: 红色
    ///   - green: 绿色
    ///   - blue: 蓝色
    /// - Returns: Color
    convenience init(_ red: CGFloat,
                     _ green: CGFloat,
                     _ blue: CGFloat )
    {
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    
    /// 获取当前主题下的颜色
    /// - Parameters:
    ///   - light: 明亮模式颜色
    ///   - dark: 暗黑模式颜色
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return light
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
    
    /// 根基16进制字符串生成颜色
    /// - Parameters:
    ///   - hex: 明亮模式-16进制颜色字符串
    ///   - alpha: 明亮模式-透明度，默认为1
    ///   - darkHex: 暗黑模式-16进制颜色字符串，为空则默认暗黑和明亮同一个色值
    ///   - darkAlpha: 暗黑模式-透明度，默认为1
    /// - Returns: Color
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
            switch AppThemeModeManager.shared.currentMode {
            case .dark:
                return darkColor
            case .light:
                return lightColor
            case .followingSystem:
                return traitCollection.userInterfaceStyle == .dark ? darkColor : lightColor
            }
        }
    }
    
    private static func color(value: Any, alpha: CGFloat = 1) -> UIColor {
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
    
    
    /// 获取Color的RGBA值
    /// - Parameter originColor: Color
    /// - Returns: RGBA
    func getRGBByColor(originColor: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat)
    {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        originColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
    
    
    /// 获取两个颜色混合后的颜色
    /// - Parameters:
    ///   - beginColor: 颜色1
    ///   - endColor: 颜色2
    ///   - coe: 偏移量
    /// - Returns: Color
    func getColor(beginColor: UIColor,
                  endColor: UIColor,
                  coe: CGFloat) -> UIColor
    {
        let beginRGB = getRGBByColor(originColor: beginColor)
        let endRGB = getRGBByColor(originColor: endColor)
        let newRed =  beginRGB.0 + coe * (endRGB.0 -  beginRGB.0)
        let newGreen =  beginRGB.1 + coe * (endRGB.1 -  beginRGB.1)
        let newBlue =  beginRGB.2 + coe * (endRGB.2 -  beginRGB.2)
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1)
    }
    
    
    /// 获取两个颜色混合后的颜色
    /// - Parameters:
    ///   - beginColorRed: 红色1
    ///   - beginColorGreen: 绿色1
    ///   - beginColorBlue: 蓝色1
    ///   - endColorRed: 红色2
    ///   - endColorGreen: 绿色2
    ///   - endColorBlue: 蓝色2
    ///   - coe: 偏移量
    /// - Returns: Color
    func getColor(beginColorRed: CGFloat,
                  beginColorGreen: CGFloat,
                  beginColorBlue: CGFloat,
                  endColorRed: CGFloat,
                  endColorGreen: CGFloat,
                  endColorBlue: CGFloat,
                  coe: CGFloat) -> UIColor
    {
        let newRed = beginColorRed + coe * (endColorRed - beginColorRed)
        let newGreen = beginColorGreen + coe * (endColorGreen - beginColorGreen)
        let newBlue = beginColorBlue + coe * (endColorBlue - beginColorBlue)
        return UIColor.initWithRGB(newRed, newGreen, newBlue, alpha: 1)
    }
}


public extension UIColor {
    // MARK: - color 不会根据主题颜色改变
    static var C_Black = ColorFromHex("000000")
    static var C_White = ColorFromHex("FFFFFF")
    static var C_Clear = ColorFromHex("")
    
    // MARK: - Color 根据主题颜色改变
    static var ColorWhite = ColorFromHex("FFFFFF", darkHex: "000000")
    static var ColorBlack = ColorFromHex("000000", darkHex: "FFFFFF")
    
    
    // MARK: BG Color
    static let BG_FFFFFF_015           = ColorFromHex("FFFFFF", 0.15)
    static let BG_FFFFFF_02            = ColorFromHex("FFFFFF", 0.2)
    static let BG_FFFFFF_03            = ColorFromHex("FFFFFF", 0.3)
    static let BG_FFFFFF_08            = ColorFromHex("FFFFFF", 0.8)
    static let BG_FFFFFF_1_FFFFFF_01   = ColorFromHex("FFFFFF", darkHex: "FFFFFF", darkAlpha: 0.1)
    static let BG_FFFFFF_1_FFFFFF_003  = ColorFromHex("FFFFFF", darkHex: "FFFFFF", darkAlpha: 0.03)
    static let BG_FFFFFF_1_ADA7FF_01   = ColorFromHex("FFFFFF", darkHex: "ADA7FF", darkAlpha: 0.1)
    static let BG_FFFFFF_1_F1F1F1_005  = ColorFromHex("FFFFFF", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let BG_FFFFFF_1_FE2B52_008  = ColorFromHex("FFFFFF", darkHex: "FE2B52", darkAlpha: 0.08)
    static let BG_FFFFFF_1_222225_1    = ColorFromHex("FFFFFF", darkHex: "222225")
    static let BG_FFFFFF_08_17171A_1   = ColorFromHex("FFFFFF", 0.8, darkHex: "17171A")
    static let BG_FFFFFF_1_2C2C2F_1    = ColorFromHex("FFFFFF", darkHex: "2C2C2F")
    static let BG_FFFFFF_1_262626_1    = ColorFromHex("FFFFFF", darkHex: "262626")
    static let BG_FFFFFF_1_2D2D2D_1    = ColorFromHex("FFFFFF", darkHex: "2D2D2D")
    static let BG_FFFFFF_1_1D1D20_1    = ColorFromHex("FFFFFF", darkHex: "1D1D20")
    static let BG_FFFFFF_1_17171A_1    = ColorFromHex("FFFFFF", darkHex: "17171A")
    static let BG_FFFFFF_1_222222_1    = ColorFromHex("FFFFFF", darkHex: "222222")
    static let BG_FFFFFF_1_181818_1    = ColorFromHex("FFFFFF", darkHex: "181818")
    static let BG_FFFFFF_1_FE2B52_012  = ColorFromHex("FFFFFF", darkHex: "FE2B52", darkAlpha: 0.12)
    static let BG_FFFFFF_0_181818_0    = ColorFromHex("FFFFFF", 0, darkHex: "181818", darkAlpha: 0)
    static let BG_FFFFFF_0_000000_0    = ColorFromHex("FFFFFF", 0, darkHex: "000000", darkAlpha: 0)
    
    
    static let BG_000000_06            = ColorFromHex("000000", 0.6)
    static let BG_000000_01            = ColorFromHex("000000", 0.1)
    static var BG_000000_1_008673_1    = ColorFromHex("000000", darkHex: "008673")
    static var BG_000000_1_6236FF_1    = ColorFromHex("000000", darkHex: "6236FF")
    static var BG_000000_03_777790_1   = ColorFromHex("000000", 0.3, darkHex: "777790")
    static let BG_000000_03_FFFFFF_03  = ColorFromHex("000000", 0.3, darkHex: "FFFFFF", darkAlpha: 0.3)
    static let BG_000000_1_FFFFFF_01   = ColorFromHex("000000", darkHex: "FFFFFF", darkAlpha: 0.1)
    static let BG_000000_1_FFFFFF_02   = ColorFromHex("000000", darkHex: "FFFFFF", darkAlpha: 0.2)
    static let BG_000000_1_FFFFFF_1    = ColorFromHex("000000", darkHex: "FFFFFF")
    static let BG_000000_1_181818_1    = ColorFromHex("000000", darkHex: "181818")
    static let BG_000000_1_2F2F2F_1    = ColorFromHex("000000", darkHex: "2F2F2F")
    
    static let BG_6236FF               = ColorFromHex("6236FF")
    static let BG_6236FF_003           = ColorFromHex("6236FF", 0.03)
    static let BG_6236FF_005           = ColorFromHex("6236FF", 0.05)
    static let BG_6236FF_01            = ColorFromHex("6236FF", 0.1)
    static let BG_6236FF_02            = ColorFromHex("6236FF", 0.2)
    static let BG_6236FF_06            = ColorFromHex("6236FF", 0.6)
    static let BG_6236FF_07            = ColorFromHex("6236FF", 0.7)
    static let BG_6236FF_1_3C3F4A_1    = ColorFromHex("6236FF", darkHex: "3C3F4A")
    static let BG_6236FF_1_ADA7FF_1    = ColorFromHex("6236FF", darkHex: "ADA7FF")
    static let BG_6236FF_003_ADA7FF_02 = ColorFromHex("6236FF", 0.03, darkHex: "ADA7FF", darkAlpha: 0.2)
    static let BG_6236FF_01_ADA7FF_01  = ColorFromHex("6236FF", 0.1, darkHex: "ADA7FF", darkAlpha: 0.1)
    static let BG_6236FF_1_FFFFFF_01   = ColorFromHex("6236FF", darkHex: "FFFFFF", darkAlpha: 0.1)
    static let BG_6236FF_1_FFFFFF_1    = ColorFromHex("6236FF", darkHex: "FFFFFF", darkAlpha: 1)
    static let BG_6236FF_1_clear       = ColorFromHex("6236FF", darkHex: "")
    static let BG_6236FF_005_FFFFFF_02 = ColorFromHex("6236FF", 0.05, darkHex: "FFFFFF", darkAlpha: 0.2)
    static let BG_6236FF_003_262530_1  = ColorFromHex("6236FF", 0.03, darkHex: "262530", darkAlpha: 1)
    
    static let BG_FF6200               = ColorFromHex("FF6200")
    
    static let BG_FCFCFC               = ColorFromHex("FCFCFC")
    static let BG_FCFCFC_1_FFFFFF_003  = ColorFromHex("FCFCFC", darkHex: "FFFFFF", darkAlpha: 0.03)
    static let BG_FCFCFC_1_FFFFFF_005  = ColorFromHex("FCFCFC", darkHex: "FFFFFF", darkAlpha: 0.05)
    static let BG_FCFCFC_1_FFFFFF_008  = ColorFromHex("FCFCFC", darkHex: "FFFFFF", darkAlpha: 0.08)
    static let BG_FCFCFC_1_222225_1    = ColorFromHex("FCFCFC", darkHex: "222225")
    static let BG_FCFCFC_1_ADA7FF_01   = ColorFromHex("FCFCFC", darkHex: "ADA7FF", darkAlpha: 0.1)
    static let BG_FCFCFC_1_FE2B52_008  = ColorFromHex("FCFCFC", darkHex: "FE2B52", darkAlpha: 0.08)
    static let BG_FCFCFC_1_F1F1F1_005  = ColorFromHex("FCFCFC", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let BG_FCFCFC_1_1D1D20_1    = ColorFromHex("FCFCFC", darkHex: "1D1D20")
    static let BG_FCFCFC_1_181818_1    = ColorFromHex("FCFCFC", darkHex: "181818")
    static let BG_FCFCFC_1_FE2B52_012  = ColorFromHex("FCFCFC", darkHex: "FE2B52", darkAlpha: 0.12)
    static let BG_FCFCFC_1_222222_1    = ColorFromHex("FCFCFC", darkHex: "222222")
    
    static let BG_F7F7F7_1_F1F1F1_005  = ColorFromHex("F7F7F7", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let BG_F7F7F7_1_181818_1    = ColorFromHex("F7F7F7", darkHex: "181818")
    static let BG_F7F7F7_1_222222_1    = ColorFromHex("F7F7F7", darkHex: "222222")
    
    static let BG_FAFAFA_1_F1F1F1_005  = ColorFromHex("FAFAFA", darkHex: "F1F1F1", darkAlpha: 0.05)
    
    static let BG_F1F1F2               = ColorFromHex("F1F1F2")
    static let BG_F1F1F2_2E2E33        = ColorFromHex("F1F1F1", darkHex: "2E2E33")
    
    static let BG_F1F2F2               = ColorFromHex("F1F2F2")
    
    static let BG_F1F1F1               = ColorFromHex("F1F1F1")
    static let BG_F1F1F1_07            = ColorFromHex("F1F1F1", 0.7)
    static let BG_F1F1F1_07_clear      = ColorFromHex("F1F1F1", 0.7, darkHex: "")
    static let BG_F1F1F1_1_F1F1F1_005  = ColorFromHex("F1F1F1", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let BG_F1F1F1_07_F1F1F1_005 = ColorFromHex("F1F1F1", 0.7, darkHex: "F1F1F1", darkAlpha: 0.05)
    static let BG_F1F1F1_1_27272D_1    = ColorFromHex("F1F1F1", darkHex: "27272D")
    static let BG_F1F1F1_1_2D2D2D_1    = ColorFromHex("F1F1F1", darkHex: "2D2D2D")
    static let BG_F1F1F1_1_FE2B52_1    = ColorFromHex("F1F1F1", darkHex: "FE2B52")
    static let BG_F1F1F1_1_2A2A2A_1    = ColorFromHex("F1F1F1", darkHex: "2A2A2A")
    static let BG_F1F1F1_1_clear       = ColorFromHex("F1F1F1", darkHex: "")
    static let BG_F1F1F1_05_F1F1F1_02  = ColorFromHex("F1F1F1", 0.5, darkHex: "F1F1F1", darkAlpha: 0.2)
    static let BG_F1F1F1_07_181818_1   = ColorFromHex("F1F1F1", 0.7, darkHex: "181818")
    static let BG_F1F1F1_07_222222_1   = ColorFromHex("F1F1F1", 0.7, darkHex: "222222")
    static let BG_F1F1F1_07_FFFFFF_008 = ColorFromHex("F1F1F1", 0.7, darkHex: "FFFFFF", darkAlpha: 0.08)
    static let BG_F1F1F1_1_181818_1    = ColorFromHex("F1F1F1", darkHex: "181818")
    static let BG_F1F1F1_1_222222_1    = ColorFromHex("F1F1F1", darkHex: "222222")
    static let BG_F1F1F1_07_2F2F2F_1   = ColorFromHex("F1F1F1", 0.7, darkHex: "2F2F2F")
    
    static let BG_D8D8D8               = ColorFromHex("D8D8D8")
    static let BG_D8D8D8_05            = ColorFromHex("D8D8D8", 0.5)
    static let BG_D8D8D8_1_D8D8D8_02   = ColorFromHex("D8D8D8", darkHex: "D8D8D8", darkAlpha: 0.2)
    static let BG_D8D8D8_07_D8D8D8_02  = ColorFromHex("D8D8D8", 0.7, darkHex: "D8D8D8", darkAlpha: 0.2)
    static let BG_D8D8D8_05_D8D8D8_02  = ColorFromHex("D8D8D8", 0.5, darkHex: "D8D8D8", darkAlpha: 0.2)
    static let BG_D8D8D8_07_1E1E21_07  = ColorFromHex("D8D8D8", 0.7, darkHex: "1E1E21", darkAlpha: 0.7)
    static let BG_D8D8D8_05_FFFFFF_01  = ColorFromHex("D8D8D8", 0.5, darkHex: "FFFFFF", darkAlpha: 0.1)
    static let BG_D8D8D8_1_F1F1F1_005  = ColorFromHex("D8D8D8", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let BG_D8D8D8_1_FFFFFF_02   = ColorFromHex("D8D8D8", darkHex: "FFFFFF", darkAlpha: 0.2)
    static let BG_D8D8D8_1_9B9B9B_1    = ColorFromHex("D8D8D8", darkHex: "9B9B9B")
    
    static let BG_FE2B52               = ColorFromHex("FE2B52")
    static let BG_FE2B52_008           = ColorFromHex("FE2B52", 0.08)
    
    static let BG_F8F8F8               = ColorFromHex("F8F8F8")
    static let BG_F8F8F8_1_222225_1    = ColorFromHex("F8F8F8", darkHex: "222225")
    static let BG_F8F8F8_1_F8F8F8_005  = ColorFromHex("F8F8F8", darkHex: "F8F8F8", darkAlpha: 0.05)
    static let BG_F8F8F8_1_F1F1F1_005  = ColorFromHex("F8F8F8", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let BG_F8F8F8_1_181818_1    = ColorFromHex("F8F8F8", darkHex: "181818")
    
    static let BG_F8F7F9_1_181818_1    = ColorFromHex("F8F7F9", darkHex: "181818")
    static let BG_F8F7F9_1_222222_1    = ColorFromHex("F8F7F9", darkHex: "222222")
    
    static let BG_06CA64               = ColorFromHex("06CA64")
    static let BG_06CA64_003_06CA64_019 = ColorFromHex("06CA64", 0.03, darkHex: "06CA64", darkAlpha: 0.19)
    static let BG_06CA64_003_FFFFFF_003 = ColorFromHex("06CA64", 0.03, darkHex: "FFFFFF", darkAlpha: 0.03)
    
    static let BG_4E566B_1_3C3F4A_1    = ColorFromHex("4E566B", darkHex: "3C3F4A")
    
    static let BG_00ABFF               = ColorFromHex("00ABFF")
    
    static let BG_F2F1F3_1_FFFFFF_1    = ColorFromHex("F2F1F3", darkHex: "FFFFFF")
    static let BG_F2F1F3_1_F1F1F1_005  = ColorFromHex("F2F1F3", darkHex: "F1F1F1", darkAlpha: 0.05)
    
    static var BG_008673               = ColorFromHex("008673")
    static var BG_008673_003           = ColorFromHex("008673", 0.03)
    static var BG_008673_1_3C3F4A_1    = ColorFromHex("008673", darkHex: "3C3F4A")
    
    
    static var BG_EA293C               = ColorFromHex("EA293C")
    
    static let BG_C6C6C6_02            = ColorFromHex("C6C6C6", 0.2)
    static let BG_C6C6C6_02_27272D_1   = ColorFromHex("C6C6C6", 0.2, darkHex: "27272D")
    static let BG_C6C6C6_03_27272D_1   = ColorFromHex("C6C6C6", 0.3, darkHex: "27272D")
    
    
    static let BG_1D61EE               = ColorFromHex("1D61EE")
    static let BG_1D61EE_1_3D3D3D_1    = ColorFromHex("1D61EE", darkHex: "3D3D3D")
    
    static let BG_480CA8               = ColorFromHex("480CA8")
    
    static var BG_0091FF               = ColorFromHex("0091FF")
    
    static var BG_B7B6BC               = ColorFromHex("B7B6BC")
    static var BG_B7B6BC_1_4A4A4A_1    = ColorFromHex("B7B6BC", darkHex: "4A4A4A")
    static var BG_B7B6BC_1_9B9B9B_1    = ColorFromHex("B7B6BC", darkHex: "9B9B9B")
    
    static var BG_727386_003           = ColorFromHex("727386", 0.03)
    
    static var BG_FF6200_01            = ColorFromHex("FF6200", 0.1, darkHex: "9B9B9B", darkAlpha: 0.1)
    
    static var BG_9B9B9B               = ColorFromHex("9B9B9B")
    static var BG_9B9B9B_01            = ColorFromHex("9B9B9B", 0.1)
    static var BG_9B9B9B_03            = ColorFromHex("9B9B9B", 0.3)
    static var BG_9B9B9B_1_D8D8D8_1    = ColorFromHex("9B9B9B", darkHex: "D8D8D8")
    
    static var BG_clear_F1F1F1_005     = ColorFromHex("", darkHex: "F1F1F1", darkAlpha: 0.05)
    static var BG_clear_FFFFFF_015     = ColorFromHex("", darkHex: "FFFFFF", darkAlpha: 0.15)
    static var BG_clear_6236FF         = ColorFromHex("", darkHex: "6236FF")
    static var BG_clear_000000         = ColorFromHex("", darkHex: "000000")
    static var BG_clear_181818         = ColorFromHex("", darkHex: "181818")
    
    static var BG_F9F9F9_1_F1F1F1_005  = ColorFromHex("F9F9F9", darkHex: "F1F1F1", darkAlpha: 0.05)
    static var BG_F9F9F9_1_181818_1    = ColorFromHex("F9F9F9", darkHex: "181818")
    static var BG_F9F9F9_1_222222_1    = ColorFromHex("F9F9F9", darkHex: "222222")
    
    static var BG_F9F8FA_1_222225_1    = ColorFromHex("F9F8FA", darkHex: "222225")
    static let BG_F9F8FA_1_181818_1    = ColorFromHex("F9F8FA", darkHex: "181818")
    
    static var BG_F8FCFB_1_06CA64_003  = ColorFromHex("F8FCFB", darkHex: "06CA64", darkAlpha: 0.03)
    
    static var BG_F9F8FA_1_FFFFFF_02   = ColorFromHex("F9F8FA", darkHex: "FFFFFF", darkAlpha: 0.2)
    
    static var BG_4A4A4A               = ColorFromHex("4A4A4A")
    static var BG_4A4A4A_1_FFFFFF_1    = ColorFromHex("4A4A4A", darkHex: "FFFFFF", darkAlpha: 1)
    
    static var BG_1F1F1F               = ColorFromHex("1F1F1F")
    
    static let BG_27272D               = ColorFromHex("27272D")
    
    static let BG_BE031F               = ColorFromHex("BE031F")
    
    static let BG_14746F               = ColorFromHex("14746F")
    
    static let BG_C9184A               = ColorFromHex("C9184A")
    
    static let BG_979797_005_FFFFFF_003 = ColorFromHex("979797", 0.05, darkHex: "FFFFFF", darkAlpha: 0.03)
    
    static let BG_F6536F                = ColorFromHex("F6536F")
    static let BG_D74961                = ColorFromHex("D74961")
    
    static let BG_1F9CF8                = ColorFromHex("1F9CF8")
    static let BG_1B8CDF                = ColorFromHex("1B8CDF")
    
    static let BG_727386                = ColorFromHex("727386")
    static let BG_616272                = ColorFromHex("616272")
    
    static let BG_ADA7FF_02             = ColorFromHex("ADA7FF", 0.2)
    
    static let BG_E4E4E4                = ColorFromHex("E4E4E4")
    
    static let BG_38B000_008            = ColorFromHex("38B000", 0.08)
    
    static let BG_0091FF_05             = ColorFromHex("0091FF", 0.5)

    static let BG_E4E5E6                = ColorFromHex("E4E5E6")
    
    

    
    // MARK: Line
    static var Line_E4E5E6_05               = ColorFromHex("E4E5E6", 0.5)
    static var Line_E4E5E6_05_FFFFFF_006    = ColorFromHex("E4E5E6", 0.5, darkHex: "FFFFFF", darkAlpha: 0.06)
    static var Line_E4E5E6_05_FFFFFF_008    = ColorFromHex("E4E5E6", 0.5, darkHex: "FFFFFF", darkAlpha: 0.08)
    static var Line_E4E5E6_05_222222        = ColorFromHex("E4E5E6", 0.5, darkHex: "222222")
    
    static let Line_F1F1F1_1_2E2E33_1       = ColorFromHex("F1F1F1", darkHex: "2E2E33")
    static let Line_F1F1F1_1_222222         = ColorFromHex("F1F1F1", darkHex: "222222")
    static let Line_F1F1F1_1_FFFFFF_006     = ColorFromHex("F1F1F1", darkHex: "FFFFFF", darkAlpha: 0.06)
    static let Line_F1F1F1_1_2A2A2A_08      = ColorFromHex("F1F1F1", darkHex: "2A2A2A", darkAlpha: 0.8)
    
    static let Line_F1F1F2_1_222222         = ColorFromHex("F1F1F2", darkHex: "222222")
    static let Line_F1F1F2_1_clear          = ColorFromHex("F1F1F2", darkHex: "")
    
    static let Line_F1F2F2_1_222222         = ColorFromHex("F1F2F2", darkHex: "222222")
    static let Line_F1F2F2_1_464646_05      = ColorFromHex("F1F2F2", darkHex: "464646", darkAlpha: 0.5)
    
    static let Line_D8D8D8_05_222222        = ColorFromHex("D8D8D8", 0.5, darkHex: "222222")
    static let Line_D8D8D8_05_2A2A2A_08     = ColorFromHex("D8D8D8", 0.5, darkHex: "2A2A2A", darkAlpha: 0.8)
    static let Line_D8D8D8_05_ADA7FF_03     = ColorFromHex("D8D8D8", 0.5, darkHex: "ADA7FF", darkAlpha: 0.3)
    
    static let Line_4A4A4A_03               = ColorFromHex("4A4A4A", 0.3)
    
    static let Line_ECECEC_1_222222         = ColorFromHex("ECECEC", darkHex: "FFFFFF", darkAlpha: 0.06)
    
    static let Line_037F5F                  = ColorFromHex("037F5F")
    
    static var Line_EA293C                  = ColorFromHex("EA293C")

        
    // MARK: BL
    static let BL_E8E8E9_1_464646_07       = ColorFromHex("E8E8E9", darkHex: "464646", darkAlpha: 0.7)
    static let BL_E8E8E9_07_464646_1       = ColorFromHex("E8E8E9", 0.7, darkHex: "464646")
    static let BL_E8E8E9_07_464646_05      = ColorFromHex("E8E8E9", 0.7, darkHex: "464646", darkAlpha: 0.5)
    static let BL_E8E8E9_07_464646_07      = ColorFromHex("E8E8E9", 0.7, darkHex: "464646", darkAlpha: 0.7)
    static let BL_E8E8E9_07_FFFFFF_015     = ColorFromHex("E8E8E9", 0.7, darkHex: "FFFFFF", darkAlpha: 0.15)
    static let BL_E8E8E9_07_clear          = ColorFromHex("E8E8E9", 0.7, darkHex: "")
    
    static let BL_F1F1F1                   = ColorFromHex("F1F1F1")
    static let BL_F1F1F1_03                = ColorFromHex("F1F1F1", 0.3)
    static let BL_F1F1F1_1_clear           = ColorFromHex("F1F1F1", darkHex: "")
    static let BL_F1F1F1_07_clear          = ColorFromHex("F1F1F1", 0.7, darkHex: "")
    static let BL_F1F1F1_1_464646_05       = ColorFromHex("F1F1F1", darkHex: "464646", darkAlpha: 0.5)
    
    static let BL_F1F1F2_1_clear           = ColorFromHex("F1F1F2", darkHex: "")
    
    static let BL_F1F2F2_1_clear           = ColorFromHex("F1F2F2", darkHex: "")
    
    static let BL_EDEDEE_1_clear           = ColorFromHex("EDEDEE", darkHex: "")
    
    static let BL_FF507E                   = ColorFromHex("FF507E")
    
    static let BL_6236FF_1_ADA7FF_1        = ColorFromHex("6236FF", darkHex: "ADA7FF")
    static let BL_6236FF_1_clear           = ColorFromHex("6236FF", darkHex: "")
    
    static let BL_06CA64_05                = ColorFromHex("06CA64", 0.5)
    static let BL_06CA64_05_clear          = ColorFromHex("06CA64", 0.5, darkHex: "")
    
    static let BL_008673                   = ColorFromHex("008673")
    static let BL_008673_1_06CA64_1        = ColorFromHex("008673", darkHex: "06CA64")
    
    static var BL_F9F9F9_1_clear           = ColorFromHex("F9F9F9", darkHex: "")
    
    static var BL_9B7FFF                   = ColorFromHex("9B7FFF")
    
    static var BL_clear_404042_1           = ColorFromHex("", darkHex: "404042")
    
    static var BL_E4E5E6_1_464646_07       = ColorFromHex("E4E5E6", darkHex: "464646", darkAlpha: 0.7)
    static var BL_E4E5E6_1_clear           = ColorFromHex("E4E5E6", darkHex: "")
    
    static var BL_FE2B52                   = ColorFromHex("FE2B52")
    
    static let BL_FFFFFF_1_17171A_1        = ColorFromHex("FFFFFF", darkHex: "17171A")
    
    
    // MARK: Text
    
    static let Text_000000                 = ColorFromHex("000000")
    
    static let Text_777790                 = ColorFromHex("777790")
    static let Text_777790_05              = ColorFromHex("777790", 0.5)
    static let Text_777790_1_FFFFFF_1      = ColorFromHex("777790", darkHex: "FFFFFF")
    static let Text_777790_1_FFFFFF_06     = ColorFromHex("777790", darkHex: "FFFFFF", darkAlpha: 0.6)
    static let Text_777790_1_ADA7FF_1      = ColorFromHex("777790", darkHex: "ADA7FF")
    static let Text_777790_1_06CA64_1      = ColorFromHex("777790", darkHex: "06CA64")
    static let Text_777790_1_32C5FF_1      = ColorFromHex("777790", darkHex: "32C5FF")
    
    static let Text_3A0CA3_1_ADA7FF_1      = ColorFromHex("3A0CA3", darkHex: "ADA7FF")
    static let Text_3A0CA3_07_ADA7FF_1     = ColorFromHex("3A0CA3", 0.7, darkHex: "ADA7FF")
    static let Text_3A0CA3_07_ADA7FF_07    = ColorFromHex("3A0CA3", 0.7, darkHex: "ADA7FF", darkAlpha: 0.7)
    static let Text_3A0CA3_1_FFFFFF_1      = ColorFromHex("3A0CA3", darkHex: "FFFFFF")
    
    static var Text_727386                 = ColorFromHex("727386")
    static var Text_727386_1_FFFFFF_1      = ColorFromHex("727386", darkHex: "FFFFFF")
    static var Text_727386_1_FFFFFF_06     = ColorFromHex("727386", darkHex: "FFFFFF", darkAlpha: 0.6)
    
    static var Text_008673                 = ColorFromHex("008673")
    static var Text_008673_1_06CA64_1      = ColorFromHex("008673", darkHex: "06CA64")
    
    static var Text_9B9b9B                 = ColorFromHex("9B9B9B")
    static var Text_9B9b9B_1_707076_1      = ColorFromHex("9B9B9B", darkHex: "707076")
    static var Text_9B9b9B_1_9B9b9B_03     = ColorFromHex("9B9B9B", darkHex: "9B9B9B", darkAlpha: 0.3)
    static var Text_9B9b9B_1_9B9b9B_1      = ColorFromHex("9B9B9B", darkHex: "9B9B9B")
    static var Text_9B9b9B_1_747474_1      = ColorFromHex("9B9B9B", darkHex: "747474")
    
    static var Text_15A84E                 = ColorFromHex("15A84E")
    static var Text_15A84E_106CA64_1       = ColorFromHex("15A84E", darkHex: "06CA64")
    
    static var Text_0091FF                 = ColorFromHex("0091FF")
    static var Text_0091FF_1_32C5FF_1      = ColorFromHex("0091FF", darkHex: "32C5FF")
    
    static var Text_1F9CF8                 = ColorFromHex("1F9CF8")
    
    static var Text_C6C6C6                 = ColorFromHex("C6C6C6")
    static var Text_C6C6C6_1_747474_1      = ColorFromHex("C6C6C6", darkHex: "747474")
    static var Text_C6C6C6_1_5D5D5D_1      = ColorFromHex("C6C6C6", darkHex: "5D5D5D")
    static var Text_C6C6C6_1_777790_1      = ColorFromHex("C6C6C6", darkHex: "777790")
    
    static let Text_6236FF                 = ColorFromHex("6236FF")
    static let Text_6236FF_1_FFFFFF_1      = ColorFromHex("6236FF", darkHex: "FFFFFF")
    static let Text_6236FF_1_ADA7FF_1      = ColorFromHex("6236FF", darkHex: "ADA7FF")
    
    static let Text_FF6200                 = ColorFromHex("FF6200")
    static let Text_FF6200_1_9B9B9B_1      = ColorFromHex("FF6200", darkHex: "9B9B9B")
    
    static let Text_AAABB6                 = ColorFromHex("AAABB6")
    
    static let Text_C7CCD2                 = ColorFromHex("C7CCD2")
    
    static let Text_FFFFFF                 = ColorFromHex("FFFFFF")
    static let Text_FFFFFF_05              = ColorFromHex("FFFFFF", 0.5)
    static let Text_FFFFFF_07              = ColorFromHex("FFFFFF", 0.7)
    static let Text_FFFFFF_08              = ColorFromHex("FFFFFF", 0.8)
    static let Text_FFFFFF_07_777790_1     = ColorFromHex("FFFFFF", 0.7, darkHex: "777790")
    static let Text_FFFFFF_1_000000_1      = ColorFromHex("FFFFFF", darkHex: "000000")
    static let Text_FFFFFF_1_17171A_1      = ColorFromHex("FFFFFF", darkHex: "17171A")
    
    static let Text_4A4A4A                 = ColorFromHex("4A4A4A")
    static let Text_4A4A4A_1_FFFFFF_1      = ColorFromHex("4A4A4A", darkHex: "FFFFFF")
    
    static let Text_FE2B52                 = ColorFromHex("FE2B52")
    static let Text_EA293C_1_FE2B52_1      = ColorFromHex("EA293C", darkHex: "FE2B52")
    
    static let Text_000000_1_727386_1      = ColorFromHex("000000", darkHex: "727386")
    static let Text_000000_1_707076_1      = ColorFromHex("000000", darkHex: "707076")
    static let Text_000000_1_FFFFFF_1      = ColorFromHex("000000", darkHex: "FFFFFF")
    static let Text_000000_1_FFD200_1      = ColorFromHex("000000", darkHex: "FFD200")
    
    static let Text_32C5FF                 = ColorFromHex("32C5FF")
    
    static let Text_4BAE4F                 = ColorFromHex("4BAE4F")
    
    static let Text_F34235                 = ColorFromHex("F34235")
    
    static let Text_0A37F2                 = ColorFromHex("0A37F2")
    
    static let Text_38B000                 = ColorFromHex("38B000")
    
    static let ColorBG_FFFFFF_0_000000_0    = ColorFromHex("FFFFFF", 0, darkHex: "000000", darkAlpha: 0)
    static let ColorBG_FFFFFF_058_000000_058    = ColorFromHex("FFFFFF", 0.58, darkHex: "000000", darkAlpha: 0.58)

    
    // MARK: - 首页顶部渐变背景色
    static let Level_0_Left_1             = ColorFromHex("05D29D")
    static let Level_0_Left_0             = ColorFromHex("05D29D", 0.0)
    static let Level_0_Center_1           = ColorFromHex("0EC517")
    static let Level_0_Center_0           = ColorFromHex("0EC517", 0.0)
    static let Level_0_Right_1            = ColorFromHex("80B917")
    static let Level_0_Right_0            = ColorFromHex("80B917", 0.0)
    
    static let Level_1_Left_1             = ColorFromHex("DE4104")
    static let Level_1_Left_0             = ColorFromHex("DE4104", 0.0)
    static let Level_1_Center_1           = ColorFromHex("F46A07")
    static let Level_1_Center_0           = ColorFromHex("F46A07", 0.0)
    static let Level_1_Right_1            = ColorFromHex("F7971D")
    static let Level_1_Right_0            = ColorFromHex("F7971D", 0.0)
    
    static let Level_2_Left_1             = ColorFromHex("006EFF")
    static let Level_2_Left_0             = ColorFromHex("006EFF", 0.0)
    static let Level_2_Center_1           = ColorFromHex("19B9EE")
    static let Level_2_Center_0           = ColorFromHex("19B9EE", 0.0)
    static let Level_2_Right_1            = ColorFromHex("30DFD3")
    static let Level_2_Right_0            = ColorFromHex("30DFD3", 0.0)
    
    static let Level_3_Left_1             = ColorFromHex("6236FF")
    static let Level_3_Left_0             = ColorFromHex("6236FF", 0.0)
    static let Level_3_Center_1           = ColorFromHex("8E62FF")
    static let Level_3_Center_0           = ColorFromHex("8E62FF", 0.0)
    static let Level_3_Right_1            = ColorFromHex("B58DFF")
    static let Level_3_Right_0            = ColorFromHex("B58DFF", 0.0)
    
    static let Level_4_Left_1             = ColorFromHex("EE1574")
    static let Level_4_Left_0             = ColorFromHex("EE1574", 0.0)
    static let Level_4_Center_1           = ColorFromHex("F60B3E")
    static let Level_4_Center_0           = ColorFromHex("F60B3E", 0.0)
    static let Level_4_Right_1            = ColorFromHex("FD0101")
    static let Level_4_Right_0            = ColorFromHex("FD0101", 0.0)
    
    static let Level_5_Left_1             = ColorFromHex("DBDE17")
    static let Level_5_Left_0             = ColorFromHex("DBDE17", 0.0)
    static let Level_5_Center_1           = ColorFromHex("9CE112")
    static let Level_5_Center_0           = ColorFromHex("9CE112", 0.0)
    static let Level_5_Right_1            = ColorFromHex("57E40D")
    static let Level_5_Right_0            = ColorFromHex("57E40D", 0.0)
}
