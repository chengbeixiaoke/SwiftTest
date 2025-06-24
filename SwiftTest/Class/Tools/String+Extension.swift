//
//  String+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2025/6/16.
//

import UIKit

extension String {
    func extractURLsFromText() -> [String] {
        let pattern = "(https?|ftp):\\/\\/[^\\s\\u4e00-\\u9fa5，。、；：（）「」【】]+"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return []
        }
        
        let nsString = self as NSString
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
        
        return matches.map { match in
            nsString.substring(with: match.range)
        }.map { originUrl in
            print(originUrl)
            // 二次验证确保是有效URL
            let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let match = detector?.firstMatch(in: originUrl, options: [], range: NSRange(location: 0, length: originUrl.utf16.count))
            if match?.range.length == originUrl.utf16.count {
                return originUrl
            }
            else {
                return String(originUrl.prefix(match?.range.length ?? 0))
            }
        }
    }
    
    func parseURL() -> [String: Any]? {
        guard let urlComponents = URLComponents(string: self) else {
            print("无效的URL格式")
            return nil
        }
        
        var result = [String: Any]()
        
        // 1. 获取scheme (http/https)
        if let scheme = urlComponents.scheme {
            result["scheme"] = scheme
        }
        
        // 2. 获取host (域名)
        if let host = urlComponents.host {
            result["host"] = host
            
            // 提取主域名（二级域名）
            let parts = host.components(separatedBy: ".")
            if parts.count >= 2 {
                result["mainDomain"] = "\(parts[parts.count-2]).\(parts.last!)"
            }
        }
        
        // 3. 获取path (路径)
        result["path"] = urlComponents.path
        
        // 4. 解析query参数
        if let queryItems = urlComponents.queryItems {
            var queryParams = [String: String]()
            for item in queryItems {
                queryParams[item.name] = item.value
            }
            if !queryParams.isEmpty {
                result["queryParameters"] = queryParams
            }
        }
        
        // 5. 获取fragment (锚点)
        if let fragment = urlComponents.fragment {
            result["fragment"] = fragment
        }
        
        // 6. 获取port (端口)
        if let port = urlComponents.port {
            result["port"] = port
        }
        
        return result
    }
}
