//
//  CrashReporter.swift
//  SwiftTest
//

import Foundation
import KSCrash

/// KSCrash 的应用级封装：崩溃时本地持久化，下次冷启动上传历史报告。
final class CrashReporter {
    static let shared = CrashReporter()

    /// 临时测试接口；替换为正式的 HTTPS 报告接收地址即可。
    private let uploadURL = URL(string: "https://examples.com")!

    /// 报告保存在 Application Support，避免使用可被系统清理的缓存目录。
    let localReportDirectoryURL: URL

    private init(fileManager: FileManager = .default) {
        let applicationSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        localReportDirectoryURL = applicationSupportURL
            .appendingPathComponent("SwiftTest", isDirectory: true)
            .appendingPathComponent("KSCrash", isDirectory: true)
    }

    /// 在 AppDelegate 的 didFinishLaunching 中调用。
    /// KSCrash 负责在异常发生时将报告写入 `localReportDirectoryURL`，本方法只发送此前运行留下的报告。
    func start() {
        do {
            try FileManager.default.createDirectory(
                at: localReportDirectoryURL,
                withIntermediateDirectories: true
            )
        } catch {
            assertionFailure("无法创建 KSCrash 报告目录：\(error)")
            return
        }

        let installation = CrashInstallationStandard.shared
        installation.url = uploadURL

        let configuration = KSCrashConfiguration()
        configuration.installPath = localReportDirectoryURL.path
        // 上传成功才删除本地报告；网络或服务端失败时保留到下一次冷启动重试。
        configuration.reportStoreConfiguration.reportCleanupPolicy = .onSuccess

        do {
            try installation.install(with: configuration)
        } catch {
            assertionFailure("KSCrash 安装失败：\(error)")
            return
        }

        guard let reportStore = KSCrash.shared.reportStore, reportStore.reportCount > 0 else {
            return
        }

        installation.sendAllReports { _, error in
            if let error {
                print("KSCrash 报告上传失败，将在下次冷启动重试：\(error)")
            } else {
                print("KSCrash 历史报告上传完成。")
            }
        }
    }
}
