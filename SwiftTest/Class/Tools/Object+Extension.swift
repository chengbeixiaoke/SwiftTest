//
//  Object+Extension.swift
//  SwiftTest
//
//  Created by yyw on 2025/4/3.
//

import UIKit

extension URL {
    var filePath: String {
        get {
            if #available(iOS 16.0, *) {
                return path()
            } else {
                return path
            }
        }
    }
    
    static func FileURL(_ filePath: String) -> URL {
        if #available(iOS 16.0, *) {
            return URL.init(filePath: filePath)
        } else {
            return URL.init(fileURLWithPath: filePath)
        }
    }
    
    static func outputURL(_ name: String,
                          clearOld: Bool = false,
                          createEmptyFile: Bool = false) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let outputFolder = documentsDirectory.appendingPathComponent("Output")
        let outputURL = outputFolder.appendingPathComponent(name)
        
        do {
            if !FileManager.default.fileExists(atPath: outputFolder.filePath) {
                try FileManager.default.createDirectory(at: outputFolder,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }

            if clearOld && FileManager.default.fileExists(atPath: outputURL.filePath) {
                try FileManager.default.removeItem(atPath: outputURL.filePath)
            }
            
            if createEmptyFile {
                /// 预先创建空文件，以便后续文件写入
                try "".write(to: outputURL, atomically: true, encoding: .utf8)
            }
        }
        catch {
            print("[Error] 创建outputURL失败：\(error.localizedDescription)")
        }
        return outputURL
    }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined()
    }
}
