//
//  T3D2ViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/11/12.
//

import UIKit
import SceneKit
import QuartzCore

class T3D2ViewController: BaseViewController {
    
    // MARK: - UI Components
    private var sceneView: SCNView!
    private var controlPanel: UIView!
    private var resetButton: UIButton!
    private var animateButton: UIButton!
    private var modelPicker: UISegmentedControl!
    
    // MARK: - 3D Scene Properties
    private var scene: SCNScene!
    private var modelNode: SCNNode!
    private var cameraNode: SCNNode!
    private var lightGroupNode: SCNNode!
    
    // MARK: - Animation Properties
    private var isAnimating: Bool = false
    private var currentModel: String = "robot"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScene()
        setupCamera()
        setupLighting()
        loadModel(named: currentModel)
        setupGestureRecognizers()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Setup Methods
extension T3D2ViewController {
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // 主场景视图
        sceneView = SCNView(frame: view.bounds)
        sceneView.backgroundColor = UIColor.black
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = false
        sceneView.antialiasingMode = .multisampling4X
        view.addSubview(sceneView)
        
        // 控制面板
        setupControlPanel()
    }
    
    private func setupControlPanel() {
        controlPanel = UIView()
        controlPanel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        controlPanel.layer.cornerRadius = 12
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlPanel)
        
