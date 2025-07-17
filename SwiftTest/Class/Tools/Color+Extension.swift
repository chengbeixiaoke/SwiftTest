//
//  Color+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2025/1/9.
//

import UIKit

// color
func ColorFromHex (_ hex: String, _ alpha: CGFloat = 1, darkHex: String? = nil, darkAlpha: CGFloat = 1) -> UIColor {
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

private func color(value: Any, alpha: CGFloat = 1) -> UIColor {
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


extension UIColor {
    // MARK: - color 不会根据主题颜色改变
    static var C_Black = ColorFromHex("000000")
    static var C_White = ColorFromHex("FFFFFF")
    static var C_Clear = ColorFromHex("")
    
    // MARK: - Color 根据主题颜色改变
    static var ColorWhite = ColorFromHex("FFFFFF", darkHex: "17171A")
    static var ColorBlack = ColorFromHex("000000", darkHex: "FFFFFF")

    // bg
    static let ColorBG_FFFFFF_015           = ColorFromHex("FFFFFF", 0.15)
    static let ColorBG_FFFFFF_02            = ColorFromHex("FFFFFF", 0.2)
    static let ColorBG_FFFFFF_03            = ColorFromHex("FFFFFF", 0.3)
    static let ColorBG_FFFFFF_08            = ColorFromHex("FFFFFF", 0.8)
    static let ColorBG_FFFFFF_1_FFFFFF_01   = ColorFromHex("FFFFFF", darkHex: "FFFFFF", darkAlpha: 0.1)
    static let ColorBG_FFFFFF_1_FFFFFF_003  = ColorFromHex("FFFFFF", darkHex: "FFFFFF", darkAlpha: 0.03)
    static let ColorBG_FFFFFF_1_ADA7FF_01   = ColorFromHex("FFFFFF", darkHex: "ADA7FF", darkAlpha: 0.1)
    static let ColorBG_FFFFFF_1_F1F1F1_005  = ColorFromHex("FFFFFF", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let ColorBG_FFFFFF_1_FE2B52_008  = ColorFromHex("FFFFFF", darkHex: "FE2B52", darkAlpha: 0.08)
    static var ColorBG_FFFFFF_1_1F1F1F_1    = ColorFromHex("FFFFFF", darkHex: "1F1F1F")
    static let ColorBG_FFFFFF_1_222225_1    = ColorFromHex("FFFFFF", darkHex: "222225")
    static let ColorBG_FFFFFF_08_17171A_1   = ColorFromHex("FFFFFF", 0.8, darkHex: "17171A")
    static let ColorBG_FFFFFF_1_2C2C2F_1    = ColorFromHex("FFFFFF", darkHex: "2C2C2F")
    static let ColorBG_FFFFFF_1_262626_1    = ColorFromHex("FFFFFF", darkHex: "262626")
    static let ColorBG_FFFFFF_1_2D2D2D_1    = ColorFromHex("FFFFFF", darkHex: "2D2D2D")
    static let ColorBG_FFFFFF_1_1D1D20_1    = ColorFromHex("FFFFFF", darkHex: "1D1D20")
    static let ColorBG_FFFFFF_1_17171A_1   = ColorFromHex("FFFFFF", darkHex: "17171A")
    static let ColorBG_FFFFFF_1_222222_1    = ColorFromHex("FFFFFF", darkHex: "222222")

    static let ColorBG_000000_06            = ColorFromHex("000000", 0.6)
    static var ColorBG_000000_1_008673_1    = ColorFromHex("000000", darkHex: "008673")
    static var ColorBG_000000_1_6236FF_1    = ColorFromHex("000000", darkHex: "6236FF")
    static var ColorBG_000000_03_777790_1   = ColorFromHex("000000", 0.3, darkHex: "777790")
    static let ColorBG_000000_03_FFFFFF_03  = ColorFromHex("000000", 0.3, darkHex: "FFFFFF", darkAlpha: 0.3)
    static let ColorBG_000000_1_FFFFFF_01   = ColorFromHex("000000", darkHex: "FFFFFF", darkAlpha: 0.1)
    static let ColorBG_000000_1_FFFFFF_02   = ColorFromHex("000000", darkHex: "FFFFFF", darkAlpha: 0.2)
    static let ColorBG_000000_1_FFFFFF_1   = ColorFromHex("000000", darkHex: "FFFFFF")
    
    static let ColorBG_6236FF               = ColorFromHex("6236FF")
    static let ColorBG_6236FF_003           = ColorFromHex("6236FF", 0.03)
    static let ColorBG_6236FF_005           = ColorFromHex("6236FF", 0.05)
    static let ColorBG_6236FF_01            = ColorFromHex("6236FF", 0.1)
    static let ColorBG_6236FF_02            = ColorFromHex("6236FF", 0.2)
    static let ColorBG_6236FF_06            = ColorFromHex("6236FF", 0.6)
    static let ColorBG_6236FF_07            = ColorFromHex("6236FF", 0.7)
    static let ColorBG_6236FF_1_3C3F4A_1    = ColorFromHex("6236FF", darkHex: "3C3F4A")
    static let ColorBG_6236FF_1_ADA7FF_1    = ColorFromHex("6236FF", darkHex: "ADA7FF")
    static let ColorBG_6236FF_003_ADA7FF_01 = ColorFromHex("6236FF", 0.03, darkHex: "ADA7FF", darkAlpha: 0.1)
    static let ColorBG_6236FF_01_ADA7FF_01  = ColorFromHex("6236FF", 0.1, darkHex: "ADA7FF", darkAlpha: 0.1)
    static let ColorBG_6236FF_1_FFFFFF_01   = ColorFromHex("6236FF", darkHex: "FFFFFF", darkAlpha: 0.1)
    static let ColorBG_6236FF_1_FFFFFF_1    = ColorFromHex("6236FF", darkHex: "FFFFFF", darkAlpha: 1)
    static let ColorBG_6236FF_1_clear       = ColorFromHex("6236FF", darkHex: "")
    static let ColorBG_6236FF_005_FFFFFF_02 = ColorFromHex("6236FF", 0.05, darkHex: "FFFFFF", darkAlpha: 0.2)

    static let ColorBG_FF6200               = ColorFromHex("FF6200")
    
    static let ColorBG_FCFCFC               = ColorFromHex("FCFCFC")
    static let ColorBG_FCFCFC_1_FFFFFF_003  = ColorFromHex("FCFCFC", darkHex: "FFFFFF", darkAlpha: 0.03)
    static let ColorBG_FCFCFC_1_FFFFFF_005  = ColorFromHex("FCFCFC", darkHex: "FFFFFF", darkAlpha: 0.05)
    static let ColorBG_FCFCFC_1_FFFFFF_008  = ColorFromHex("FCFCFC", darkHex: "FFFFFF", darkAlpha: 0.08)
    static let ColorBG_FCFCFC_1_222225_1    = ColorFromHex("FCFCFC", darkHex: "222225")
    static let ColorBG_FCFCFC_1_ADA7FF_01   = ColorFromHex("FCFCFC", darkHex: "ADA7FF", darkAlpha: 0.1)
    static let ColorBG_FCFCFC_1_FE2B52_008  = ColorFromHex("FCFCFC", darkHex: "FE2B52", darkAlpha: 0.08)
    static let ColorBG_FCFCFC_1_F1F1F1_005  = ColorFromHex("FCFCFC", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let ColorBG_FCFCFC_1_1D1D20_1    = ColorFromHex("FCFCFC", darkHex: "1D1D20")
    
    static let ColorBG_F7F7F7_1_F1F1F1_005  = ColorFromHex("F7F7F7", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let ColorBG_F7F7F7_1_222225_1    = ColorFromHex("F7F7F7", darkHex: "222225")
    
    static let ColorBG_FAFAFA_1_F1F1F1_005  = ColorFromHex("FAFAFA", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let ColorBG_FAFAFA_1_222225_1    = ColorFromHex("FAFAFA", darkHex: "222225")

    static let ColorBG_F1F1F2               = ColorFromHex("F1F1F2")
    static let ColorBG_F1F1F2_2E2E33        = ColorFromHex("F1F1F1", darkHex: "2E2E33")
    
    static let ColorBG_F1F2F2               = ColorFromHex("F1F2F2")

    static let ColorBG_F1F1F1               = ColorFromHex("F1F1F1")
    static let ColorBG_F1F1F1_07            = ColorFromHex("F1F1F1", 0.7)
    static let ColorBG_F1F1F1_07_clear             = ColorFromHex("F1F1F1", 0.7, darkHex: "")
    static let ColorBG_F1F1F1_1_F1F1F1_005  = ColorFromHex("F1F1F1", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let ColorBG_F1F1F1_07_F1F1F1_005 = ColorFromHex("F1F1F1", 0.7, darkHex: "F1F1F1", darkAlpha: 0.05)
    static let ColorBG_F1F1F1_1_27272D_1    = ColorFromHex("F1F1F1", darkHex: "27272D")
    static let ColorBG_F1F1F1_1_2D2D2D_1    = ColorFromHex("F1F1F1", darkHex: "2D2D2D")
    static let ColorBG_F1F1F1_1_FE2B52_1    = ColorFromHex("F1F1F1", darkHex: "FE2B52")
    static let ColorBG_F1F1F1_1_2A2A2A_1    = ColorFromHex("F1F1F1", darkHex: "2A2A2A")
    static let ColorBG_F1F1F1_1_clear       = ColorFromHex("F1F1F1", darkHex: "")
    static let ColorBG_F1F1F1_1_222225_1    = ColorFromHex("F1F1F1", darkHex: "222225")
    static let ColorBG_F1F1F1_05_F1F1F1_02  = ColorFromHex("F1F1F1", 0.5, darkHex: "F1F1F1", darkAlpha: 0.2)
    
    static let ColorBG_D8D8D8               = ColorFromHex("D8D8D8")
    static let ColorBG_D8D8D8_05            = ColorFromHex("D8D8D8", 0.5)
    static let ColorBG_D8D8D8_1_D8D8D8_02   = ColorFromHex("D8D8D8", darkHex: "D8D8D8", darkAlpha: 0.2)
    static let ColorBG_D8D8D8_07_D8D8D8_02  = ColorFromHex("D8D8D8", 0.7, darkHex: "D8D8D8", darkAlpha: 0.2)
    static let ColorBG_D8D8D8_05_D8D8D8_02  = ColorFromHex("D8D8D8", 0.5, darkHex: "D8D8D8", darkAlpha: 0.2)
    static let ColorBG_D8D8D8_07_1E1E21_1   = ColorFromHex("D8D8D8", 0.7, darkHex: "1E1E21")
    static let ColorBG_D8D8D8_05_FFFFFF_01  = ColorFromHex("D8D8D8", 0.5, darkHex: "FFFFFF", darkAlpha: 0.1)
    static let ColorBG_D8D8D8_1_F1F1F1_005  = ColorFromHex("D8D8D8", darkHex: "F1F1F1", darkAlpha: 0.05)
    static let ColorBG_D8D8D8_1_FFFFFF_02   = ColorFromHex("D8D8D8", darkHex: "FFFFFF", darkAlpha: 0.2)
    static let ColorBG_D8D8D8_1_9B9B9B_1    = ColorFromHex("D8D8D8", darkHex: "9B9B9B")


    static let ColorBG_FE2B52               = ColorFromHex("FE2B52")

    static let ColorBG_F8F8F8               = ColorFromHex("F8F8F8")
    static let ColorBG_F8F8F8_1_222225_1    = ColorFromHex("F8F8F8", darkHex: "222225")
    static let ColorBG_F8F8F8_1_F8F8F8_005  = ColorFromHex("F8F8F8", darkHex: "F8F8F8", darkAlpha: 0.05)
    static let ColorBG_F8F8F8_1_F1F1F1_005  = ColorFromHex("F8F8F8", darkHex: "F1F1F1", darkAlpha: 0.05)

    static let ColorBG_F8F7F9_1_222225_1    = ColorFromHex("F8F7F9", darkHex: "222225")

    static let ColorBG_06CA64               = ColorFromHex("06CA64")
    static let ColorBG_06CA64_003_06CA64_019 = ColorFromHex("06CA64", 0.03, darkHex: "06CA64", darkAlpha: 0.19)
    static let ColorBG_06CA64_003_FFFFFF_003 = ColorFromHex("06CA64", 0.03, darkHex: "FFFFFF", darkAlpha: 0.03)

    static let ColorBG_4E566B_1_3C3F4A_1    = ColorFromHex("4E566B", darkHex: "3C3F4A")
    
    static let ColorBG_00ABFF               = ColorFromHex("00ABFF")
    
    static let ColorBG_F2F1F3_1_FFFFFF_1    = ColorFromHex("F2F1F3", darkHex: "FFFFFF")
    static let ColorBG_F2F1F3_1_F1F1F1_005  = ColorFromHex("F2F1F3", darkHex: "F1F1F1", darkAlpha: 0.05)
    
    static var ColorBG_008673               = ColorFromHex("008673")
    static var ColorBG_008673_003           = ColorFromHex("008673", 0.03)
    static var ColorBG_008673_1_3C3F4A_1    = ColorFromHex("008673", darkHex: "3C3F4A")
    
    
    static var ColorBG_EA293C               = ColorFromHex("EA293C")
    
    static let ColorBG_C6C6C6_02            = ColorFromHex("C6C6C6", 0.2)
    static let ColorBG_C6C6C6_02_27272D_1   = ColorFromHex("C6C6C6", 0.2, darkHex: "27272D")
    static let ColorBG_C6C6C6_03_27272D_1   = ColorFromHex("C6C6C6", 0.3, darkHex: "27272D")
    
    
    static let ColorBG_1D61EE               = ColorFromHex("1D61EE")
    static let ColorBG_1D61EE_1_3D3D3D_1    = ColorFromHex("1D61EE", darkHex: "3D3D3D")
    
    static let ColorBG_480CA8               = ColorFromHex("480CA8")
    
    static var ColorBG_0091FF               = ColorFromHex("0091FF")
    
    static var ColorBG_B7B6BC               = ColorFromHex("B7B6BC")
    static var ColorBG_B7B6BC_1_4A4A4A_1    = ColorFromHex("B7B6BC", darkHex: "4A4A4A")
    static var ColorBG_B7B6BC_1_9B9B9B_1    = ColorFromHex("B7B6BC", darkHex: "9B9B9B")
    
    static var ColorBG_727386_003           = ColorFromHex("727386", 0.03)

    static var ColorBG_FF6200_01            = ColorFromHex("FF6200", 0.1, darkHex: "9B9B9B", darkAlpha: 0.1)
    
    static var ColorBG_9B9B9B               = ColorFromHex("9B9B9B")
    static var ColorBG_9B9B9B_01            = ColorFromHex("9B9B9B", 0.1)
    static var ColorBG_9B9B9B_03            = ColorFromHex("9B9B9B", 0.3)
    static var ColorBG_9B9B9B_1_D8D8D8_1    = ColorFromHex("9B9B9B", darkHex: "D8D8D8")

    static var ColorBG_clear_F1F1F1_005     = ColorFromHex("", darkHex: "F1F1F1", darkAlpha: 0.05)
    static var ColorBG_clear_FFFFFF_015     = ColorFromHex("", darkHex: "FFFFFF", darkAlpha: 0.15)
    static var ColorBG_clear_6236FF         = ColorFromHex("", darkHex: "6236FF")

    static var ColorBG_F9F9F9_1_F1F1F1_005  = ColorFromHex("F9F9F9", darkHex: "F1F1F1", darkAlpha: 0.05)
        
    static var ColorBG_F9F8FA_1_222225_1    = ColorFromHex("F9F8FA", darkHex: "222225")
    
    static var ColorBG_F8FCFB_1_06CA64_003  = ColorFromHex("F8FCFB", darkHex: "06CA64", darkAlpha: 0.03)
    
    static var ColorBG_F9F8FA_1_FFFFFF_02   = ColorFromHex("F9F8FA", darkHex: "FFFFFF", darkAlpha: 0.2)
    
    static var ColorBG_4A4A4A               = ColorFromHex("4A4A4A")
    static var ColorBG_4A4A4A_1_FFFFFF_1    = ColorFromHex("4A4A4A", darkHex: "FFFFFF", darkAlpha: 1)
    
    static var ColorBG_1F1F1F               = ColorFromHex("1F1F1F")
    
    static let ColorBG_27272D               = ColorFromHex("27272D")
    
    static let ColorBG_BE031F               = ColorFromHex("BE031F")
    
    static let ColorBG_14746F               = ColorFromHex("14746F")
    
    static let ColorBG_C9184A               = ColorFromHex("C9184A")
    
    static let ColorBG_979797_005_FFFFFF_003 = ColorFromHex("979797", 0.05, darkHex: "FFFFFF", darkAlpha: 0.03)
    
    // line
    static var ColorLine_E4E5E6_05              = ColorFromHex("E4E5E6", 0.5)
    static var ColorLine_E4E5E6_05_E4E5E6_02    = ColorFromHex("E4E5E6", 0.5, darkHex: "E4E5E6", darkAlpha: 0.2)
    static var ColorLine_E4E5E6_05_2A2A2E_1     = ColorFromHex("E4E5E6", 0.5, darkHex: "2A2A2E")
    static var ColorLine_E4E5E6_05_2E2E33_1     = ColorFromHex("E4E5E6", 0.5, darkHex: "2E2E33")
    static var ColorLine_E4E5E6_05_2A2A2E_05    = ColorFromHex("E4E5E6", 0.5, darkHex: "2A2A2E", darkAlpha: 0.5)

    static let ColorLine_F1F1F1_1_2E2E33_1      = ColorFromHex("F1F1F1", darkHex: "2E2E33")
    static let ColorLine_F1F1F1_1_2A2A2E_1      = ColorFromHex("F1F1F1", darkHex: "2A2A2E")

    static let ColorLine_F1F1F2_1_2E2E33_1      = ColorFromHex("F1F1F2", darkHex: "2E2E33")
    static let ColorLine_F1F1F2_1_2A2A2E_1      = ColorFromHex("F1F1F2", darkHex: "2A2A2E")
    
    static let ColorLine_F1F2F2_1_2A2A2E_1      = ColorFromHex("F1F2F2", darkHex: "2A2A2E")
    static let ColorLine_F1F2F2_1_2E2E33_1      = ColorFromHex("F1F2F2", darkHex: "2E2E33")
    
    static let ColorLine_D8D8D8_05_2E2E33_1     = ColorFromHex("D8D8D8", 0.5, darkHex: "2E2E33")
    static let ColorLine_D8D8D8_05_2A2A2E_1     = ColorFromHex("D8D8D8", 0.5, darkHex: "2A2A2E")
    
    static let ColorLine_4A4A4A_03              = ColorFromHex("4A4A4A", 0.3)
    
    
    // border
    static let ColorBL_E8E8E9_1_464646_07       = ColorFromHex("E8E8E9", darkHex: "464646", darkAlpha: 0.7)
    static let ColorBL_E8E8E9_07_464646_1       = ColorFromHex("E8E8E9", 0.7, darkHex: "464646")
    static let ColorBL_E8E8E9_07_464646_05      = ColorFromHex("E8E8E9", 0.7, darkHex: "464646", darkAlpha: 0.5)
    static let ColorBL_E8E8E9_07_464646_07      = ColorFromHex("E8E8E9", 0.7, darkHex: "464646", darkAlpha: 0.7)
    static let ColorBL_E8E8E9_07_FFFFFF_015     = ColorFromHex("E8E8E9", 0.7, darkHex: "FFFFFF", darkAlpha: 0.15)
    static let ColorBL_E8E8E9_07_clear          = ColorFromHex("E8E8E9", 0.7, darkHex: "")

    static let ColorBL_F1F1F1_03                = ColorFromHex("F1F1F1", 0.3)
    static let ColorBL_F1F1F1_1_clear           = ColorFromHex("F1F1F1", darkHex: "")
    static let ColorBL_F1F1F1_07_clear          = ColorFromHex("F1F1F1", 0.7, darkHex: "")
    static let ColorBL_F1F1F1_1_222225_1        = ColorFromHex("F1F1F1", darkHex: "222225")
    static let ColorBL_F1F1F1_1_464646_05       = ColorFromHex("F1F1F1", darkHex: "464646", darkAlpha: 0.5)

    static let ColorBL_F1F1F2_1_clear           = ColorFromHex("F1F1F2", darkHex: "")
    
    static let ColorBL_F1F2F2_1_clear           = ColorFromHex("F1F2F2", darkHex: "")

    static let ColorBL_FF507E                   = ColorFromHex("FF507E")
    
    static let ColorBL_6236FF_1_ADA7FF_1        = ColorFromHex("6236FF", darkHex: "ADA7FF")
    static let ColorBL_6236FF_1_clear           = ColorFromHex("6236FF", darkHex: "")
    
    static let ColorBL_06CA64_05                = ColorFromHex("06CA64", 0.5)
    static let ColorBL_06CA64_05_clear          = ColorFromHex("06CA64", 0.5, darkHex: "")
    
    static let ColorBL_008673                   = ColorFromHex("008673")
    static let ColorBL_008673_1_06CA64_1        = ColorFromHex("008673", darkHex: "06CA64")
    
    static var ColorBL_F9F9F9_1_clear           = ColorFromHex("F9F9F9", darkHex: "")
    
    static var ColorBL_9B7FFF                   = ColorFromHex("9B7FFF")

    static var ColorBL_clear_404042_1           = ColorFromHex("", darkHex: "404042")

    static var ColorBL_E4E5E6_1_464646_07       = ColorFromHex("E4E5E6", darkHex: "464646", darkAlpha: 0.7)
    static var ColorBL_E4E5E6_1_clear           = ColorFromHex("E4E5E6")

    static var ColorBL_FE2B52_1                 = ColorFromHex("FE2B52")
    
    
    
    // text
    static let ColorText_777790                 = ColorFromHex("777790")
    static let ColorText_777790_05              = ColorFromHex("777790", 0.5)
    static let ColorText_777790_1_FFFFFF_1      = ColorFromHex("777790", darkHex: "FFFFFF")
    static let ColorText_777790_1_FFFFFF_06     = ColorFromHex("777790", darkHex: "FFFFFF", darkAlpha: 0.6)
    static let ColorText_777790_1_ADA7FF_1      = ColorFromHex("777790", darkHex: "ADA7FF")
    static let ColorText_777790_1_06CA64_1      = ColorFromHex("777790", darkHex: "06CA64")
    static let ColorText_777790_1_32C5FF_1      = ColorFromHex("777790", darkHex: "32C5FF")

    static let ColorText_3A0CA3_1_ADA7FF_1      = ColorFromHex("3A0CA3", darkHex: "ADA7FF")
    static let ColorText_3A0CA3_07_ADA7FF_1     = ColorFromHex("3A0CA3", 0.7, darkHex: "ADA7FF")
    static let ColorText_3A0CA3_07_ADA7FF_07    = ColorFromHex("3A0CA3", 0.7, darkHex: "ADA7FF", darkAlpha: 0.7)
    static let ColorText_3A0CA3_1_FFFFFF_1      = ColorFromHex("3A0CA3", darkHex: "FFFFFF")
    
    static var ColorText_727386                 = ColorFromHex("727386")
    static var ColorText_727386_1_FFFFFF_1       = ColorFromHex("727386", darkHex: "FFFFFF")
    
    static var ColorText_008673                 = ColorFromHex("008673")
    static var ColorText_008673_1_06CA64_1      = ColorFromHex("008673", darkHex: "06CA64")
    
    static var ColorText_9B9b9B                 = ColorFromHex("9B9B9B")
    static var ColorText_9B9b9B_1_707076_1      = ColorFromHex("9B9B9B", darkHex: "707076")
    static var ColorText_9B9b9B_1_9B9b9B_03     = ColorFromHex("9B9B9B", darkHex: "9B9B9B", darkAlpha: 0.3)
    
    static var ColorText_15A84E                 = ColorFromHex("15A84E")
    static var ColorText_15A84E_106CA64_1       = ColorFromHex("15A84E", darkHex: "06CA64")
    
    static var ColorText_0091FF                 = ColorFromHex("0091FF")
    static var ColorText_0091FF_1_32C5FF_1      = ColorFromHex("0091FF", darkHex: "32C5FF")
    
    static var ColorText_1F9CF8                 = ColorFromHex("1F9CF8")
    
    static var ColroText_C6C6C6                 = ColorFromHex("C6C6C6")
    static var ColroText_C6C6C6_1_747474_1      = ColorFromHex("C6C6C6", darkHex: "747474")
    static var ColroText_C6C6C6_1_5D5D5D_1      = ColorFromHex("C6C6C6", darkHex: "5D5D5D")
    static var ColorText_C6C6C6_1_777790_1      = ColorFromHex("C6C6C6", darkHex: "777790")
    
    static let ColorText_6236FF                 = ColorFromHex("6236FF")
    static let ColorText_6236FF_1_FFFFFF_1      = ColorFromHex("6236FF", darkHex: "FFFFFF")
    static let ColorText_6236FF_1_ADA7FF_1      = ColorFromHex("6236FF", darkHex: "ADA7FF")
    
    static let ColorText_FF6200                 = ColorFromHex("FF6200")
    static let ColorText_FF6200_1_9B9B9B_1      = ColorFromHex("FF6200", darkHex: "9B9B9B")

    static let ColorText_AAABB6                 = ColorFromHex("AAABB6")
    
    static let ColorText_C7CCD2                 = ColorFromHex("C7CCD2")
    
    static let ColorText_FFFFFF                 = ColorFromHex("FFFFFF")
    static let ColorText_FFFFFF_05              = ColorFromHex("FFFFFF", 0.5)
    static let ColorText_FFFFFF_07              = ColorFromHex("FFFFFF", 0.7)
    static let ColorText_FFFFFF_08              = ColorFromHex("FFFFFF", 0.8)
    static let ColorText_FFFFFF_07_777790_1     = ColorFromHex("FFFFFF", 0.7, darkHex: "777790")
    static let ColorText_FFFFFF_1_000000_1      = ColorFromHex("FFFFFF", darkHex: "000000")

    static let ColorText_4A4A4A                 = ColorFromHex("4A4A4A")
    static let ColorText_4A4A4A_1_FFFFFF_1      = ColorFromHex("4A4A4A", darkHex: "FFFFFF")
    
    static let ColorText_FE2B52                 = ColorFromHex("FE2B52")
    static let ColorText_EA293C_1_FE2B52_1      = ColorFromHex("EA293C", darkHex: "FE2B52")

    static let ColorText_000000_1_727386_1      = ColorFromHex("000000", darkHex: "727386")
    static let ColorText_000000_1_707076_1      = ColorFromHex("000000", darkHex: "707076")
    static let ColorText_000000_1_FFFFFF_1      = ColorFromHex("000000", darkHex: "FFFFFF")
    static let ColorText_000000_1_FFD200_1      = ColorFromHex("000000", darkHex: "FFD200")
    
    static let ColorText_32C5FF                 = ColorFromHex("32C5FF")
}
