//
//  KLineDataGenerator3.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/11.
//

import UIKit
import Foundation

// MARK: - K线数据结构
class CandleStickData: Identifiable {
    public let id = UUID()
    public let date: Date
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let volume: Double
    public let amount: Double? // 成交额（可选）
    
    // 成交量柱状图高度
    public var volumeHeight: CGFloat = 0
    
    public init(date: Date, open: Double, high: Double, low: Double, close: Double, volume: Double, amount: Double?) {
        self.date = date
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
        self.amount = amount
    }
    
    public var isIncrease: Bool {
        return close >= open
    }
    
    public var change: Double {
        return close - open
    }
    
    // 是否是上涨
    var isUp: Bool {
        return change >= 0
    }
    
    public var changePercent: Double {
        return (close - open) / open * 100
    }
    
    // 为了方便时间序列分析，添加时间戳
    public var timestamp: TimeInterval {
        return date.timeIntervalSince1970
    }
    
    public var date_yyyymm: String {
        return AppDateFormatterManager.shared.dateString(date, formatter: .yyyyMM)
    }
    
    public var date_ddmm: String {
        return AppDateFormatterManager.shared.dateString(date, formatter: .ddMMyy)
    }
}

// MARK: - A股交易时间管理
class AShareTradingCalendar {
    
    // A股交易时间（北京时间）
    static let marketOpenTime = (hour: 9, minute: 30)  // 9:30
    static let morningCloseTime = (hour: 11, minute: 30) // 11:30
    static let afternoonOpenTime = (hour: 13, minute: 0) // 13:00
    static let marketCloseTime = (hour: 15, minute: 0)   // 15:00
    
    // 检查是否为交易日
    static func isTradingDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        
        // 1. 检查是否为周六或周日
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 1 || weekday == 7 { // 1=周日, 7=周六
            return false
        }
        
        // 2. 这里可以添加中国节假日判断
        // 实际应用中应该从API或本地数据库获取节假日数据
        if isChineseHoliday(date) {
            return false
        }
        
        return true
    }
    
    // 检查是否为交易时间（分钟级别数据使用）
    static func isTradingTime(_ date: Date) -> Bool {
        guard isTradingDay(date) else { return false }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        // 上午交易时间：9:30 - 11:30
        let isMorningTrading = (hour == 9 && minute >= 30) ||
                               (hour == 10) ||
                               (hour == 11 && minute <= 30)
        
        // 下午交易时间：13:00 - 15:00
        let isAfternoonTrading = (hour == 13 && minute >= 0) ||
                                 (hour == 14) ||
                                 (hour == 15 && minute == 0)
        
        return isMorningTrading || isAfternoonTrading
    }
    
    // 获取下一个交易日
    static func nextTradingDay(from date: Date) -> Date? {
        let calendar = Calendar.current
        var currentDate = date
        
        for _ in 0..<30 { // 最多查找30天
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDay
                if isTradingDay(currentDate) {
                    return currentDate
                }
            }
        }
        return nil
    }
    
    // 简化版的中国节假日判断（示例，实际应该使用完整数据）
    private static func isChineseHoliday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        _ = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // 示例：春节假期（正月初一至初七）
        // 这里只是示例，实际应该使用完整的节假日日历
        if month == 1 && day >= 1 && day <= 7 {
            return true
        }
        
        // 国庆节（10月1日-7日）
        if month == 10 && day >= 1 && day <= 7 {
            return true
        }
        
        return false
    }
    
    // 生成交易日列表
    static func generateTradingDays(from startDate: Date, to endDate: Date) -> [Date] {
        var tradingDays: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            if isTradingDay(currentDate) {
                tradingDays.append(currentDate)
            }
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDay
        }
        
        return tradingDays
    }
    
    // 生成交易日内的分钟时间点（用于分时K线）
    static func generateTradingMinutes(for date: Date, minuteInterval: Int) -> [Date] {
        guard isTradingDay(date) else { return [] }
        
        var tradingMinutes: [Date] = []
        let calendar = Calendar.current
        
        // 上午交易时间段
        var morningTime = calendar.date(
            bySettingHour: marketOpenTime.hour,
            minute: marketOpenTime.minute,
            second: 0,
            of: date
        )!
        
        let morningEndTime = calendar.date(
            bySettingHour: morningCloseTime.hour,
            minute: morningCloseTime.minute,
            second: 0,
            of: date
        )!
        
        // 下午交易时间段
        var afternoonTime = calendar.date(
            bySettingHour: afternoonOpenTime.hour,
            minute: afternoonOpenTime.minute,
            second: 0,
            of: date
        )!
        
        let afternoonEndTime = calendar.date(
            bySettingHour: marketCloseTime.hour,
            minute: marketCloseTime.minute,
            second: 0,
            of: date
        )!
        
        // 生成上午分钟数据
        while morningTime <= morningEndTime {
            tradingMinutes.append(morningTime)
            guard let nextMinute = calendar.date(
                byAdding: .minute,
                value: minuteInterval,
                to: morningTime
            ) else { break }
            morningTime = nextMinute
        }
        
        // 生成下午分钟数据
        while afternoonTime <= afternoonEndTime {
            tradingMinutes.append(afternoonTime)
            guard let nextMinute = calendar.date(
                byAdding: .minute,
                value: minuteInterval,
                to: afternoonTime
            ) else { break }
            afternoonTime = nextMinute
        }
        
        return tradingMinutes
    }
}