        // 模型选择器
        modelPicker = UISegmentedControl(items: ["机器人", "飞船", "汽车", "角色"])
        modelPicker.selectedSegmentIndex = 0
        modelPicker.backgroundColor = .darkGray
        modelPicker.selectedSegmentTintColor = .systemBlue
        modelPicker.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        modelPicker.addTarget(self, action: #selector(modelChanged), for: .valueChanged)
        modelPicker.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(modelPicker)
        
        // 重置按钮
        resetButton = UIButton(type: .system)
        resetButton.setTitle("重置视图", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = .systemBlue
        resetButton.layer.cornerRadius = 8
        resetButton.addTarget(self, action: #selector(resetView), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(resetButton)
        
        // 动画按钮
        animateButton = UIButton(type: .system)
        animateButton.setTitle("开始动画", for: .normal)
        animateButton.setTitleColor(.white, for: .normal)
        animateButton.backgroundColor = .systemGreen
        animateButton.layer.cornerRadius = 8
        animateButton.addTarget(self, action: #selector(toggleAnimation), for: .touchUpInside)
        animateButton.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(animateButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 控制面板约束
            controlPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            controlPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            controlPanel.heightAnchor.constraint(equalToConstant: 150),
            
            // 模型选择器约束
            modelPicker.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 16),
            modelPicker.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            modelPicker.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            modelPicker.heightAnchor.constraint(equalToConstant: 40),
            
            // 按钮约束
            resetButton.topAnchor.constraint(equalTo: modelPicker.bottomAnchor, constant: 12),
            resetButton.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 44),
            
            animateButton.topAnchor.constraint(equalTo: modelPicker.bottomAnchor, constant: 12),
            animateButton.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            animateButton.widthAnchor.constraint(equalToConstant: 120),
            animateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupScene() {
        scene = SCNScene()
        sceneView.scene = scene
        
        // 设置场景背景
        scene.background.contents = [
            "art.scnassets/background/right.jpg",
            "art.scnassets/background/left.jpg",
            "art.scnassets/background/top.jpg",
            "art.scnassets/background/bottom.jpg",
            "art.scnassets/background/back.jpg",
            "art.scnassets/background/front.jpg"
        ]
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // 配置高级相机属性
        cameraNode.camera?.fieldOfView = 75
        cameraNode.camera?.focalLength = 35
        cameraNode.camera?.sensorHeight = 24
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 1000
        
        // 启用景深效果（可选）
        cameraNode.camera?.wantsDepthOfField = true
        cameraNode.camera?.focusDistance = 10
        cameraNode.camera?.fStop = 2.8
        
        cameraNode.position = SCNVector3(0, 1, 8)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting() {
        lightGroupNode = SCNNode()
        
        // 1. 环境光
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.3, alpha: 1.0)
        ambientLight.temperature = 6500
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        lightGroupNode.addChildNode(ambientNode)
        
        // 2. 主定向光
        let mainLight = SCNLight()
        mainLight.type = .directional
        mainLight.color = UIColor(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0)
        mainLight.temperature = 5500
        mainLight.castsShadow = true
        mainLight.shadowRadius = 5
        mainLight.shadowColor = UIColor.black.withAlphaComponent(0.4)
        mainLight.shadowSampleCount = 16
        let mainLightNode = SCNNode()
        mainLightNode.light = mainLight
        mainLightNode.position = SCNVector3(5, 8, 5)
        mainLightNode.look(at: SCNVector3(0, 0, 0))
        lightGroupNode.addChildNode(mainLightNode)
        
        // 3. 填充光
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.color = UIColor(red: 0.4, green: 0.5, blue: 1.0, alpha: 1.0)
        fillLight.intensity = 800
        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(-3, 2, -2)
        lightGroupNode.addChildNode(fillLightNode)
        
        // 4. 背光
        let backLight = SCNLight()
        backLight.type = .spot
        backLight.color = UIColor(red: 1.0, green: 0.7, blue: 0.4, alpha: 1.0)
        backLight.intensity = 600
        backLight.spotInnerAngle = 30
        backLight.spotOuterAngle = 60
        let backLightNode = SCNNode()
        backLightNode.light = backLight
        backLightNode.position = SCNVector3(0, 3, -5)
        backLightNode.look(at: SCNVector3(0, 0, 0))
        lightGroupNode.addChildNode(backLightNode)
        
        scene.rootNode.addChildNode(lightGroupNode)
    }
}

// MARK: - Model Loading
extension T3D2ViewController {
    
    private func loadModel(named modelName: String) {
        // 移除现有模型
        modelNode?.removeFromParentNode()
        
        let modelPath: String
        let scale: Float
        let position: SCNVector3
        
        switch modelName {
        case "robot":
            modelPath = "art.scnassets/robot/robot.scn"
            scale = 0.8
            position = SCNVector3(0, -1, 0)
        case "spaceship":
            modelPath = "art.scnassets/spaceship/spaceship.scn"
            scale = 0.3
            position = SCNVector3(0, 0, 0)
        case "car":
            modelPath = "art.scnassets/car/car.scn"
            scale = 0.8
            position = SCNVector3(0, -0.5, 0)
        case "character":
            modelPath = "art.scnassets/character/character.scn"
            scale = 0.015
            position = SCNVector3(0, -1.5, 0)
        default:
            return
        }
        
        // 加载模型
        if let modelScene = SCNScene(named: modelPath) {
            modelNode = SCNNode()
            
            // 遍历场景中的所有节点
            modelScene.rootNode.childNodes.forEach { childNode in
                let clonedNode = childNode.clone()
                modelNode.addChildNode(clonedNode)
            }
            
            // 设置模型位置和缩放
            modelNode.position = position
            modelNode.scale = SCNVector3(scale, scale, scale)
            
            scene.rootNode.addChildNode(modelNode)
            
            // 重置视图
            resetView()
        } else {
            // 如果找不到模型文件，创建一个占位模型
            createPlaceholderModel()
        }
    }
    
    private func createPlaceholderModel() {
        modelNode = SCNNode()
        
        // 创建复杂的占位几何体
        let geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        geometry.firstMaterial?.diffuse.contents = UIColor.systemPurple
        geometry.firstMaterial?.specular.contents = UIColor.white
        geometry.firstMaterial?.shininess = 1.0
        geometry.firstMaterial?.metalness.contents = 0.8
        geometry.firstMaterial?.roughness.contents = 0.2
        
        let boxNode = SCNNode(geometry: geometry)
        modelNode.addChildNode(boxNode)
        
        scene.rootNode.addChildNode(modelNode)
    }
    
    @objc private func modelChanged(_ sender: UISegmentedControl) {
        let models = ["robot", "spaceship", "car", "character"]
        currentModel = models[sender.selectedSegmentIndex]
        loadModel(named: currentModel)
    }
}

// MARK: - Gesture Recognizers
extension T3D2ViewController {
    
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
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: sceneView)
        
        switch gestureRecognizer.state {
        case .changed:
            let rotationY = Float(translation.x) * .pi / 180.0 * 0.5
            let rotationX = Float(translation.y) * .pi / 180.0 * 0.5
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .default)
            
            modelNode.eulerAngles.x -= rotationX
            modelNode.eulerAngles.y -= rotationY
            
            SCNTransaction.commit()
            
            // 重置translation以便累计旋转
            gestureRecognizer.setTranslation(.zero, in: sceneView)
            
        default:
            break
        }
    }
    
