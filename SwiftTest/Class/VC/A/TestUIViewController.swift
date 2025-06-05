//
//  TestUIViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/4/11.
//

import UIKit
import WebKit
import SnapKit

class TestUIViewController: UIViewController {
    lazy var webview = {
        return WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(webview)
        webview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 加载 URL
        if let url = URL(string: "http://www.baidu.com") {
            let request = URLRequest(url: url)
            webview.load(request)
            
            if #available(iOS 16.4, *) {
                webview.isInspectable = true
            } else {
                // Fallback on earlier versions
            }
        }
    }
}