// MARK: - K线数据生成器
class KLineDataGenerator {
    
    // MARK: - 生成指定类型的K线数据
    static func generateKLineData(
        type: KLineType,
        periods: Int = 500, // 周期数量
        startPrice: Double = 100.0,
        volatility: Double = 2.0,
        baseVolume: Double = 1000000
    ) -> [CandleStickData] {
        
        switch type {
        case .realTtime:
            return []
        case .fiveDay:
            return []
        case .dayK:
            return generateDayKLine(periods: periods, startPrice: startPrice, volatility: volatility, baseVolume: baseVolume)
        case .weekK:
            return generateWeekKLine(periods: periods, startPrice: startPrice, volatility: volatility, baseVolume: baseVolume)
        case .monthK:
            return generateMonthKLine(periods: periods, startPrice: startPrice, volatility: volatility, baseVolume: baseVolume)
        case .minute_1_K, .minute_5_K, .minute_15_K, .minute_30_K, .minute_60_K:
            guard let interval = type.minuteInterval else { return [] }
            return generateMinuteKLine(
                minuteInterval: interval,
                periods: periods,
                startPrice: startPrice,
                volatility: volatility,
                baseVolume: baseVolume
            )
        }
    }
    
    // MARK: - 生成日K线
    private static func generateDayKLine(
        periods: Int,
        startPrice: Double,
        volatility: Double,
        baseVolume: Double
    ) -> [CandleStickData] {
        
        var kLineData: [CandleStickData] = []
        let calendar = Calendar.current
        let today = Date()
        
        // 获取起始日期（往后退periods个交易日）
        var tradingDays: [Date] = []
        var currentDate = today
        
        while tradingDays.count < periods {
            if let prevDay = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                currentDate = prevDay
                if AShareTradingCalendar.isTradingDay(currentDate) {
                    tradingDays.insert(currentDate, at: 0)
                }
            }
        }
        
        // 生成价格数据
        var previousClose = startPrice
        
        for date in tradingDays {
            let candle = generateSingleCandle(
                date: date,
                previousClose: previousClose,
                volatility: volatility,
                baseVolume: baseVolume
            )
            kLineData.append(candle)
            previousClose = candle.close
        }
        
