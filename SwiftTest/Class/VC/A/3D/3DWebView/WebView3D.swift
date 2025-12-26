import UIKit
import WebKit

class WebView3D: UIView, WKURLSchemeHandler {
    private var webView: WKWebView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(self, forURLScheme: "custom")
        webView = WKWebView(frame: bounds, configuration: config)
        addSubview(webView)
        loadLocalHTML()
    }
    
    private func loadLocalHTML() {
        guard let filePath = Bundle.main.path(forResource: "index", ofType: "html") else { return }
        
        let url = URL(fileURLWithPath: filePath)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else { return }
        let fileName = url.lastPathComponent
        
        let origin = urlSchemeTask.request.value(forHTTPHeaderField: "Origin") ?? "*"
        if fileName.contains("model-viewer.min.js"),
           let filePath = Bundle.main.path(forResource: "model-viewer.min", ofType: "js"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        {
            let headers = ["Content-Type": "application/javascript", "Access-Control-Allow-Origin": origin]
            let response = HTTPURLResponse(url: url,
                                           statusCode: 200,
                                           httpVersion: "HTTP/1.1",
                                           headerFields: headers)!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        }
        
        if fileName.contains("modelGLB.glb"),
           let filePath = Bundle.main.path(forResource: "modelGLB", ofType: "glb"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        {
            let headers = ["Content-Type": "model/gltf-binary", "Access-Control-Allow-Origin": origin]
            let response = HTTPURLResponse(url: url,
                                           statusCode: 200,
                                           httpVersion: "HTTP/1.1",
                                           headerFields: headers)!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        }
        
        if fileName.contains("modelHDR.hdr"),
           let filePath = Bundle.main.path(forResource: "modelHDR", ofType: "hdr"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        {
            let headers = ["Content-Type": "image/hdr", "Access-Control-Allow-Origin": origin]
            let response = HTTPURLResponse(url: url,
                                           statusCode: 200,
                                           httpVersion: "HTTP/1.1",
                                           headerFields: headers)!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        printLog("[3D] 请求停止: \(urlSchemeTask.request.url?.absoluteString ?? "")")
    }
}
