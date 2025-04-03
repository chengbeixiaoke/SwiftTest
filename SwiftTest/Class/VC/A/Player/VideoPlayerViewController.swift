//
//  VideoPlayerViewController.swift
//  CashSAVO
//
//  Created by yyw on 2024/12/19.
//

import UIKit
import ffmpegkit
import BMPlayer
import SwifterSwift

class VideoPlayerViewController: ViewController {
    var videoLocalPath: String = {
        return Bundle.main.path(forResource: "飞书20250120-095209", ofType: "mp4") ?? ""
    }()
    
    var outputPath: String = {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return "" }
        let outputPath = documentsDirectory.appendingPathComponent("Video.mov").path
        if FileManager.default.fileExists(atPath: outputPath) {
            try? FileManager.default.removeItem(atPath: outputPath)
        }
        return outputPath
    }()
    
    lazy var player = {
        let controlView = BMPlayerControlView()
        controlView.fullscreenButton.isHidden = true
        let player = BMPlayer(customControlView: controlView)
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        player.frame = self.view.bounds
        self.view.addSubview(player)
        
        player.backBlock = { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.dismiss(animated: true)
        }
        
        if FileManager.default.fileExists(atPath: outputPath) {
            let asset = BMPlayerResource(url: URL.FileURL(outputPath))
            player.setVideo(resource: asset)
            player.play()
        }
        else {
            convertFLVtoMP4(inputPath: videoLocalPath, outputPath: outputPath)
        }
    }
    
    /// 不支持.flv播放，所以这里把.flv转成.mp4
    func convertFLVtoMP4(inputPath: String, outputPath: String) {
        let command = "-i \(inputPath) -c:v copy -c:a copy \(outputPath)"
        FFmpegKit.executeAsync(command) { [weak self] session in
            guard let weakSelf = self else { return }
            
            if let session = session {
                let returnCode = session.getReturnCode().getValue()
                
                if returnCode == 0 {
                    /// 转换成功
                    ChatIMExecuteOnMainThreadAndWait {
                        let asset = BMPlayerResource(url: URL.FileURL(outputPath))
                        weakSelf.player.setVideo(resource: asset)
                        weakSelf.player.play()
                    }
                    print("CHATIM - [Video] 视频转换成功: \(inputPath), \(outputPath)")
                }
                else if returnCode == -2 {
                    print("CHATIM - [Video] 视频转换取消: \(inputPath), \(outputPath)")
                }
                else {
                    print("CHATIM - [Video] 视频转换失败: \(inputPath), \(outputPath)")
                }
            }
        }
    }
    
    deinit {
        print("Log [VideoPlayerViewController] deinit")
    }
}
