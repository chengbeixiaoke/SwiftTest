//
//  S3DModelView.swift
//  SwiftTest
//
//  Created by yyw on 2025/11/26.
//

import UIKit
import SnapKit
import SceneKit
import SceneKit.ModelIO

public class S3DModelView: BaseView {
    public override var backgroundColor: UIColor? {
        didSet {
            scene.background.contents = backgroundColor
        }
    }
    
    // 主场景
    private lazy var scene: SCNScene = {
        return SCNScene()
    }()
    
    // 主场景视图
    private lazy var sceneView: SCNView = {
        let sceneView = SCNView(frame: bounds)
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = false
        sceneView.delegate = self
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        return sceneView
    }()
    
    // 容器节点，模型和灯光都将添加到此节点
    private lazy var containerNode: SCNNode = {
        let containerNode = SCNNode()
        // 固定在场景中心
        containerNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(containerNode)
        return containerNode
    }()
    
    // 模型节点
    private var modelNode: SCNNode?
    
    // 记录相机初始位置
    private var cameraPosition: SCNVector3 = SCNVector3Zero
    
    // 惯性相关属性
    // 角速度
    private var angularVelocity: CGPoint = .zero
    // 惯性事件
    private var inertiaAction: SCNAction?
    
    private var initialPinchDistance: Float = 0.0
    private var lastPinchScale: Float = 1.0
    
    // 自动旋转相关属性
    private var isAutoRotating = false
    private var autoRotationAction: SCNAction?
    private var autoRotationSpeed: Double = 5.0 // 旋转速度（秒/圈）
    
    // 渲染完成回调
    private var isModelLoaded = false
    public var onModelLoadComplete: ((Bool) -> Void)?
    
    // 模型
    private let modelURL: URL?
    private let hdrURL: URL?
    
    public init(frame: CGRect, modelURL: URL?, hdrURL: URL?) {
        self.modelURL = modelURL
        self.hdrURL = hdrURL
        super.init(frame: frame)
        
        setupScene()
        setupGestureRecognizers()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置场景
    private func setupScene()
    {
        addSubview(sceneView)
    }
    
    /// 设置背景和光照模型
    public func loadHDREnvironment()
    {
        guard let hdrURL = hdrURL else {
            SLog("[3D] HDR文件未找到，请确保 .hdr 文件已添加到项目中")
            return
        }
        
        // scene.background.contents = hdrURL
        
        // 设置 HDR 环境贴图
        scene.lightingEnvironment.contents = hdrURL
        scene.lightingEnvironment.intensity = 1.0 // 调整强度
    }
    
    /// 加载模型
    public func loadOBJModel()
    {
        guard let modelURL = modelURL else {
            SLog("[3D] Model文件未找到，请确保模型文件已添加到项目中")
            onModelLoadComplete?(false)
            return
        }
        
        loadModelInBackground(modelURL: modelURL) { [weak self] modelNode in
            guard let self = self, let modelNode = modelNode else {
                SLog("[3D] 模型加载失败: \(modelURL.filePath)")
                
                DispatchQueue.main.async {
                    self?.onModelLoadComplete?(false)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.setupSceneWithModel(modelNode)
                self.setupPBRMaterials(for: modelNode)
                self.containerNode.addChildNode(modelNode)
                self.modelNode = modelNode
                self.setupInitialAngle(angle: 30, duration: 0.2)
                
                // 标记模型已添加，等待渲染完成
                self.isModelLoaded = true
                SLog("[3D] 模型节点已添加到场景，等待渲染完成...")
            }
        }
    }
    
    /// 加载模型
    /// - Parameters:
    ///   - objURL: 模型URL
    ///   - completion: 加载完成回调
    private func loadModelInBackground(modelURL: URL, completion: @escaping (SCNNode?) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = MDLAsset(url: modelURL)
            asset.loadTextures()
            let node = SCNNode(mdlObject: asset.object(at: 0))
            DispatchQueue.main.async {
                completion(node)
            }
        }
    }
    
    /// 设置模型
    /// - Parameter modelNode: 3D模型
    func setupSceneWithModel(_ modelNode: SCNNode)
    {
        // 1. 首先将模型添加到场景
        scene.rootNode.addChildNode(modelNode)
        
        // 设置相机
        S3DCameraSystem.setupOptimalCamera(modelNode: modelNode,
                                           sceneView: sceneView)
    }
    
    /// 为3D模型的所有子节点统一配置基于物理的渲染材质，确保模型在SceneKit中具有真实的光照和材质表现。
    /// - Parameter modelNode: 模型节点
    private func setupPBRMaterials(for modelNode: SCNNode)
    {
        // 遍历所有子节点并设置 PBR 材质
        modelNode.enumerateChildNodes { node, _ in
            if let geometry = node.geometry {
                for material in geometry.materials {
                    // 启用基于物理的渲染
                    material.lightingModel = .physicallyBased
                    
                    // 设置默认材质属性
                    if material.diffuse.contents == nil {
                        material.diffuse.contents = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
                    }
                    
                    // 设置金属度和粗糙度
                    material.metalness.contents = 0.3
                    material.roughness.contents = 0.7
                }
            }
        }
    }
    
    /// 设置手势
    private func setupGestureRecognizers()
    {
        // 平移手势 - 旋转模型
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
    }
    
    /// 重置模型
    @objc private func resetView() {
        stopInertia() // 重置时停止所有惯性
        stopAutoRotation() // 停止自动旋转
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.8
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        // 重置容器旋转
        setupInitialAngle(angle: initialAngle, duration: 0.2)
        
        // 重置相机位置
        if let systemCameraNode = sceneView.pointOfView {
            systemCameraNode.position = cameraPosition
            scene.rootNode.addChildNode(systemCameraNode)
        }
        
        SCNTransaction.commit()
        
        // 重置后自动开始旋转
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.startAutoRotation()
        }
    }
    
