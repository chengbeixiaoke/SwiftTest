//
//  DeviceInfoTools.swift
//  SwiftTest
//
//  Created by yyw on 2026/9/10.
//

import UIKit
import CoreTelephony
import NetworkExtension
import CFNetwork

class DeviceInfoTools {
    static func mayHaveVPN() -> Bool {
        guard let settings = CFNetworkCopySystemProxySettings()?
            .takeRetainedValue() as? [String: Any],
              let scoped = settings["__SCOPED__"] as? [String: Any]
        else {
            return false
        }
        
        let prefixes = ["utun", "ppp", "ipsec", "tap", "tun"]
        
        return scoped.keys.contains { interface in
            prefixes.contains { interface.hasPrefix($0) }
        }
    }
    
    static func carrierInfo() {
        let networkInfo = CTTelephonyNetworkInfo()
        print("============================================================")
        // 运营商信息
        networkInfo.serviceSubscriberCellularProviders?.values.forEach { carrier in
            printLog("[CoreTelephony] name: \(String(describing: carrier.carrierName)), mcc: \(String(describing: carrier.mobileCountryCode)), mnc\(String(describing: carrier.mobileNetworkCode))")
        }
        
        // 是否注册了蜂窝网络
        let info = CTTelephonyNetworkInfo()
        let technologies = info.serviceCurrentRadioAccessTechnology
        if let technologies, !technologies.isEmpty {
            print("检测到已注册的蜂窝服务：\(technologies)")
        } else {
            print("未检测到已注册的蜂窝服务")
        }
        
        // 电量/是否正在充电
        UIDevice.current.isBatteryMonitoringEnabled = true
        // 0.0 ~ 1.0；-1 表示未知
        let percent = Int(UIDevice.current.batteryLevel * 100)
        print("电量：\(percent)%")
        
        switch UIDevice.current.batteryState {
        case .charging:
            print("正在充电")
        case .full:
            print("已充满，仍接通电源")
        case .unplugged:
            print("未充电")
        case .unknown:
            print("充电状态未知")
        @unknown default:
            break
        }
        
        // 检测VPN
        if mayHaveVPN() {
            print("开启 VPN")
        } else {
            print("未开启 VPN")
        }
        
        print("============================================================")
    }
}
