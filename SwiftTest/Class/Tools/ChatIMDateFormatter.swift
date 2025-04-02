//
//  ChatIMDateFormatter.swift
//  CashSAVO
//
//  Created by yyw on 2024/10/25.
//

import Foundation

open class ChatIMDateFormatter {
    
    // MARK: - Properties
    
    public static let shared = ChatIMDateFormatter()
    lazy var formatter3 = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss SSS"
        return formatter
    }()
    
    func dateString(from date: Date) -> String {
        /// yyyy年MM月dd日
        return formatter3.string(from: date)
    }
    
    func dateString(from time: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(time)/1000)
        /// yyyy年MM月dd日
        return formatter3.string(from: date)
    }
}
