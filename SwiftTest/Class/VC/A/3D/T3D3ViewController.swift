//
//  T3D3ViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/11/12.
//

import UIKit
import SceneKit
import QuartzCore

class T3D3ViewController: BaseViewController {
    
    // MARK: - UI Components
    private var sceneView: SCNView!
    private var controlPanel: UIView!
    private var resetButton: UIButton!
    private var toggleLightButton: UIButton!
    private var modelInfoLabel: UILabel!
    private var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - 3D Scene Properties
    private var scene: SCNScene!
    private var modelNode: SCNNode!
    private var cameraNode: SCNNode!
    private var lightNodes: [SCNNode] = []
    
    // MARK: - Gesture Properties
    private var lastPanLocation: CGPoint = .zero
    private var lastScale: CGFloat = 1.0
    private var isRotating: Bool = false
    
    // MARK: - Animation Properties
    private var rotationAnimation: CABasicAnimation?
    private var isLightEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScene()
        setupCamera()
        setupLighting()
        loadOBJModel()
        setupGestureRecognizers()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Setup Methods
extension T3D3ViewController {
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // 主场景视图
        sceneView = SCNView(frame: view.bounds)
        sceneView.backgroundColor = UIColor.black
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = false
        sceneView.antialiasingMode = .multisampling4X
        sceneView.delegate = self
        view.addSubview(sceneView)
        
        // 加载指示器
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        setupControlPanel()
    }
    
    private func setupControlPanel() {
        controlPanel = UIView()
        controlPanel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        controlPanel.layer.cornerRadius = 12
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlPanel)
        
        // 模型信息标签
        modelInfoLabel = UILabel()
        modelInfoLabel.text = "加载中..."
        modelInfoLabel.textColor = .white
        modelInfoLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        modelInfoLabel.textAlignment = .center
        modelInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(modelInfoLabel)
        
        // 重置按钮
        resetButton = UIButton(type: .system)
        resetButton.setTitle("重置视图", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = .systemBlue
        resetButton.layer.cornerRadius = 8
        resetButton.addTarget(self, action: #selector(resetView), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(resetButton)
        
        // 灯光切换按钮
        toggleLightButton = UIButton(type: .system)
        toggleLightButton.setTitle("关闭灯光", for: .normal)
        toggleLightButton.setTitleColor(.white, for: .normal)
        toggleLightButton.backgroundColor = .systemOrange
        toggleLightButton.layer.cornerRadius = 8
        toggleLightButton.addTarget(self, action: #selector(toggleLighting), for: .touchUpInside)
        toggleLightButton.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(toggleLightButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 控制面板约束
            controlPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            controlPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            controlPanel.heightAnchor.constraint(equalToConstant: 120),
            
            // 模型信息标签
            modelInfoLabel.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 12),
            modelInfoLabel.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            modelInfoLabel.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            
            // 按钮约束
            resetButton.topAnchor.constraint(equalTo: modelInfoLabel.bottomAnchor, constant: 12),
            resetButton.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 44),
            
            toggleLightButton.topAnchor.constraint(equalTo: modelInfoLabel.bottomAnchor, constant: 12),
            toggleLightButton.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            toggleLightButton.widthAnchor.constraint(equalToConstant: 120),
            toggleLightButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupScene() {
        scene = SCNScene()
        sceneView.scene = scene
        
        // 设置场景背景
        setupSceneBackground()
    }
    
    private func setupSceneBackground() {
        // 使用渐变背景
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0).cgColor,
            UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        let backgroundImage = gradientLayer.toImage()
        scene.background.contents = backgroundImage
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // 配置高级相机属性
        cameraNode.camera?.fieldOfView = 65
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 1000
        
        // 启用景深效果
        cameraNode.camera?.wantsDepthOfField = true
        cameraNode.camera?.focusDistance = 5
        cameraNode.camera?.fStop = 1.8
        
        // 设置相机位置
        cameraNode.position = SCNVector3(0, 0, 8)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting() {
        // 1. 环境光
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.3, alpha: 1.0)
        ambientLight.temperature = 6500
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        lightNodes.append(ambientNode)
        
        // 2. 主定向光
        let mainLight = SCNLight()
        mainLight.type = .directional
        mainLight.color = UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0)
        mainLight.temperature = 5500
        mainLight.castsShadow = true
        mainLight.shadowRadius = 8
        mainLight.shadowColor = UIColor.black.withAlphaComponent(0.4)
        mainLight.shadowSampleCount = 16
        mainLight.shadowMode = .forward
        let mainLightNode = SCNNode()
        mainLightNode.light = mainLight
        mainLightNode.position = SCNVector3(5, 8, 5)
        mainLightNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(mainLightNode)
        lightNodes.append(mainLightNode)
        
        // 3. 填充光
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.color = UIColor(red: 0.4, green: 0.5, blue: 1.0, alpha: 1.0)
        fillLight.intensity = 600
        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(-4, 3, 3)
        scene.rootNode.addChildNode(fillLightNode)
        lightNodes.append(fillLightNode)
        
        // 4. 背光
        let backLight = SCNLight()
        backLight.type = .spot
        backLight.color = UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0)
        backLight.intensity = 400
        backLight.spotInnerAngle = 30
        backLight.spotOuterAngle = 80
        let backLightNode = SCNNode()
        backLightNode.light = backLight
        backLightNode.position = SCNVector3(0, 5, -5)
        backLightNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(backLightNode)
        lightNodes.append(backLightNode)
    }
}

