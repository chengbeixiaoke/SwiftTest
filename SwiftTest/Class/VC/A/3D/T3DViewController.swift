//
//  T3DViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/11/12.
//

import UIKit
import SceneKit

class T3DViewController: BaseViewController {
    
    // MARK: - UI Components
    private var sceneView: SCNView!
    private var controlPanel: UIView!
    private var resetButton: UIButton!
    private var autoRotateSwitch: UISwitch!
    private var autoRotateLabel: UILabel!
    
    // MARK: - 3D Scene Properties
    private var scene: SCNScene!
    private var modelNode: SCNNode!
    private var cameraNode: SCNNode!
    private var ambientLightNode: SCNNode!
    private var directionalLightNode: SCNNode!
    private var omniLightNode: SCNNode!
    
    // MARK: - Gesture Properties
    private var lastPanLocation: CGPoint = .zero
    private var lastScale: CGFloat = 1.0
    private var isAutoRotating: Bool = false
    
    // MARK: - Rotation Animation
    private var rotationAnimation: CABasicAnimation?
    private var inertiaDisplayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScene()
        setupCamera()
        setupLighting()
        setupModel()
        setupGestureRecognizers()
        startAutoRotation()
    }
    
    deinit {
        inertiaDisplayLink?.invalidate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Setup Methods
extension T3DViewController {
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // 主场景视图
        sceneView = SCNView(frame: view.bounds)
        sceneView.backgroundColor = UIColor.black
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = false
        view.addSubview(sceneView)
        
        // 控制面板
        controlPanel = UIView()
        controlPanel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        controlPanel.layer.cornerRadius = 12
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlPanel)
        
        // 重置按钮
        resetButton = UIButton(type: .system)
        resetButton.setTitle("重置视图", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = UIColor.systemBlue
        resetButton.layer.cornerRadius = 8
        resetButton.addTarget(self, action: #selector(resetView), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(resetButton)
        
        // 自动旋转标签
        autoRotateLabel = UILabel()
        autoRotateLabel.text = "自动旋转"
        autoRotateLabel.textColor = .white
        autoRotateLabel.font = UIFont.systemFont(ofSize: 14)
        autoRotateLabel.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(autoRotateLabel)
        
        // 自动旋转开关
        autoRotateSwitch = UISwitch()
        autoRotateSwitch.isOn = true
        autoRotateSwitch.onTintColor = .systemBlue
        autoRotateSwitch.addTarget(self, action: #selector(toggleAutoRotation), for: .valueChanged)
        autoRotateSwitch.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(autoRotateSwitch)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 控制面板约束
            controlPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            controlPanel.widthAnchor.constraint(equalToConstant: 150),
            controlPanel.heightAnchor.constraint(equalToConstant: 100),
            
            // 重置按钮约束
            resetButton.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 12),
            resetButton.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 12),
            resetButton.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -12),
            resetButton.heightAnchor.constraint(equalToConstant: 40),
            
            // 自动旋转标签约束
            autoRotateLabel.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 12),
            autoRotateLabel.bottomAnchor.constraint(equalTo: controlPanel.bottomAnchor, constant: -15),
            
            // 自动旋转开关约束
            autoRotateSwitch.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -12),
            autoRotateSwitch.centerYAnchor.constraint(equalTo: autoRotateLabel.centerYAnchor)
        ])
    }
    
    private func setupScene() {
        scene = SCNScene()
        sceneView.scene = scene
        sceneView.antialiasingMode = .multisampling4X
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 60
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 1000
        cameraNode.position = SCNVector3(0, 0, 8)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting() {
        // 环境光
        ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor(white: 0.3, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        // 定向光
        directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light?.type = .directional
        directionalLightNode.light?.color = UIColor(white: 0.8, alpha: 1.0)
        directionalLightNode.light?.castsShadow = true
        directionalLightNode.position = SCNVector3(10, 10, 10)
        directionalLightNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directionalLightNode)
        
        // 点光源
        omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = .omni
        omniLightNode.light?.color = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
        omniLightNode.position = SCNVector3(-5, 5, 5)
        scene.rootNode.addChildNode(omniLightNode)
    }
    
    private func setupModel() {
        createComplexModel()
    }
    
    private func createComplexModel() {
        modelNode = SCNNode()
        
        // 中心球体
        let sphere = SCNSphere(radius: 0.8)
        sphere.firstMaterial?.diffuse.contents = UIColor.systemBlue
        sphere.firstMaterial?.specular.contents = UIColor.white
        sphere.firstMaterial?.shininess = 0.8
        let sphereNode = SCNNode(geometry: sphere)
        modelNode.addChildNode(sphereNode)
        
        // 环绕的圆环
        let torus = SCNTorus(ringRadius: 1.5, pipeRadius: 0.2)
        torus.firstMaterial?.diffuse.contents = UIColor.systemRed
        torus.firstMaterial?.specular.contents = UIColor.white
        torus.firstMaterial?.shininess = 1.0
        let torusNode = SCNNode(geometry: torus)
        torusNode.eulerAngles = SCNVector3(CGFloat.pi / 2, 0, 0)
        modelNode.addChildNode(torusNode)
        
        // 装饰性的小立方体
        for i in 0..<8 {
            let cube = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.05)
            cube.firstMaterial?.diffuse.contents = UIColor.systemGreen
            cube.firstMaterial?.specular.contents = UIColor.white
            
            let cubeNode = SCNNode(geometry: cube)
            let angle = Float(i) * Float.pi / 4
            cubeNode.position = SCNVector3(
                cos(angle) * 2.0,
                sin(angle) * 2.0,
                0
            )
            modelNode.addChildNode(cubeNode)
        }
        
        scene.rootNode.addChildNode(modelNode)
    }
}

