//
//  S3DModelView2.swift
//  SwiftTest
//
//  Created by yyw on 2025/11/26.
//

import UIKit
import SnapKit
import SceneKit
import SceneKit.ModelIO

class S3DModelView2: BaseView {
    public override var backgroundColor: UIColor? {
        didSet {
            scene.background.contents = backgroundColor
        }
    }
    
    private var sceneView: SCNView!
    
    // 容器节点，模型和灯光都将添加到此节点
    private var scene: SCNScene!
    private var containerNode: SCNNode!
    // 模型节点
    private var modelNode: SCNNode?
    
    // 记录初始旋转状态
    private var initialRotation: SCNVector4?
    private var isRotating = false
    
    private let objURL: URL?
    private let hdrURL: URL?
    
    // 惯性相关属性
    // 角速度
    private var angularVelocity: CGPoint = .zero
    // 刷新链接
    private var displayLink: CADisplayLink?
    // 减速度系数
    private var deceleration: CGFloat = 0.9
    // 最后手势时间戳
    private var lastPanTimestamp: TimeInterval = 0
    // 最后手势位移
    private var lastPanTranslation: CGPoint = .zero
    
    public init(frame: CGRect, objURL: URL?, hdrURL: URL?) {
        self.objURL = objURL
        self.hdrURL = hdrURL
        super.init(frame: frame)
        
        setupUI()
        setupScene()
        setupContainerNode()
        loadOBJModel()
        setupHDREnvironment()
        setupGestureRecognizers()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 主场景视图
        sceneView = SCNView(frame: bounds)
        sceneView.backgroundColor = UIColor.black
        // 禁用默认光照，使用自定义光照
        sceneView.autoenablesDefaultLighting = false
        // 禁用默认相机控制，使用自定义手势
        sceneView.allowsCameraControl = false
        addSubview(sceneView)
    }
    
    private func setupScene() {
        scene = SCNScene()
        sceneView.scene = scene
    }
    
    private func setupContainerNode() {
        // 创建容器节点，所有变换将应用于此节点
        containerNode = SCNNode()
        containerNode.position = SCNVector3Zero // 固定在场景中心
        scene.rootNode.addChildNode(containerNode)
    }
    