    private var initialAngle: CGFloat = 0
    public func setupInitialAngle(angle: CGFloat, duration: CGFloat = 0.5) {
        initialAngle = angle
        
        let radians = angle * .pi / 180.0
        let rotateAction = SCNAction.rotateTo(x: CGFloat(radians),
                                              y: 0,
                                              z: 0,
                                              duration: duration)
        containerNode.runAction(rotateAction)
    }
    
    deinit
    {
        stopInertia()
        stopAutoRotation()
        
        SLog("[View] - deinit:\(self.className())")
    }
}

// MARK: - 旋转手势
extension S3DModelView {
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: sceneView)
        
        switch gestureRecognizer.state {
        case .began:
            stopInertia()
            stopAutoRotation()
            
        case .changed:
            let rotationY = Float(translation.x) * .pi / 180.0 * 0.5
            let rotationX = Float(translation.y) * .pi / 180.0 * 0.5
            
            // 计算新的欧拉角
            var newEulerX = containerNode.eulerAngles.x + rotationX
            let newEulerY = containerNode.eulerAngles.y + rotationY
            
            // 限制X轴旋转在 -90° 到 90° 之间（±π/2）
            let maxRotationX = Float.pi / 2  // 90度
            newEulerX = max(-maxRotationX, min(maxRotationX, newEulerX))
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .default)
            
            containerNode.eulerAngles.x = newEulerX
            containerNode.eulerAngles.y = newEulerY
            
            SCNTransaction.commit()
            
            let systemVelocity = gestureRecognizer.velocity(in: sceneView)
            angularVelocity = systemVelocity
            
            gestureRecognizer.setTranslation(.zero, in: sceneView)
            
        case .ended, .cancelled:
            startInertia()
            
        default:
            break
        }
    }
    
    /// 停止惯性动画
    private func stopInertia()
    {
        containerNode.removeAction(forKey: "inertia")
        inertiaAction = nil
        angularVelocity = .zero
    }
    
    /// 开始惯性动画
    private func startInertia()
    {
        let speed = sqrt(angularVelocity.x * angularVelocity.x + angularVelocity.y * angularVelocity.y)
        
        // 调整启动阈值
        let minSpeed: CGFloat = 50.0 // 提高阈值，因为系统速度值较大
        guard speed > minSpeed else { return }
        
        // 计算惯性持续时间
        let duration = calculateInertiaDuration(speed: speed)
        
        // 创建惯性动画
        let inertiaAction = createInertiaAction(speed: speed, duration: duration)
        
        // 计算之后，停止之前的惯性动画
        stopInertia()
        // 开始惯性动画
        containerNode.runAction(inertiaAction, forKey: "inertia")
    }
    
    /// 计算惯性动画时间
    /// - Parameter speed: 初始速度
    /// - Returns: 动画时间
    private func calculateInertiaDuration(speed: CGFloat) -> TimeInterval
    {
        // 根据速度计算持续时间
        let minDuration: TimeInterval = 0.2
        let maxDuration: TimeInterval = 0.5
        let normalizedSpeed = min(speed / 1000.0, 0.5) // 标准化速度
        
        return minDuration + (maxDuration - minDuration) * TimeInterval(normalizedSpeed)
    }
    
    /// 惯性动画
    /// - Parameter speed: 初始速度
    /// - Parameter duration: 动画时间
    /// - Returns: 惯性动画
    private func createInertiaAction(speed: CGFloat, duration: TimeInterval) -> SCNAction
    {
        // 速度越大，灵敏度越高
        let sensitivity: Double = 0.002
        let speedFactor = min(speed / 500.0, 1.0)
        let dynamicSensitivity = sensitivity * (1.0 + speedFactor)
        
        var rotationY = Double(angularVelocity.x) * dynamicSensitivity * Double(duration)
        var rotationX = Double(angularVelocity.y) * dynamicSensitivity * Double(duration)
        
        // 限制1：单次惯性旋转的最大增量角度（90度）
        let maxIncrement = Double.pi / 2  // 90度
        rotationX = max(-maxIncrement, min(maxIncrement, rotationX))
        rotationY = max(-maxIncrement, min(maxIncrement, rotationY))
        
        // 限制2：X轴的绝对角度限制（90度）
        let currentEulerX = Double(containerNode.eulerAngles.x)
        let targetEulerX = currentEulerX + rotationX
        let maxRotationX = Double.pi / 2  // 90度
        
        var clampedTargetX = 0.0
        if targetEulerX > maxRotationX {
            clampedTargetX = max(0, maxRotationX - currentEulerX)
        } else if targetEulerX < -maxRotationX {
            clampedTargetX = -maxRotationX - currentEulerX
        } else {
            clampedTargetX = rotationX
        }
        
        let rotateAction = SCNAction.rotateBy(
            x: CGFloat(clampedTargetX),
            y: CGFloat(rotationY),
            z: 0,
            duration: duration
        )
        rotateAction.timingMode = .easeOut
        
        return rotateAction
    }
}

