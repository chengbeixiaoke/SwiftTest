//
//  Color+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2025/1/9.
//

import UIKit

func ColorFromHex (_ hex: String, _ alpha: CGFloat = 1) -> UIColor {
    if hex.isEmpty {
        return UIColor.clear
    }
    if hex.count < 6 {
        return UIColor.clear
    }
    
    return color(value: hex, alpha: alpha);
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