        return kLineData
    }
    
    // MARK: - 生成周K线
    private static func generateWeekKLine(
        periods: Int,
        startPrice: Double,
        volatility: Double,
        baseVolume: Double
    ) -> [CandleStickData] {
        
        var kLineData: [CandleStickData] = []
        let calendar = Calendar.current
        let today = Date()
        
        // 获取最近的周结束日期（周五）
        var weekday = calendar.component(.weekday, from: today)
        var friday = today
        while weekday != 6 { // 6=周五
            guard let prevDay = calendar.date(byAdding: .day, value: -1, to: friday) else { break }
            friday = prevDay
            weekday = calendar.component(.weekday, from: friday)
        }
        
        // 生成周K线
        var previousClose = startPrice
        
        for i in 0..<periods {
            // 计算周开始和结束日期
            guard let weekEnd = calendar.date(byAdding: .weekOfYear, value: -i, to: friday),
                  let weekStart = calendar.date(byAdding: .day, value: -4, to: weekEnd) else { continue }
            
            // 生成一周的价格序列（基于日数据）
            var weeklyData: [CandleStickData] = []
            var currentDate = weekStart
            var weekPreviousClose = previousClose
            
            while currentDate <= weekEnd {
                if AShareTradingCalendar.isTradingDay(currentDate) {
                    let dailyCandle = generateSingleCandle(
                        date: currentDate,
                        previousClose: weekPreviousClose,
                        volatility: volatility,
                        baseVolume: baseVolume
                    )
                    weeklyData.append(dailyCandle)
                    weekPreviousClose = dailyCandle.close
                }
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDay
            }
            
            // 合并为周K线
            if let first = weeklyData.first, let last = weeklyData.last {
                let weekHigh = weeklyData.map { $0.high }.max() ?? first.high
                let weekLow = weeklyData.map { $0.low }.min() ?? first.low
                let weekVolume = weeklyData.reduce(0) { $0 + $1.volume }
                let weekAmount = weeklyData.compactMap { $0.amount }.reduce(0, +)
                
                let weekCandle = CandleStickData(
                    date: weekEnd,
                    open: first.open,
                    high: weekHigh,
                    low: weekLow,
                    close: last.close,
                    volume: weekVolume,
                    amount: weekAmount
                )
                kLineData.append(weekCandle)
                previousClose = last.close
            }
        }
        
        return kLineData.reversed() // 按时间正序排列
    }
    
    // MARK: - 生成月K线
    private static func generateMonthKLine(
        periods: Int,
        startPrice: Double,
        volatility: Double,
        baseVolume: Double
    ) -> [CandleStickData] {
        
        var kLineData: [CandleStickData] = []
        let calendar = Calendar.current
        let today = Date()
        
        // 获取最近的月末日期
        var components = calendar.dateComponents([.year, .month], from: today)
        components.day = 1
        guard let firstDayOfMonth = calendar.date(from: components),
              let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth) else {
            return []
        }
        
        var previousClose = startPrice
        
        for i in 0..<periods {
            // 计算月份
            guard let monthStart = calendar.date(byAdding: .month, value: -i, to: firstDayOfMonth),
                  let monthEnd = calendar.date(byAdding: .month, value: -i, to: lastDayOfMonth) else { continue }
            
            // 生成一月的价格序列
            var monthlyData: [CandleStickData] = []
            var currentDate = monthStart
            var monthPreviousClose = previousClose
            
            while currentDate <= monthEnd {
                if AShareTradingCalendar.isTradingDay(currentDate) {
                    let dailyCandle = generateSingleCandle(
                        date: currentDate,
                        previousClose: monthPreviousClose,
                        volatility: volatility,
                        baseVolume: baseVolume
                    )
                    monthlyData.append(dailyCandle)
                    monthPreviousClose = dailyCandle.close
                }
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDay
            }
            
            // 合并为月K线
            if let first = monthlyData.first, let last = monthlyData.last {
                let monthHigh = monthlyData.map { $0.high }.max() ?? first.high
                let monthLow = monthlyData.map { $0.low }.min() ?? first.low
                let monthVolume = monthlyData.reduce(0) { $0 + $1.volume }
                let monthAmount = monthlyData.compactMap { $0.amount }.reduce(0, +)
                
                let monthCandle = CandleStickData(
                    date: monthEnd,
                    open: first.open,
                    high: monthHigh,
                    low: monthLow,
                    close: last.close,
                    volume: monthVolume,
                    amount: monthAmount
                )
                kLineData.append(monthCandle)
                previousClose = last.close
            }
        }
        
        return kLineData.reversed() // 按时间正序排列
    }
    
    // MARK: - 生成分钟K线
    private static func generateMinuteKLine(
        minuteInterval: Int,
        periods: Int,
        startPrice: Double,
        volatility: Double,
        baseVolume: Double
    ) -> [CandleStickData] {
        
        var kLineData: [CandleStickData] = []
        let calendar = Calendar.current
        let today = Date()
        
        // 获取最近的交易日
        var tradingMinutes: [Date] = []
        var currentDate = today
        
        while tradingMinutes.count < periods {
            if AShareTradingCalendar.isTradingDay(currentDate) {
                let minutes = AShareTradingCalendar.generateTradingMinutes(
                    for: currentDate,
                    minuteInterval: minuteInterval
                )
                tradingMinutes = minutes + tradingMinutes
            }
            guard let prevDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = prevDay
        }
        
        // 只取最近的periods个数据点
        let neededMinutes = Array(tradingMinutes.suffix(periods))
        
        // 生成价格数据
        var previousClose = startPrice
        
        for minuteDate in neededMinutes {
            // 分钟级别的波动率要小一些
            let minuteVolatility = volatility * 0.3
            let candle = generateSingleCandle(
                date: minuteDate,
                previousClose: previousClose,
                volatility: minuteVolatility,
                baseVolume: baseVolume * 0.01 // 分钟数据成交量较小
            )
            kLineData.append(candle)
            previousClose = candle.close
        }
        
        return kLineData
    }
    
    // MARK: - 生成单个K线
    private static func generateSingleCandle(
        date: Date,
        previousClose: Double,
        volatility: Double,
        baseVolume: Double
    ) -> CandleStickData {
        
        // 价格变化百分比（基于波动率）
        let priceChangePercent = (Double.random(in: -volatility...volatility)) / 100
        let priceChange = previousClose * priceChangePercent
        
        // 生成OHLC价格
        let open = previousClose
        let close = open + priceChange
        
        // 生成日内最高最低价
        let intradayVolatility = volatility * 1.5 / 100
        let highVariation = Double.random(in: 0...intradayVolatility)
        let lowVariation = Double.random(in: 0...intradayVolatility)
        
        let potentialHigh = max(open, close) * (1 + highVariation)
        let potentialLow = min(open, close) * (1 - lowVariation)
        
        let high = max(open, close, potentialHigh)
        let low = min(open, close, potentialLow)
        
        // 生成成交量和成交额
        let volumeVariation = Double.random(in: 0.5...1.5)
        let volume = baseVolume * volumeVariation
        let averagePrice = (open + high + low + close) / 4
        let amount = volume * averagePrice
        
        return CandleStickData(
            date: date,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            amount: amount
        )
    }
    
    // MARK: - 基于tick数据生成更高周期K线（数据聚合）
    static func aggregateKLineData(
        from tickData: [CandleStickData],
        to targetType: KLineType
    ) -> [CandleStickData] {
        
        guard !tickData.isEmpty else { return [] }
        
        var aggregatedData: [CandleStickData] = []
        _ = Calendar.current
        
        switch targetType {
        case .minute_5_K, .minute_15_K, .minute_30_K, .minute_60_K:
            guard let interval = targetType.minuteInterval else { return [] }
            aggregatedData = aggregateToMinuteKLine(tickData, minuteInterval: interval)
            
        case .dayK:
            aggregatedData = aggregateToDayKLine(tickData)
            
        case .weekK:
            // 先聚合到日K，再聚合到周K
            let dailyData = aggregateToDayKLine(tickData)
            aggregatedData = aggregateToWeekKLine(dailyData)
            
        case .monthK:
            // 先聚合到日K，再聚合到月K
            let dailyData = aggregateToDayKLine(tickData)
            aggregatedData = aggregateToMonthKLine(dailyData)
            
        default:
            return tickData
        }
        
        return aggregatedData
    }
    
    // 聚合到指定分钟K线
    private static func aggregateToMinuteKLine(
        _ data: [CandleStickData],
        minuteInterval: Int
    ) -> [CandleStickData] {
        
        var aggregated: [CandleStickData] = []
        let calendar = Calendar.current
        
        var currentMinuteStart: Date?
        var currentGroup: [CandleStickData] = []
        
        for candle in data.sorted(by: { $0.date < $1.date }) {
            // 计算当前candle所属的分钟区间
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: candle.date)
            guard let minute = components.minute else { continue }
            let minuteGroup = minute / minuteInterval * minuteInterval
            
            var groupComponents = components
            groupComponents.minute = minuteGroup
            guard let groupStart = calendar.date(from: groupComponents) else { continue }
            
            if currentMinuteStart != groupStart {
                // 完成上一个分组
                if !currentGroup.isEmpty, let startDate = currentMinuteStart {
                    let aggregatedCandle = aggregateCandles(currentGroup, date: startDate)
                    aggregated.append(aggregatedCandle)
                }
                // 开始新分组
                currentMinuteStart = groupStart
                currentGroup = [candle]
            } else {
                currentGroup.append(candle)
            }
        }
        
        // 处理最后一组
        if !currentGroup.isEmpty, let startDate = currentMinuteStart {
            let aggregatedCandle = aggregateCandles(currentGroup, date: startDate)
            aggregated.append(aggregatedCandle)
        }
        
        return aggregated
    }
    
    // 聚合到日K线
    private static func aggregateToDayKLine(_ data: [CandleStickData]) -> [CandleStickData] {
        let calendar = Calendar.current
        var dailyGroups: [Date: [CandleStickData]] = [:]
        
        for candle in data {
            let dayStart = calendar.startOfDay(for: candle.date)
            if dailyGroups[dayStart] == nil {
                dailyGroups[dayStart] = []
            }
            dailyGroups[dayStart]?.append(candle)
        }
        
        var dailyData: [CandleStickData] = []
        for (date, candles) in dailyGroups.sorted(by: { $0.key < $1.key }) {
            let dailyCandle = aggregateCandles(candles, date: date)
            dailyData.append(dailyCandle)
        }
        
        return dailyData
    }
    
    // 聚合到周K线
    private static func aggregateToWeekKLine(_ dailyData: [CandleStickData]) -> [CandleStickData] {
        let calendar = Calendar.current
        var weeklyGroups: [Date: [CandleStickData]] = [:]
        
        for dailyCandle in dailyData {
            // 获取周开始日期（周一）
            let weekStart = calendar.date(from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: dailyCandle.date
            ))!
            
            if weeklyGroups[weekStart] == nil {
                weeklyGroups[weekStart] = []
            }
            weeklyGroups[weekStart]?.append(dailyCandle)
        }
        
        var weeklyData: [CandleStickData] = []
        for (weekStart, candles) in weeklyGroups.sorted(by: { $0.key < $1.key }) {
            // 使用本周最后一个交易日作为周K线的日期
            let lastDay = candles.max(by: { $0.date < $1.date })?.date ?? weekStart
            let weeklyCandle = aggregateCandles(candles, date: lastDay)
            weeklyData.append(weeklyCandle)
        }
        
        return weeklyData
    }
    
    // 聚合到月K线
    private static func aggregateToMonthKLine(_ dailyData: [CandleStickData]) -> [CandleStickData] {
        let calendar = Calendar.current
        var monthlyGroups: [Date: [CandleStickData]] = [:]
        
        for dailyCandle in dailyData {
            let components = calendar.dateComponents([.year, .month], from: dailyCandle.date)
            guard let monthStart = calendar.date(from: components) else { continue }
            
            if monthlyGroups[monthStart] == nil {
                monthlyGroups[monthStart] = []
            }
            monthlyGroups[monthStart]?.append(dailyCandle)
        }
        
        var monthlyData: [CandleStickData] = []
        for (monthStart, candles) in monthlyGroups.sorted(by: { $0.key < $1.key }) {
            // 使用本月最后一个交易日作为月K线的日期
            let lastDay = candles.max(by: { $0.date < $1.date })?.date ?? monthStart
            let monthlyCandle = aggregateCandles(candles, date: lastDay)
            monthlyData.append(monthlyCandle)
        }
        
        return monthlyData
    }
    
    // 聚合多个K线为一个
    private static func aggregateCandles(_ candles: [CandleStickData], date: Date) -> CandleStickData {
        guard !candles.isEmpty else {
            return CandleStickData(
                date: date,
                open: 0,
                high: 0,
                low: 0,
                close: 0,
                volume: 0,
                amount: 0
            )
        }
        
        let sortedCandles = candles.sorted(by: { $0.date < $1.date })
        
        let open = sortedCandles.first?.open ?? 0
        let close = sortedCandles.last?.close ?? 0
        let high = sortedCandles.map { $0.high }.max() ?? 0
        let low = sortedCandles.map { $0.low }.min() ?? 0
        let volume = sortedCandles.reduce(0) { $0 + $1.volume }
        let amount = sortedCandles.compactMap { $0.amount }.reduce(0, +)
        
        return CandleStickData(
            date: date,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            amount: amount
        )
    }
}

