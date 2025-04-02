//
//  ViewController.swift
//  SwiftTest
//
//  Created by 王阳洋 on 2024/10/13.
//

import UIKit
import Combine
import Network
import SnapKit
import SwiftyJSON
import CoreStore
import Security
import CryptoKit
import Security
import CommonCrypto
import YYKit
import UIKit
import CombineCocoa
import AVFoundation
import AVKit

class ViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear:")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewController viewDidAppear:")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController viewWillDisappear:")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController viewDidDisappear:")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")

        view.backgroundColor = .white
        
        let button = UIButton()
        button.setTitle("按钮", for: .normal)
        button.backgroundColor = .red
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSizeMake(100, 50))
        }
        button.tapPublisher
            .sink { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.startTimer()
            }
            .store(in: &cancellables)
    }
    
    /// 开启通话计时
    func startTimer() {
        let links = [
            "https://www.jianshu.com/p/246231674d12?i=10&iok=sdjhhj 哈哈https://juejin.cn/post/6844903955424608263#heading-0",
            "ffdhttps://www.jianshu.com/p/246231674d12?i=10&iok=sdjhhj奥斯卡https://juejin.cn/post/6844903955424608263#heading-0",
            "2334https://www.jianshu.com/p/246231674d12?i=10&iok=sdjhhj卡斯https://juejin.cn/post/6844903955424608263#heading-0",
            "https://www.jianshu.com/p/246231674d12?i=10&iok=sdjhhj454拉流https://juejin.cn/post/6844903955424608263#heading-0",
            "ajksjkashttps://www.jianshu.com/p/246231674d12?i=10&iok=sdjhhjajksjkakshttps://juejin.cn/post/6844903955424608263#heading-0",
            "哈哈哈https://www.jianshu.com/p/246231674d12?i=10&iok=sdjhhj阿克苏看https://juejin.cn/post/6844903955424608263#heading-0",
            "jqwhttps://juejin.cn/post/6844903955424608263#heading-0",
            "https://www.jianshu.com/p/246231674d12?i=10&iok=sdjhhj 啊及时解决"
        ]
        
        links.forEach { text in
            print("====================")
            print(text)
            print(extractPureURLs(text: text))
            print("====================")
        }
    }
    
    func extractLinks(text: String) -> [String] {
        var links: [String] = []
        do {
            let detector = try NSDataDetector.init(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: text, options: [.reportProgress], range: NSRange(location: 0, length: text.count))
            for match in matches {
                if match.resultType == .link {
                    if let url = match.url {
                        links.append(url.absoluteString)
                    }
                }
            }
        } catch {
            print("CHATIM - [PreviewUrl] Error creating NSDataDetector: \(error)")
        }
        return links
    }
    
    func extractLinksWithRegex(text: String) -> [String] {
        let pattern = #"https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let urlString = String(text[range])
            return urlString
        }
    }
    
    func extractLinks2(text: String) -> [String] {
        let detector: NSDataDetector
        do {
            detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        } catch {
            return []
        }
        
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let urlString = String(text[range])
            return urlString
        }
    }
    func extractPureURLs(text: String) -> [String] {
//        let pattern = #"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)"#
        
        
        let pattern = #"(?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/\S*)?"#

        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return "" }
            let urlString = String(text[range])
            return urlString
        }
    }
}

class XXXViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("XXXViewController viewWillAppear:")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("XXXViewController viewDidAppear:")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("XXXViewController viewWillDisappear:")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("XXXViewController viewDidDisappear:")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("XXXViewController viewDidLoad")

        view.backgroundColor = .green
    }
    
    
}