    @objc private func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed:
            let scaleFactor = Float(gestureRecognizer.scale)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            
            // 限制缩放范围
            let currentScale = modelNode.scale.x
            let newScale = currentScale * scaleFactor
            let clampedScale = max(0.3, min(newScale, 3.0))
            
            modelNode.scale = SCNVector3(clampedScale, clampedScale, clampedScale)
            
            SCNTransaction.commit()
            
            gestureRecognizer.scale = 1.0
            
        default:
            break
        }
    }
}

// MARK: - Animation Methods
extension T3D2ViewController {
    
    @objc private func toggleAnimation() {
        if isAnimating {
            stopAllAnimations()
            animateButton.setTitle("开始动画", for: .normal)
            animateButton.backgroundColor = .systemGreen
        } else {
            startLightAnimation()
            startModelAnimation()
            animateButton.setTitle("停止动画", for: .normal)
            animateButton.backgroundColor = .systemRed
        }
        isAnimating.toggle()
    }
    
    private func startLightAnimation() {
        // 1. 主灯光颜色动画
        let mainLight = lightGroupNode.childNodes[1].light!
        let colorAnimation = CABasicAnimation(keyPath: "color")
        colorAnimation.fromValue = mainLight.color
        colorAnimation.toValue = UIColor(red: 0.8, green: 1.0, blue: 0.9, alpha: 1.0)
        colorAnimation.duration = 3.0
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = .infinity
        mainLight.addAnimation(colorAnimation, forKey: "colorAnimation")
        
        // 2. 灯光旋转动画
        let rotationAnimation = CABasicAnimation(keyPath: "rotation")
        rotationAnimation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        rotationAnimation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, .pi * 2.0))
        rotationAnimation.duration = 8.0
        rotationAnimation.repeatCount = .infinity
        lightGroupNode.addAnimation(rotationAnimation, forKey: "lightRotation")
        
        // 3. 点光源脉冲动画
        let fillLight = lightGroupNode.childNodes[2].light!
        let intensityAnimation = CABasicAnimation(keyPath: "intensity")
        intensityAnimation.fromValue = 800
        intensityAnimation.toValue = 1200
        intensityAnimation.duration = 2.0
        intensityAnimation.autoreverses = true
        intensityAnimation.repeatCount = .infinity
        fillLight.addAnimation(intensityAnimation, forKey: "intensityPulse")
    }
    
    private func startModelAnimation() {
        guard modelNode != nil else { return }
        
        // 1. 模型浮动动画
        let floatAnimation = CABasicAnimation(keyPath: "position")
        floatAnimation.fromValue = NSValue(scnVector3: modelNode.position)
        floatAnimation.toValue = NSValue(scnVector3: SCNVector3(
            modelNode.position.x,
            modelNode.position.y + 0.2,
            modelNode.position.z
        ))
        floatAnimation.duration = 2.0
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        modelNode.addAnimation(floatAnimation, forKey: "floatAnimation")
        
        // 2. 模型缓慢旋转动画
        let slowRotation = CABasicAnimation(keyPath: "rotation")
        slowRotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        slowRotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, .pi * 2.0))
        slowRotation.duration = 20.0
        slowRotation.repeatCount = .infinity
        modelNode.addAnimation(slowRotation, forKey: "slowRotation")
    }
    
    private func stopAllAnimations() {
        modelNode?.removeAllAnimations()
        lightGroupNode.removeAllAnimations()
        lightGroupNode.childNodes.forEach { node in
            node.light?.removeAllAnimations()
        }
    }
}

// MARK: - Control Methods
extension T3D2ViewController {
    
    @objc private func resetView() {
        stopAllAnimations()
        isAnimating = false
        animateButton.setTitle("开始动画", for: .normal)
        animateButton.backgroundColor = .systemGreen
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.8
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        // 重置模型变换
        modelNode.eulerAngles = SCNVector3(0, 0, 0)
        modelNode.scale = SCNVector3(1, 1, 1)
        
        // 重置相机
        cameraNode.position = SCNVector3(0, 1, 8)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        
        SCNTransaction.commit()
    }
}