// MARK: - 使用示例
class KLineDataManager {
    
    // 生成并缓存K线数据
    private var cache: [KLineType: [CandleStickData]] = [:]
    
    func getKLineData(type: KLineType, periods: Int = 100) -> [CandleStickData] {
        if let cachedData = cache[type], cachedData.count >= periods {
            return Array(cachedData.suffix(periods))
        }
        
        let data = KLineDataGenerator.generateKLineData(
            type: type,
            periods: periods,
            startPrice: 100.0,
            volatility: type == .dayK ? 2.0 : 5.0 // 不同周期的波动率不同
        )
        
        cache[type] = data
        return data
    }
    
    // 切换K线周期
    func switchKLineType(_ type: KLineType) -> [CandleStickData] {
        let periods = getDefaultPeriods(for: type)
        return getKLineData(type: type, periods: periods)
    }
    
    private func getDefaultPeriods(for type: KLineType) -> Int {
        switch type {
        case .realTtime: return 0
        case .fiveDay: return 0
        case .minute_1_K, .minute_5_K: return 240 // 大约2天的数据
        case .minute_15_K, .minute_30_K: return 120 // 大约10天的数据
        case .minute_60_K: return 60 // 大约15天的数据
        case .dayK: return 100 // 100个交易日
        case .weekK: return 50 // 50周
        case .monthK: return 24 // 2年
        }
    }
    