// MARK: - OBJ Model Loading
extension T3D3ViewController {
    
    private func loadOBJModel() {
        loadingIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 方法1: 从应用包加载OBJ文件
            if let modelURL = Bundle.main.url(forResource: "tinker_1", withExtension: "obj") {
                self.loadModelFromURL(modelURL)
            }
            // 方法2: 从Documents目录加载
            else if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let modelURL = documentsURL.appendingPathComponent("tinker_1.obj")
                if FileManager.default.fileExists(atPath: modelURL.path) {
                    self.loadModelFromURL(modelURL)
                } else {
                    // 方法3: 创建备用演示模型
                    DispatchQueue.main.async {
                        self.createFallbackModel()
                    }
                }
            }
        }
    }
    
    private func loadModelFromURL(_ modelURL: URL) {
        do {
            // 创建场景源
            let sceneSource = SCNSceneSource(url: modelURL, options: nil)
            
            // 加载场景
            if let loadedScene = sceneSource?.scene(options: nil) {
                DispatchQueue.main.async {
                    self.setupLoadedScene(loadedScene)
                }
            } else {
                // 如果SCNSceneSource失败，尝试直接加载
                let loadedScene = try SCNScene(url: modelURL, options: nil)
                DispatchQueue.main.async {
                    self.setupLoadedScene(loadedScene)
                }
            }
        } catch {
            print("加载OBJ模型失败: \(error)")
            DispatchQueue.main.async {
                self.createFallbackModel()
            }
        }
    }
    
    private func setupLoadedScene(_ loadedScene: SCNScene) {
        // 移除现有模型
        modelNode?.removeFromParentNode()
        
        // 使用加载的场景根节点
        modelNode = loadedScene.rootNode
        
        // 调整模型大小和位置
        adjustModelSizeAndPosition()
        
        // 添加到场景
        scene.rootNode.addChildNode(modelNode)
        
        // 更新UI
        updateModelInfo()
        loadingIndicator.stopAnimating()
        
        // 应用材质增强
        enhanceMaterials()
        
        // 添加进入动画
        addEntranceAnimation()
    }
    
    private func adjustModelSizeAndPosition() {
        guard let modelNode = modelNode else { return }
        
        // 计算模型的边界框
        let boundingBox = modelNode.boundingBox
        let minBounds = boundingBox.min
        let maxBounds = boundingBox.max
        
        // 检查边界框是否有效[citation:10]
        guard maxBounds.x > minBounds.x && maxBounds.y > minBounds.y && maxBounds.z > minBounds.z else {
            print("边界框数据无效，可能需要等待加载完成")
            return
        }
        
        let size = SCNVector3(
            maxBounds.x - minBounds.x,
            maxBounds.y - minBounds.y,
            maxBounds.z - minBounds.z
        )
        
        // 计算缩放比例使模型适合视图
        let maxDimension = max(size.x, max(size.y, size.z))
        let targetScale: Float = 5.0 / maxDimension // 调整这个值来改变默认大小
        
        // 使用SCNTransaction应用缩放和位置调整
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        modelNode.scale = SCNVector3(targetScale, targetScale, targetScale)
        
        // 居中模型
        let center = SCNVector3(
            (minBounds.x + maxBounds.x) * 0.5 * targetScale,
            (minBounds.y + maxBounds.y) * 0.5 * targetScale,
            (minBounds.z + maxBounds.z) * 0.5 * targetScale
        )
        modelNode.position = SCNVector3(-center.x, -center.y, -center.z)
        
        SCNTransaction.commit()
    }
    
    private func createFallbackModel() {
        loadingIndicator.stopAnimating()
        
        // 创建备用模型
        modelNode = SCNNode()
        
        // 创建复杂几何体作为演示
        let geometry = SCNTorus(ringRadius: 1.0, pipeRadius: 0.3)
        geometry.firstMaterial?.diffuse.contents = UIColor.systemBlue
        geometry.firstMaterial?.specular.contents = UIColor.white
        geometry.firstMaterial?.shininess = 1.0
        geometry.firstMaterial?.metalness.contents = 0.8
        geometry.firstMaterial?.roughness.contents = 0.2
        
        let torusNode = SCNNode(geometry: geometry)
        modelNode.addChildNode(torusNode)
        
        // 添加一些球体
        for i in 0..<6 {
            let sphere = SCNSphere(radius: 0.2)
            sphere.firstMaterial?.diffuse.contents = UIColor.systemRed
            sphere.firstMaterial?.specular.contents = UIColor.white
            
            let sphereNode = SCNNode(geometry: sphere)
            let angle = Float(i) * .pi / 3
            sphereNode.position = SCNVector3(
                cos(angle) * 1.8,
                sin(angle) * 1.8,
                0
            )
            modelNode.addChildNode(sphereNode)
        }
        
        scene.rootNode.addChildNode(modelNode)
        updateModelInfo()
        
        modelInfoLabel.text = "演示模型 (请添加model.obj文件)"
    }
    
    private func enhanceMaterials() {
        // 遍历所有子节点并增强材质
        modelNode?.enumerateChildNodes { node, _ in
            if let geometry = node.geometry, let material = geometry.firstMaterial {
                // 增强材质属性
                material.lightingModel = .physicallyBased
                
                if material.diffuse.contents == nil {
                    material.diffuse.contents = UIColor.systemGray
                }
                
                // 添加一些反射
                material.fresnelExponent = 2.0
                material.reflective.contents = UIColor.black
                
                // 设置金属度和粗糙度
                material.metalness.contents = 0.3
                material.roughness.contents = 0.7
            }
        }
    }
    
    private func updateModelInfo() {
        guard let modelNode = modelNode else { return }
        
        var childCount = 0
        modelNode.enumerateChildNodes { _, _ in
            childCount += 1
        }
        
        modelInfoLabel.text = "子节点: \(childCount) | 已加载"
    }
}

