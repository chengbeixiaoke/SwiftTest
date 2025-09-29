//
//  PublicFunction.swift
//  BoXinCustomer
//
//  Created by yyw on 2025/8/19.
//

import UIKit
import YYKit
import SwifterSwift
import SwiftyJSON
import AudioToolbox

// MARK: - 确保在在主线程执行
public func OnMainThreadIfNeeded(task: @escaping () -> Void)
{
    if Thread.isMainThread {
        task()
    } else {
        DispatchQueue.main.async {
            task()
        }
    }
}

// MARK: - 延时执行
func delay(seconds: Double,
           queue: DispatchQueue = DispatchQueue.main,
           completion:@escaping () -> Void)
{
    let time = Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
    queue.asyncAfter(deadline: DispatchTime.now() + time) {
        completion()
    }
}

// MARK: - 打印文件名、函数名、行号及自定义信息
public func printLog(_ messages: Any...,
                     file: String = #file,
                     line: Int = #line)
{
    var messageString: String = ""
    for message in messages {
        messageString.append("\(message)")
    }
    let log = "\((file as NSString).lastPathComponent)[\(line)] : \(messageString)"
#if DEBUG
    print(log)
#endif
}

// MARK: - 计算文本最大高度
public func labelSize(attributedText: NSAttributedString,
                      maxWidth: CGFloat? = nil,
                      removeBlankSpace: Bool = false) -> CGSize
{
    var att = attributedText
    /// 先去一下空格
    if removeBlankSpace && att.string.count > 0 {
        let attributes = attributedText.attributes(at: 0,
                                                   effectiveRange: nil)
        var string = attributedText.string
        string = string.replacingOccurrences(of: "\n",
                                             with: "")
        att = NSAttributedString(string: string,
                                 attributes: attributes)
    }
    
    let size = CGSize(width: maxWidth == nil ? CGFloat.greatestFiniteMagnitude : maxWidth!,
                      height: CGFloat.greatestFiniteMagnitude)
    let rect = att.boundingRect(with: size,
                                options: [.usesLineFragmentOrigin, .usesFontLeading],
                                context: nil).integral
    return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height))
}

// MARK: - 计算文本最后一行宽度
public func lastLineWidth(attributedText: NSAttributedString,
                          maxWidth: CGFloat,
                          textPadding: UIEdgeInsets) -> CGFloat
{
    let layoutManager = NSLayoutManager()
    let size = CGSize(width: maxWidth - textPadding.horizontal,
                      height: CGFloat.greatestFiniteMagnitude)
    let textContainer = NSTextContainer(size: size)
    textContainer.lineFragmentPadding = 0
    layoutManager.addTextContainer(textContainer)
    
    let storage = NSTextStorage(attributedString: attributedText)
    storage.addLayoutManager(layoutManager)
    
    // 通过遍历所有的行来找到最后一行
    let range = NSRange(location: 0, length: attributedText.length)
    var lastLineWidth: CGFloat = 0
    layoutManager.enumerateLineFragments(forGlyphRange: range) { (_, lineRect, _, _, _) in
        lastLineWidth = lineRect.width
    }
    return ceil(lastLineWidth)
}

// MARK: - 计算文本所有行最大宽度
public func maxLineWidth(attributedText: NSAttributedString,
                         maxWidth: CGFloat,
                         textPadding: UIEdgeInsets) -> CGFloat
{
    let layoutManager = NSLayoutManager()
    let size = CGSize(width: maxWidth - textPadding.horizontal,
                      height: CGFloat.greatestFiniteMagnitude)
    let textContainer = NSTextContainer(size: size)
    layoutManager.addTextContainer(textContainer)
    
    let storage = NSTextStorage(attributedString: attributedText)
    storage.addLayoutManager(layoutManager)
    
    // 通过遍历所有的行来找到最后一行
    let range = NSRange(location: 0, length: attributedText.length)
    var maxLineWidth: CGFloat = 0
    layoutManager.enumerateLineFragments(forGlyphRange: range) { (_, lineRect, _, _, _) in
        if lineRect.width > maxLineWidth {
            maxLineWidth = lineRect.width
        }
    }
    return ceil(maxLineWidth)
}

