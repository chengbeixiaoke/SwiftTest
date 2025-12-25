import UIKit
import WebKit
import GCDWebServer

class WebView3D: UIView {
    private var webView: WKWebView!
    private var webServer: GCDWebServer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupWebView()
        setupWebServer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        // 允许本地文件访问
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        webView = WKWebView(frame: bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(webView)
        loadLocalHTML()
    }
    
    private func setupWebServer() {
        webServer = GCDWebServer()
        
        // 1. 启用日志
        GCDWebServer.setLogLevel(3)
        GCDWebServer.setBuiltInLogger { level, message in
            printLog("[3D] \(message)")
        }
        
        // 2. 获取资源目录路径
        guard let resourcePath = Bundle.main.resourcePath else {
            print("❌ 无法获取资源路径")
            return
        }
        
        print("📁 资源目录: \(resourcePath)")
        
        // 3. 列出所有文件（调试用）
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
            print("📄 包内文件: \(files)")
        } catch {
            print("⚠️ 无法列出文件: \(error)")
        }
        
        // 4. 添加静态文件处理器
        webServer.addGETHandler(forBasePath: "/", directoryPath: resourcePath, indexFilename: nil, cacheAge: 0, allowRangeRequests: true)
        
        // 5. 启动服务器
        do {
            try webServer.start(options: [
                GCDWebServerOption_Port: 8080,
                GCDWebServerOption_BindToLocalhost: true,
                GCDWebServerOption_AutomaticallySuspendInBackground: false
            ])
            print("✅ 本地服务器启动: http://localhost:8080/")
        } catch {
            print("❌ 服务器启动失败: \(error)")
        }
    }
    
    private func loadLocalHTML() {
        let htmlString = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>3D Model</title>
            <script type="module" src="http://localhost:8080/model-viewer.min.js"></script>
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
                src="http://localhost:8080/gg.glb"
                alt="A 3D model"
                environment-image="http://localhost:8080/wd_1g.hdr"
                auto-rotate
                camera-controls
                disable-tap
                disable-pan
                disable-zoom
                interaction-prompt="none"
                max-camera-orbit="auto auto 300%"
            >
            </model-viewer>
        </body>

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
        </html>
        """
        
        // 2. 加载HTML
        webView.loadHTMLString(htmlString, baseURL: URL(string: "http://localhost:8080/"))
        
        // 3. 添加JavaScript控制台日志
        webView.configuration.userContentController.add(self, name: "logger")
    }
    
    deinit {
        webServer?.stop()
        print("🛑 服务器已停止")
    }
}

extension WebView3D: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logger" {
            printLog("[3D] JavaScript日志: \(message.body)")
        }
    }
}