// MARK: - 缩放手势处理
extension S3DModelView {
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        // 直接使用系统提供的相机节点
        guard let systemCameraNode = sceneView.pointOfView else { return }
        
        switch gesture.state {
        case .began:
            stopInertia()
            stopAutoRotation()
            
        case .changed:
            let currentScale = Float(gesture.scale)
            let scaleFactor = currentScale / lastPinchScale
            
            // 移动系统相机而不是自定义相机
            let currentZ = systemCameraNode.position.z
            let newZ = currentZ / scaleFactor
            
            // 限制距离范围
            let minDistance: Float = cameraPosition.z * 0.5
            let maxDistance: Float = cameraPosition.z * 1.5
            let clampedZ = max(minDistance, min(maxDistance, newZ))
            
            systemCameraNode.position.z = clampedZ
            scene.rootNode.addChildNode(systemCameraNode)
            
            lastPinchScale = currentScale
            
        case .ended, .cancelled:
            lastPinchScale = 1.0
            
        default:
            break
        }
    }
}

// MARK: - 自动旋转动画
extension S3DModelView {
    /// 获取自动旋转状态
    public var autoRotating: Bool {
        return isAutoRotating
    }
    
    /// 设置自动旋转方向
    /// - Parameter clockwise: true为顺时针，false为逆时针
    public func setAutoRotationDirection(clockwise: Bool) {
        let direction: CGFloat = clockwise ? 1.0 : -1.0
        
        if isAutoRotating {
            stopAutoRotation()
            
            // 创建指定方向的旋转动画
            let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2 * direction, z: 0, duration: autoRotationSpeed)
            rotateAction.timingMode = .linear
            let repeatAction = SCNAction.repeatForever(rotateAction)
            
            containerNode.runAction(repeatAction, forKey: "autoRotation")
            autoRotationAction = repeatAction
            
            isAutoRotating = true
        }
    }
    
    public func startAutoRotation() {
        guard !isAutoRotating else { return }
        
        stopInertia()
        stopAutoRotation()
        
        isAutoRotating = true
        
        // 创建无限旋转动画
        let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi, z: 0, duration: autoRotationSpeed)
        rotateAction.timingMode = .linear
        
        // 无限重复
        let repeatAction = SCNAction.repeatForever(rotateAction)
        
        // 应用到容器节点
        containerNode.runAction(repeatAction, forKey: "autoRotation")
        autoRotationAction = repeatAction
        
        SLog("[3D] 开始自动旋转")
    }
    
    /// 停止自动旋转
    public func stopAutoRotation() {
        guard isAutoRotating else { return }
        
        containerNode.removeAction(forKey: "autoRotation")
        autoRotationAction = nil
        isAutoRotating = false
        
        SLog("[3D] 停止自动旋转")
    }
    
    /// 切换自动旋转状态
    public func toggleAutoRotation() {
        if isAutoRotating {
            stopAutoRotation()
        } else {
            startAutoRotation()
        }
    }
    
    /// 设置自动旋转速度
    /// - Parameter speed: 旋转一圈的秒数，越小越快
    public func setAutoRotationSpeed(_ speed: Double) {
        autoRotationSpeed = max(0.1, speed)
        
        if isAutoRotating {
            stopAutoRotation()
            startAutoRotation()
        }
    }
}