// MARK: - 计算文本最大高度
public func yy_labelSize(attributedText: NSAttributedString,
                         maxWidth: CGFloat? = nil,
                         removeBlankSpace: Bool = false) -> CGSize
{
    var att = attributedText
    /// 先去一下空格
    if removeBlankSpace && att.string.count > 0 {
        let attributes = attributedText.attributes(at: 0,
                                                   effectiveRange: nil)
        var string = attributedText.string
        string = string.replacingOccurrences(of: "\n",
                                             with: "")
        att = NSAttributedString(string: string,
                                 attributes: attributes)
    }
    
    let width = maxWidth == nil ? CGFloat.greatestFiniteMagnitude : maxWidth!
    let size = CGSize(width: width,
                      height: CGFloat.greatestFiniteMagnitude)
    
    let container = YYTextContainer(size: size)
    
    // 2. 清除默认边距
    container.insets = .zero
    container.maximumNumberOfRows = 0
    container.truncationType = .none
    
    // 4. 创建布局
    guard let layout = YYTextLayout(container: container, text: att) else {
        return .zero
    }
    
    // 5. 像素对齐处理
    return CGSize(width: ceil(layout.textBoundingRect.width),
                  height: ceil(layout.textBoundingRect.height))
    
}

// MARK: - 计算文本最后一行宽度
public func yy_lastLineWidth(attributedText: NSAttributedString,
                             maxWidth: CGFloat,
                             textPadding: UIEdgeInsets) -> CGFloat
{
    let size = CGSize(width: maxWidth - textPadding.horizontal,
                      height: CGFloat.greatestFiniteMagnitude)
    guard let layout = YYTextLayout(containerSize: size, text: attributedText) else {
        return 0
    }
    guard let lastLine = layout.lines.last else {
        return 0
    }
    return ceil(lastLine.width)
}

// MARK: - 计算文本所有行最大宽度
public func yy_maxLineWidth(attributedText: NSAttributedString,
                            maxWidth: CGFloat,
                            textPadding: UIEdgeInsets) -> CGFloat
{
    let size = CGSize(width: maxWidth - textPadding.horizontal,
                      height: CGFloat.greatestFiniteMagnitude)
    guard let layout = YYTextLayout(containerSize: size, text: attributedText) else {
        return 0
    }
    var maxLineWidth: CGFloat = 0
    for textLine in layout.lines {
        if maxLineWidth < textLine.width {
            maxLineWidth = textLine.width
        }
    }
    return ceil(maxLineWidth)
}

// MARK: - 字典转Data
public func dictionaryToData(_ dic: [String: Any]) -> Data?
{
    do {
        let data = try JSONSerialization.data(withJSONObject: dic, options: [])
        return data
    }
    catch {
        printLog("[App] 字典转Data: \(error.localizedDescription)")
        return nil
    }
}

// MARK: - 字典转String
public func dictionaryToString(_ dic: [String: Any]) -> String?
{
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    }
    catch {
        printLog("[App] 字典转String: \(error.localizedDescription)")
        return nil
    }
}

// MARK: - Data转JSON
public func dataToJSON(_ data: Data) -> JSON?
{
    do {
        let result1 = try JSON(data: data)
        return result1
    }
    catch {
        printLog("[App] Data转JSON失败: \(error.localizedDescription)")
        return nil
    }
}

// MARK: - Data转字典
public func dataToDictionary(_ data: Data) -> [String: Any]?
{
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        let dictionary = jsonObject as? [String: Any]
        return dictionary
    }
    catch {
        printLog("[App] Data转字典失败: \(error.localizedDescription)")
        return nil
    }
}

// MARK: 字符串转字典
public func stringToDictionary(_ jsonString: String) -> [String: Any]?
{
    guard let data = jsonString.data(using: .utf8) else { return nil }
    
    do {
        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return dictionary
    }
    catch {
        printLog("[App] 字符串转字典: \(error.localizedDescription)")
        return nil
    }
}

// MARK: - 获取当前屏幕截图
public func captureScreenshot() -> UIImage?
{
    let screenSize = UIScreen.main.bounds
    let renderer = UIGraphicsImageRenderer(size: screenSize.size)
    let screenshot = renderer.image { context in
        UIWindow.keyWindow()?.drawHierarchy(in: screenSize, afterScreenUpdates: true)
    }
    return screenshot
}

// MARK: - 打开设置页面
func openSystemSeeting() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
    }
}

// MARK: - 系统音效
func playSystemAudioShock() {
    DispatchQueue.main.async {
        AudioServicesPlaySystemSound(1519)
    }
}