// MARK: - Gesture Recognizers
extension T3DViewController {
    
    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(resetView))
        doubleTapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let currentLocation = gestureRecognizer.location(in: sceneView)
        
        switch gestureRecognizer.state {
        case .began:
            stopAutoRotation()
            lastPanLocation = currentLocation
            
        case .changed:
            let deltaX = Float(currentLocation.x - lastPanLocation.x)
            let deltaY = Float(currentLocation.y - lastPanLocation.y)
            
            let rotationAngleY = deltaX * 0.01
            let rotationAngleX = deltaY * 0.01
            
            // 使用欧拉角替代四元数，避免复杂的数学运算
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .default)
            
            modelNode.eulerAngles = SCNVector3(
                modelNode.eulerAngles.x + rotationAngleX,
                modelNode.eulerAngles.y + rotationAngleY,
                modelNode.eulerAngles.z
            )
            
            SCNTransaction.commit()
            lastPanLocation = currentLocation
            
        case .ended:
            let velocity = gestureRecognizer.velocity(in: sceneView)
            addInertiaEffect(with: velocity)
            
        default:
            break
        }
    }
    
    @objc private func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            stopAutoRotation()
            lastScale = gestureRecognizer.scale
            
        case .changed:
            let currentScale = gestureRecognizer.scale
            let scaleFactor = currentScale / lastScale
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            
            let currentPosition = cameraNode.position
            let newZ = currentPosition.z / Float(scaleFactor)
            let clampedZ = max(3.0, min(newZ, 20.0))
            cameraNode.position = SCNVector3(currentPosition.x, currentPosition.y, clampedZ)
            
            SCNTransaction.commit()
            lastScale = currentScale
            
        default:
            break
        }
    }
    
    private func addInertiaEffect(with velocity: CGPoint) {
        // 停止之前的惯性动画
        inertiaDisplayLink?.invalidate()
        
        var currentVelocity = CGPoint(x: velocity.x * 0.01, y: velocity.y * 0.01)
        let deceleration: CGFloat = 0.9
        
        inertiaDisplayLink = CADisplayLink(target: self, selector: #selector(updateInertia(_:)))
        inertiaDisplayLink?.preferredFramesPerSecond = 60
        inertiaDisplayLink?.add(to: .current, forMode: .common)
        
        // 使用关联对象存储惯性数据
        let inertiaData = InertiaData(velocity: currentVelocity, deceleration: deceleration)
        objc_setAssociatedObject(inertiaDisplayLink!, "inertiaData", inertiaData, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func updateInertia(_ displayLink: CADisplayLink) {
        guard let inertiaData = objc_getAssociatedObject(displayLink, "inertiaData") as? InertiaData else {
            displayLink.invalidate()
            return
        }
        
        var velocity = inertiaData.velocity
        let deceleration = inertiaData.deceleration
        
        // 更新速度
        velocity.x *= deceleration
        velocity.y *= deceleration
        
        // 应用旋转
        if abs(velocity.x) > 0.001 || abs(velocity.y) > 0.001 {
            let rotationAngleY = Float(velocity.x) * 0.01
            let rotationAngleX = Float(velocity.y) * 0.01
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = displayLink.duration
            SCNTransaction.disableActions = true
            
            modelNode.eulerAngles = SCNVector3(
                modelNode.eulerAngles.x + rotationAngleX,
                modelNode.eulerAngles.y + rotationAngleY,
                modelNode.eulerAngles.z
            )
            
            SCNTransaction.commit()
            
            // 更新数据
            let updatedData = InertiaData(velocity: velocity, deceleration: deceleration)
            objc_setAssociatedObject(displayLink, "inertiaData", updatedData, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            // 速度足够小，停止惯性
            displayLink.invalidate()
            inertiaDisplayLink = nil
        }
    }
}

// MARK: - Inertia Data Helper
private class InertiaData {
    var velocity: CGPoint
    let deceleration: CGFloat
    
    init(velocity: CGPoint, deceleration: CGFloat) {
        self.velocity = velocity
        self.deceleration = deceleration
    }
}

// MARK: - Animation Methods
extension T3DViewController {
    
    private func startAutoRotation() {
        guard autoRotateSwitch.isOn else { return }
        
        stopAutoRotation()
        isAutoRotating = true
        
        rotationAnimation = CABasicAnimation(keyPath: "rotation")
        rotationAnimation?.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        rotationAnimation?.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotationAnimation?.duration = 8.0
        rotationAnimation?.repeatCount = .infinity
        rotationAnimation?.timingFunction = CAMediaTimingFunction(name: .linear)
        
        modelNode.addAnimation(rotationAnimation!, forKey: "autoRotation")
    }
    
    private func stopAutoRotation() {
        guard isAutoRotating else { return }
        
        isAutoRotating = false
        modelNode.removeAnimation(forKey: "autoRotation", blendOutDuration: 0.5)
    }
    
    @objc private func toggleAutoRotation() {
        if autoRotateSwitch.isOn {
            startAutoRotation()
        } else {
            stopAutoRotation()
        }
    }
}

// MARK: - Control Methods
extension T3DViewController {
    
    @objc private func resetView() {
        stopAutoRotation()
        inertiaDisplayLink?.invalidate()
        inertiaDisplayLink = nil
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        modelNode.eulerAngles = SCNVector3(0, 0, 0)
        cameraNode.position = SCNVector3(0, 0, 8)
        
        SCNTransaction.completionBlock = { [weak self] in
            if self?.autoRotateSwitch.isOn == true {
                self?.startAutoRotation()
            }
        }
        
        SCNTransaction.commit()
    }
}