// MARK: - Gesture Recognizers
extension T3D3ViewController {
    
    private func setupGestureRecognizers() {
        // 平移手势 - 旋转模型
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
        
        // 捏合手势 - 缩放模型
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        
        // 双击手势 - 重置视图
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(resetView))
        doubleTapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapGesture)
        
        // 旋转手势 - 绕Z轴旋转
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        sceneView.addGestureRecognizer(rotationGesture)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: sceneView)
        
        switch gestureRecognizer.state {
        case .began:
            isRotating = true
            stopAnimations()
            
        case .changed:
            let rotationY = Float(translation.x) * .pi / 180.0 * 0.5
            let rotationX = Float(translation.y) * .pi / 180.0 * 0.5
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .default)
            
            modelNode.eulerAngles.x -= rotationX
            modelNode.eulerAngles.y -= rotationY
            
            SCNTransaction.commit()
            
            gestureRecognizer.setTranslation(.zero, in: sceneView)
            
        case .ended, .cancelled:
            isRotating = false
            // 可以在这里添加惯性效果
            
        default:
            break
        }
    }
    
    @objc private func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            stopAnimations()
            
        case .changed:
            let scaleFactor = Float(gestureRecognizer.scale)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            
            // 限制缩放范围
            let currentScale = modelNode.scale.x
            let newScale = currentScale * scaleFactor
            let clampedScale = max(0.1, min(newScale, 5.0))
            
            modelNode.scale = SCNVector3(clampedScale, clampedScale, clampedScale)
            
            SCNTransaction.commit()
            
            gestureRecognizer.scale = 1.0
            
        default:
            break
        }
    }
    
    @objc private func handleRotation(_ gestureRecognizer: UIRotationGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed:
            let rotation = Float(gestureRecognizer.rotation)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            
            modelNode.eulerAngles.z -= rotation
            
            SCNTransaction.commit()
            
            gestureRecognizer.rotation = 0
            
        default:
            break
        }
    }
    
    private func stopAnimations() {
        modelNode?.removeAllActions()
        modelNode?.removeAllAnimations()
    }
}