// MARK: - SCNSceneRendererDelegate
extension S3DModelView: SCNSceneRendererDelegate {
    // MARK: - SCNSceneRendererDelegate
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 每帧调用，可以在这里检测渲染状态
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // 场景渲染完成后调用
        if isModelLoaded {
            self.isModelLoaded = false // 重置状态
            
            // 延迟一帧确保完全渲染
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.notifyLoadCompletion(success: true)
            }
        }
    }
    
    private func notifyLoadCompletion(success: Bool, error: Error? = nil) {
        SLog("[3D] 模型加载完成: \(success ? "成功" : "失败")")
        
        if success {
            if let cameraNode = sceneView.pointOfView {
                cameraPosition = cameraNode.position
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let weakSelf = self else { return }
                self?.startAutoRotation()
                weakSelf.onModelLoadComplete?(success)
            }
        }
    }
}

class S3DCameraSystem {
    @discardableResult
    static func setupOptimalCamera(modelNode: SCNNode,
                                   sceneView: SCNView) -> SCNNode
    {
        // 获取模型几何信息
        let (center, size) = getModelGeometry(modelNode)
        
        // 计算相机参数
        let cameraConfig = calculateCameraConfiguration(modelNode: modelNode, size: size, center: center)
        SLog("[3D] cameraConfig: \(cameraConfig)")
        
        // 创建相机节点
        let cameraNode = createCameraNode(config: cameraConfig)
        
        // 添加看向模型的约束
        let lookConstraint = SCNLookAtConstraint(target: modelNode)
        cameraNode.constraints = [lookConstraint]
        
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
        return cameraNode
    }
    
    private static func getModelGeometry(_ node: SCNNode) -> (center: SCNVector3, size: SCNVector3)
    {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        
        let center = SCNVector3((min.x + max.x) / 2,
                                (min.y + max.y) / 2,
                                (min.z + max.z) / 2)
        
        let size = SCNVector3(max.x - min.x,
                              max.y - min.y,
                              max.z - min.z)
        
        return (center, size)
    }
    
    private static func calculateCameraConfiguration(modelNode: SCNNode, size: SCNVector3, center: SCNVector3) -> CameraConfig
    {
        let distance = calculatePerspectiveDistance(size: size)
        let position = SCNVector3(center.x, center.y + size.y * 0.2, center.z + distance)
        let (zNear, zFar) = calculateProperClippingPlanes(cameraPosition: position,
                                                          modelNode: modelNode)
        return CameraConfig(position: position,
                            fieldOfView: 45.0,
                            orthographicScale: nil,
                            zNear: zNear,
                            zFar: zFar)
    }
    
    private static func calculatePerspectiveDistance(size: SCNVector3) -> Float
    {
        let diagonal = sqrt(size.x * size.x + size.y * size.y + size.z * size.z)
        return diagonal * 1.3
    }
    
    private static func calculateProperClippingPlanes(cameraPosition: SCNVector3, modelNode: SCNNode) -> (zNear: Double, zFar: Double)
    {
        // 获取模型在世界坐标系中的位置
        let modelWorldPosition = modelNode.worldPosition
        
        // 计算相机到模型中心的距离
        let distanceToModel = sqrt(
            pow(cameraPosition.x - modelWorldPosition.x, 2) +
            pow(cameraPosition.y - modelWorldPosition.y, 2) +
            pow(cameraPosition.z - modelWorldPosition.z, 2)
        )
        
        // 获取模型尺寸
        let boundingBox = modelNode.boundingBox
        let modelSize = max(boundingBox.max.x - boundingBox.min.x,
                            boundingBox.max.y - boundingBox.min.y,
                            boundingBox.max.z - boundingBox.min.z)
        
        // 计算合理的裁剪平面
        let zNear = Double(max(0.1, distanceToModel - modelSize * 2))  // 确保包含模型
        let zFar = Double(distanceToModel + modelSize * 3)             // 确保包含远景
        
        return (zNear, zFar)
    }
    
    private static func createCameraNode(config: CameraConfig) -> SCNNode
    {
        let camera = SCNCamera()
        
        if let orthographicScale = config.orthographicScale {
            camera.usesOrthographicProjection = true
            camera.orthographicScale = orthographicScale
        } else {
            camera.fieldOfView = CGFloat(config.fieldOfView)
        }
        
        camera.zNear = config.zNear
        camera.zFar = config.zFar
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = config.position
        
        return cameraNode
    }
    
    private struct CameraConfig {
        let position: SCNVector3
        let fieldOfView: Double
        let orthographicScale: Double?
        let zNear: Double
        let zFar: Double
    }
}
