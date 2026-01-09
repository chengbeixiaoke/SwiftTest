//
//  Array+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/9.
//

import UIKit

public extension Array {
    /// 安全获取子数组
    /// - Parameters:
    ///   - startIndex: 起始索引 (包含)
    ///   - count: 需要获取的元素个数
    /// - Returns: 子数组，如果索引或数量无效则返回空数组
    func subArray(from startIndex: Int, count: Int) -> [Element]
    {
        // 参数有效性检查
        guard !self.isEmpty,
              startIndex >= 0,
              startIndex < self.count,
              count > 0 else {
            return []
        }
        
        // 计算实际结束位置
        let endIndex = Swift.min(startIndex + count - 1, self.count - 1)
        
        // 再次检查索引有效性
        guard endIndex >= startIndex else {
            return []
        }
        
        // 使用数组切片，更高效
        return Array(self[startIndex...endIndex])
    }
    
    /// 安全获取子数组（更灵活的版本）
    /// - Parameters:
    ///   - startIndex: 起始索引
    ///   - count: 需要获取的元素个数
    ///   - defaultValue: 当数量不足时的默认值填充
    /// - Returns: 始终返回count长度的数组，不足时用默认值填充
    func subArray(from startIndex: Int, count: Int, defaultValue: Element? = nil) -> [Element] {
        let safeSubArray = subArray(from: startIndex, count: count)
        
        // 如果不需要填充或已满足数量
        guard let defaultValue = defaultValue,
              safeSubArray.count < count else {
            return safeSubArray
        }
        
        // 填充到指定长度
        var result = safeSubArray
        let neededCount = count - safeSubArray.count
        result.append(contentsOf: Array(repeating: defaultValue, count: neededCount))
        return result
    }
}