// MARK: - Animation Methods
extension T3D3ViewController {
    
    private func addEntranceAnimation() {
        guard let modelNode = modelNode else { return }
        
        // 保存原始位置
        let originalPosition = modelNode.position
        let originalScale = modelNode.scale
        
        // 设置初始状态（缩小并下移）
        modelNode.position = SCNVector3(originalPosition.x, originalPosition.y - 2, originalPosition.z)
        modelNode.scale = SCNVector3(0.1, 0.1, 0.1)
        modelNode.opacity = 0.0
        
        // 使用SCNTransaction创建进入动画
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        modelNode.position = originalPosition
        modelNode.scale = originalScale
        modelNode.opacity = 1.0
        
        SCNTransaction.completionBlock = {
            // 动画完成后可以添加其他效果
            self.addBreathingAnimation()
        }
        
        SCNTransaction.commit()
    }
    
    private func addBreathingAnimation() {
        guard let modelNode = modelNode else { return }
        
        let breatheAction = SCNAction.sequence([
            SCNAction.scale(by: 1.05, duration: 1.5),
            SCNAction.scale(by: 0.95, duration: 1.5)
        ])
        
        modelNode.runAction(SCNAction.repeatForever(breatheAction), forKey: "breathing")
    }
}

// MARK: - Control Methods
extension T3D3ViewController {
    
    @objc private func resetView() {
        stopAnimations()
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.8
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        // 重置模型变换
        modelNode.eulerAngles = SCNVector3(0, 0, 0)
        
        // 重置相机
        cameraNode.position = SCNVector3(0, 0, 8)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        
        SCNTransaction.completionBlock = {
            self.addBreathingAnimation()
        }
        
        SCNTransaction.commit()
    }
    
    @objc private func toggleLighting() {
        isLightEnabled.toggle()
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        for lightNode in lightNodes {
            lightNode.light?.intensity = isLightEnabled ? 1000 : 0
        }
        
        SCNTransaction.commit()
        
        toggleLightButton.setTitle(isLightEnabled ? "关闭灯光" : "开启灯光", for: .normal)
        toggleLightButton.backgroundColor = isLightEnabled ? .systemOrange : .systemGreen
    }
}

// MARK: - SCNSceneRendererDelegate
extension T3D3ViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 可以在这里添加每帧更新的逻辑
    }
}

// MARK: - CALayer Extension for Background
extension CALayer {
    func toImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            render(in: ctx.cgContext)
        }
    }
}
