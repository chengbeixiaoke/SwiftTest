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
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(webView)
        loadLocalHTML()
    }
    
    private func loadLocalHTML() {
        let htmlString = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>3D Model</title>
            <script type="module" src="custom://local/model-viewer.min.js"></script>
            <style>
                body { margin: 0; padding: 0; overflow: hidden; background-color: transparent; }
                model-viewer { width: 100vw; height: 100vh; }
                model-viewer::part(default-progress-bar) {
                    display: none;
                }
            </style>
        </head>
        <body>
            <model-viewer
                id="robot-model"
                src="custom://local/gg.glb"
                alt="A 3D model"
                environment-image="custom://local/wd_1g.hdr"
                auto-rotate
                camera-controls
                disable-tap
                disable-pan
                disable-zoom
                interaction-prompt="none"
                max-camera-orbit="auto auto 300%"
            >
            </model-viewer>
            <script>
                const modelViewer = document.querySelector('#robot-model');
                function initFromUrlParams() {
                    const params = new URLSearchParams(window.location.search);
                    const orbit = params.get('orbit');
                    if (orbit) {
                        // 暂时关闭自动旋转，否则会覆盖初始角度
                        modelViewer.setAttribute('camera-orbit', orbit)
                    }
                }
        
                initFromUrlParams()
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlString, baseURL: nil)
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
        
        if fileName.contains("gg.glb"),
           let filePath = Bundle.main.path(forResource: "gg", ofType: "glb"),
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
        
        if fileName.contains("wd_1g.hdr"),
           let filePath = Bundle.main.path(forResource: "wd_1g", ofType: "hdr"),
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