    // 获取统计数据
    func getStatistics(for type: KLineType) -> String {
        let data = getKLineData(type: type)
        guard !data.isEmpty else { return "无数据" }
        
        let first = data.first!
        let last = data.last!
        let changes = last.close - first.open
        let changePercent = changes / first.open * 100
        
        return """
        \(type.description) 数据统计:
        时间范围: \(formatDate(first.date)) - \(formatDate(last.date))
        数据点数: \(data.count)
        起始价: \(String(format: "%.2f", first.open))
        当前价: \(String(format: "%.2f", last.close))
        涨跌: \(String(format: "%.2f", changes)) (\(String(format: "%.2f", changePercent))%)
        """
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 测试使用
extension KLineDataGenerator {
    static func testAllKLineTypes() {
        let manager = KLineDataManager()
        
        for type in KLineType.allCases {
            print("\n=== 测试 \(type.description) ===")
            
            let data = manager.getKLineData(type: type, periods: 20)
            print("生成数据点数: \(data.count)")
            
            if let first = data.first, let last = data.last {
                print("时间范围: \(formatDate(first.date)) - \(formatDate(last.date))")
                print("价格范围: \(String(format: "%.2f", first.open)) - \(String(format: "%.2f", last.close))")
            }
            
            print(manager.getStatistics(for: type))
        }
    }
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch date {
        case _ where Calendar.current.isDateInToday(date):
            formatter.dateFormat = "HH:mm"
        default:
            formatter.dateFormat = "MM-dd HH:mm"
        }
        return formatter.string(from: date)
    }
}
