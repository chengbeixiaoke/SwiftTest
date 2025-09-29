//
//  MiniAppH5ContainerViewController.swift
//  CashSAVO
//
//  Created by yyw on 2025/4/29.
//

import UIKit
import WebKit
import SnapKit

class MiniAppH5ContainerViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    lazy var navigationView = {
        return MiniAppContainerNavigationView(frame: .zero)
    }()
    
    lazy var savoTransitionDelegate =  {
        return SavoSlideDownTransitionDelegate()
    }()
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.allowsBackForwardNavigationGestures = false
        webView.navigationDelegate = self
        return webView
    }()
    
    lazy var progressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor.gray
        progressView.trackTintColor = .clear
        return progressView
    }()
    
    var userContentController: WKUserContentController {
        get {
            return webView.configuration.userContentController
        }
    }
    
    let url: String
    
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHtml()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(UIScale(103))
        }
        navigationView.updateUI("")
        navigationView.clickActionBlock = { [weak self] type in
            guard let weakSelf = self else { return }
            switch type {
            case .back:
                weakSelf.clickBackAction()
            case .close:
                weakSelf.clickCloseAction()
            case .down:
                weakSelf.clickDownAction()
            case .kefu:
                weakSelf.clickKefuAction()
            case .more:
                weakSelf.clickMoreAction()
            }
        }
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: UIScale(103), left: 0, bottom: 0, right: 0))
        }
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(UIScale(2))
        }
        
        view.bringSubviewToFront(navigationView)
    }
    
    func loadHtml() {
        let eventProxySource = """
        var SavoWebviewProxyProto = function() {};
        SavoWebviewProxyProto.prototype.postEvent = function(eventName, eventData) {
            window.webkit.messageHandlers.performAction.postMessage({'eventName': eventName, 'eventData': eventData});
        };
        var SavoWebviewProxy = new SavoWebviewProxyProto();
        """
        
        let userScript = WKUserScript(source: eventProxySource,
                                      injectionTime: .atDocumentStart,
                                      forMainFrameOnly: false)
        userContentController.addUserScript(userScript)
        userContentController.add(MiniAppH5ContainerScriptMessageHandler(delegate: self),
                                  name: "performAction")
        
        guard let url = URL(string: url) else { return }
        webView.load(URLRequest(url: url,
                                timeoutInterval: 10.0))
        
        // 加载进度
        webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
    }
    
    func clickBackAction() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    func clickCloseAction() {
        dismiss(animated: true)
    }
    
    func clickDownAction() {
        MiniAppManager.shared.downMiniApp(self)
    }
    
    func clickMoreAction() {
        
    }
    
    func clickKefuAction() {
        
    }
    
    func reloadWebView() {
        // 清空所有类型的缓存
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let dateFrom = Date(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes,
                                                modifiedSince: dateFrom) { [weak self] in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async {
                weakSelf.webView.reload()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            webViewEstimatedProgress(webView)
        }
    }
    
    deinit {
        print("[MiniApp] MiniAppH5ContainerViewController - deinit")
        webView.removeObserver(self,
                               forKeyPath: #keyPath(WKWebView.estimatedProgress))
        userContentController.removeAllUserScripts()
        userContentController.removeScriptMessageHandler(forName: "performAction")
    }
}

extension MiniAppH5ContainerViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard message.name == "performAction" else { return }
        guard let body = message.body as? [String: Any] else { return }
        guard let jsapi = body["eventName"] as? String else { return }
        handleMessage(jsapiName: jsapi,
                      parameters: body["eventData"])
    }
    
    private func handleMessage(jsapiName: String,
                               parameters: Any?)
    {
        print("SAVO - [MiniApp] JSAPI Name:\(jsapiName), parameters:\(parameters ?? "")")
    }
}

extension MiniAppH5ContainerViewController: WKNavigationDelegate {
    func webViewEstimatedProgress(_ webView: WKWebView) {
        progressView.progress = Float(webView.estimatedProgress)
        if webView.estimatedProgress >= 1.0 {
            UIView.animate(withDuration: 0.3) {
                self.progressView.alpha = 0
            } completion: { _ in
                self.progressView.isHidden = true
            }
        } else {
            progressView.isHidden = false
            progressView.alpha = 1.0
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("[MiniApp] 加载失败，URL:\(url), error:\(error.localizedDescription)")
        OnMainThreadIfNeeded {
            self.webView.isHidden = true
            self.progressView.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("[MiniApp] 加载失败，URL:\(url), error:\(error.localizedDescription)")
        OnMainThreadIfNeeded {
            self.webView.isHidden = true
            self.progressView.isHidden = true
        }
    }
    
    // 实现代理方法
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { [weak self] (result, error) in
            guard let weakSelf = self else { return }
            if let title = result as? String {
                weakSelf.navigationView.titleLabel.text = title
            }
        }
        navigationView.canGoBack(webView.canGoBack)
    }
    
    // 允许 window.open() 打开新窗口
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

class MiniAppH5ContainerScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
    
    deinit {
        print("[MiniApp] MiniAppH5ContainerScriptMessageHandler - deinit")
    }
}
