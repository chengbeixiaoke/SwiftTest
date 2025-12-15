//
//  AppDateFormatterManager.swift
//  CashSAVO
//
//  Created by yyw on 2024/10/25.
//

import Foundation

let unitFlags = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .weekOfMonth, .weekday, .weekdayOrdinal])
//公历
let calendarGregorian = Calendar(identifier: Calendar.Identifier.gregorian)

enum AppFormatterType {
    case hhmma
    case dd
    case ddMM
    case mm月dd日
    case ddMMyy
    case yy年MM月DD日
    case yyyyMM
    case mmDDHHMM
    case yyyyMMDDHHMM
    case MMMMDD
}

open class AppDateFormatterManager {
    public static let shared = AppDateFormatterManager()
    
    lazy var formatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian // 明确使用公历
        formatter.dateFormat = "yyyy/MM/dd HH:mm:SSS"
        return formatter
    }()
    
    lazy var hhmmaFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian
        formatter.dateFormat = "hh:mm a"
        formatter.pmSymbol = "PM"
        formatter.amSymbol = "AM"
        formatter.locale = Locale(identifier: "zh-CN")
        return formatter
    }()
    
    lazy var ddFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian
        formatter.dateFormat = "dd"
        return formatter
    }()
    
    lazy var ddMMFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
    
    lazy var mm月dd日Formatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian
        formatter.dateFormat = "MM月dd日"
        return formatter
    }()
    
    lazy var ddMMyyFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    lazy var yy年MM月DD日Formatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian
        formatter.dateFormat = "yy年MM月dd日"
        return formatter
    }()
    
    lazy var yyyyMMFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian
        formatter.dateFormat = "yyyy/MM"
        return formatter
    }()
    
    lazy var mmDDHHMMFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter
    }()
    
    lazy var yyyyMMDDHHMMFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
    lazy var MMMMDDFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendarGregorian // 明确使用公历
        formatter.dateFormat = "MMMM dd"
        formatter.locale = Locale(identifier: "en")
        return formatter
    }()
    
    func dateString(_ date: Date,
                    formatter: AppFormatterType) -> String
    {
        switch formatter {
        case .hhmma:
            return hhmmaFormatter.string(from: date)
        case .dd:
            return ddFormatter.string(from: date)
        case .ddMM:
            return ddMMFormatter.string(from: date)
        case .mm月dd日:
            return mm月dd日Formatter.string(from: date)
        case .ddMMyy:
            return ddMMyyFormatter.string(from: date)
        case .yy年MM月DD日:
            return yy年MM月DD日Formatter.string(from: date)
        case .yyyyMM:
            return yyyyMMFormatter.string(from: date)
        case .mmDDHHMM:
            return mmDDHHMMFormatter.string(from: date)
        case .yyyyMMDDHHMM:
            return yyyyMMDDHHMMFormatter.string(from: date)
        case .MMMMDD:
            return MMMMDDFormatter.string(from: date)
        }
    }
    
    func dateString(_ date: Int64,
                    formatter: DateFormatter) -> String
    {
        let digitCount = String(date).count
        
        if digitCount == 10 {
            return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(date)))
        }
        else if digitCount == 13 {
            return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(date/1000)))
        }
        else {
            /// 非时间戳
            return ""
        }
    }
    
    // MARK: - 获取当前是周几
    func getWeakdayString(from date: Date) -> String
    {
        let weekday = calendarGregorian.component(.weekday, from: date)
        let titles = ["周日",
                      "周一",
                      "周二",
                      "周三",
                      "周四",
                      "周五",
                      "周六"]
        return titles[weekday - 1]
    }
    
    func dateString(from date: Date) -> String {
        return yy年MM月DD日Formatter.string(from: date)
    }
    
    func dateString(from time: Int64) -> String {
        if String(time).count == 13 {
            let date = Date(timeIntervalSince1970: Double(time)/1000)
            return yy年MM月DD日Formatter.string(from: date)
        }
        else {
            let date = Date(timeIntervalSince1970: TimeInterval(time))
            return yy年MM月DD日Formatter.string(from: date)
        }
    }
}