    private func loadModelInBackground(objURL: URL, completion: @escaping (SCNNode?) -> Void)
    {
        // 1. 派发到全局后台队列
        DispatchQueue.global(qos: .userInitiated).async {
            // 2. 在子线程中创建 MDLAsset 和 SCNNode
            let asset = MDLAsset(url: objURL)
            guard let object = asset.object(at: 0) as? MDLMesh else {
                SLog("[3D] 无法加载 OBJ 模型")
                // 确保回调也在主线程，方便更新UI
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let modelNode = SCNNode(mdlObject: object)
            
            // 3. 回到主线程，执行完成回调
            DispatchQueue.main.async {
                completion(modelNode)
            }
        }
    }
    
    private func loadOBJModel() {
        guard let objURL = objURL else {
            SLog("[3D] OBJ文件未找到，请确保 .obj 文件已添加到项目中")
            return
        }
        
        loadModelInBackground(objURL: objURL) { [weak self] modelNode in
            guard let weakSelf = self else { return }
            guard let modelNode = modelNode else { return }
            // 调整模型缩放和位置
            weakSelf.setupSceneWithModel(modelNode)
            
            // 设置 PBR 材质以更好地响应 HDR 光照
            weakSelf.setupPBRMaterials(for: modelNode)
            
            // 添加到容器节点
            weakSelf.containerNode.addChildNode(modelNode)
            weakSelf.modelNode = modelNode
        }
    }
    
    func setupSceneWithModel(_ modelNode: SCNNode) {
        // 1. 首先将模型添加到场景
        scene.rootNode.addChildNode(modelNode)
        
        // 2. 计算模型边界和中心
        let boundingBox = modelNode.boundingBox
        let center = SCNVector3(
            (boundingBox.min.x + boundingBox.max.x) * 0.5,
            (boundingBox.min.y + boundingBox.max.y) * 0.5,
            (boundingBox.min.z + boundingBox.max.z) * 0.5
        )
        
        let size = SCNVector3(
            boundingBox.max.x - boundingBox.min.x,
            boundingBox.max.y - boundingBox.min.y,
            boundingBox.max.z - boundingBox.min.z
        )
        
        let maxDimension = max(size.x, max(size.y, size.z))
        
        // 3. 根据模型尺寸动态设置相机和缩放
        let (cameraPosition, scale) = calculateCameraAndScale(
            modelSize: maxDimension,
            modelCenter: center
        )
        
        // 4. 应用设置
        setupCamera(at: cameraPosition)
        modelNode.scale = SCNVector3(scale, scale, scale)
        
        // 5. 调整模型位置（居中显示）
        modelNode.position = SCNVector3(-center.x * scale, -center.y * scale, -center.z * scale)
    }
    
    private func calculateCameraAndScale(modelSize: Float, modelCenter: SCNVector3) -> (SCNVector3, Float) {
        var cameraPosition: SCNVector3
        var scale: Float
        
        if modelSize < 1.0 {
            // 小模型：近距离观看，中等缩放
            scale = 2.0 / modelSize
            cameraPosition = SCNVector3(0, 0, 4)
        } else if modelSize > 10.0 {
            // 大模型：远距离观看，缩小
            scale = 6.0 / modelSize
            cameraPosition = SCNVector3(0, 2, 12)
        } else {
            // 中等模型：标准设置
            scale = 3.0 / modelSize
            cameraPosition = SCNVector3(0, 1, 8)
        }
        
        return (cameraPosition, scale)
    }
    
    private func setupCamera(at position: SCNVector3) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = position
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupPBRMaterials(for modelNode: SCNNode) {
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
    
    // MARK: - HDR Environment Setup
    private func setupHDREnvironment() {
        guard let hdrURL = hdrURL else {
            SLog("[3D] HDR文件未找到，请确保 .hdr 文件已添加到项目中")
            return
        }
        
        // 设置 HDR 环境贴图
        scene.lightingEnvironment.contents = hdrURL
        scene.lightingEnvironment.intensity = 1.0 // 调整强度
    }
    
    // MARK: - Gesture Recognizers
    private func setupGestureRecognizers() {
        // 平移手势 - 旋转模型
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: sceneView)
        let currentTimestamp = CACurrentMediaTime()
        
        switch gestureRecognizer.state {
        case .began:
            isRotating = true
            stopInertia() // 停止之前的惯性
            lastPanTimestamp = currentTimestamp
            lastPanTranslation = translation
            
        case .changed:
            let rotationY = Float(translation.x) * .pi / 180.0 * 0.5
            let rotationX = Float(translation.y) * .pi / 180.0 * 0.5
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .default)
            
            // 直接使用欧拉角旋转容器节点
            containerNode.eulerAngles.x -= rotationX
            containerNode.eulerAngles.y -= rotationY
            
            SCNTransaction.commit()
            
            // 计算速度（用于惯性）
            let deltaTime = CGFloat(currentTimestamp - lastPanTimestamp)
            if deltaTime > 0 {
                let velocityX = (translation.x - lastPanTranslation.x) / deltaTime
                let velocityY = (translation.y - lastPanTranslation.y) / deltaTime
                angularVelocity = CGPoint(x: velocityX, y: velocityY)
            }
            
            lastPanTimestamp = currentTimestamp
            lastPanTranslation = translation
            
        case .ended, .cancelled:
            isRotating = false
            
            // 只有当速度足够大时才启动惯性
            let speed = sqrt(angularVelocity.x * angularVelocity.x + angularVelocity.y * angularVelocity.y)
            if speed > 50 { // 速度阈值，可调整
                startInertia()
            } else {
                stopInertia()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Inertia Methods
    private func startInertia() {
        stopInertia() // 确保之前的惯性已停止
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateInertia))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopInertia() {
        displayLink?.invalidate()
        displayLink = nil
        angularVelocity = .zero
    }
    
    @objc private func updateInertia() {
        // 当速度很小时停止惯性
        let speed = sqrt(angularVelocity.x * angularVelocity.x + angularVelocity.y * angularVelocity.y)
        guard speed > 1.0 else {
            stopInertia()
            return
        }
        
        // 应用减速度
        angularVelocity.x *= deceleration
        angularVelocity.y *= deceleration
        
        // 计算旋转角度（根据速度调整灵敏度）
        let rotationY = Float(angularVelocity.x) * .pi / 180.0 * 0.01
        let rotationX = Float(angularVelocity.y) * .pi / 180.0 * 0.01
        
        // 使用事务应用旋转，但不带动画以获得即时响应
        SCNTransaction.begin()
        SCNTransaction.disableActions = true // 禁用动画以获得平滑的惯性
        
        containerNode.eulerAngles.x -= rotationX
        containerNode.eulerAngles.y -= rotationY
        
        SCNTransaction.commit()
    }
    
    // MARK: - Enhanced Control Methods
    @objc private func resetView() {
        stopInertia() // 重置时停止所有惯性
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.8
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        // 重置容器旋转
        containerNode.eulerAngles = SCNVector3(0, 0, 0)
        
        // 重置模型缩放（如果有的话）
        if let modelNode = modelNode {
            // 重新计算合适的缩放比例
            let boundingBox = modelNode.boundingBox
            let size = SCNVector3(
                boundingBox.max.x - boundingBox.min.x,
                boundingBox.max.y - boundingBox.min.y,
                boundingBox.max.z - boundingBox.min.z
            )
            let maxDimension = max(size.x, max(size.y, size.z))
            let targetScale: Float = 3.0 / maxDimension
            
            modelNode.scale = SCNVector3(targetScale, targetScale, targetScale)
        }
        
        SCNTransaction.commit()
    }
    
    // MARK: - Public Methods
    public func stopAllAnimations() {
        stopInertia()
        modelNode?.removeAllActions()
        containerNode.removeAllActions()
    }
    
    // MARK: - Memory Management
    deinit {
        stopInertia()
    }
    
    // MARK: - Advanced Inertia Configuration
    public struct InertiaConfiguration {
        public let deceleration: CGFloat      // 减速度 (0-1)
        public let minSpeedThreshold: CGFloat // 最小速度阈值
        public let sensitivity: CGFloat       // 灵敏度系数
        
        // 平衡模式
        public static let `default` = InertiaConfiguration(deceleration: 0.92,
                                                           minSpeedThreshold: 1.0,
                                                           sensitivity: 0.015)
        
        // 快速响应
        public static let fast = InertiaConfiguration(deceleration: 0.1,
                                                      minSpeedThreshold: 2.0,
                                                      sensitivity: 1)
        
        // 平滑流畅
        public static let smooth = InertiaConfiguration(deceleration: 0.98,
                                                        minSpeedThreshold: 0.2,
                                                        sensitivity: 0.004)
    }
    
    private var inertiaConfig: InertiaConfiguration = .default
    
    public func setInertiaConfiguration(_ config: InertiaConfiguration) {
        inertiaConfig = config
        deceleration = config.deceleration
    }
    
    // 更新惯性计算方法以使用配置
    @objc private func updateInertiaWithConfig() {
        let speed = sqrt(angularVelocity.x * angularVelocity.x + angularVelocity.y * angularVelocity.y)
        guard speed > inertiaConfig.minSpeedThreshold else {
            stopInertia()
            return
        }
        
        // 应用配置的减速度
        angularVelocity.x *= inertiaConfig.deceleration
        angularVelocity.y *= inertiaConfig.deceleration
        
        // 使用配置的灵敏度
        let rotationY = Float(angularVelocity.x) * .pi / 180.0 * Float(inertiaConfig.sensitivity)
        let rotationX = Float(angularVelocity.y) * .pi / 180.0 * Float(inertiaConfig.sensitivity)
        
        SCNTransaction.begin()
        SCNTransaction.disableActions = true
        
        containerNode.eulerAngles.x -= rotationX
        containerNode.eulerAngles.y -= rotationY
        
        SCNTransaction.commit()
    }
}
