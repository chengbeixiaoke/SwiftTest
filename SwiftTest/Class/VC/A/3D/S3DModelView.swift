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

class S3DModelView: BaseView {
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
    // 惯性事件
    private var inertiaAction: SCNAction?
    
    public var onModelLoadComplete: ((Bool) -> Void)?
    private var isModelLoaded = false
    
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
        sceneView.delegate = self
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
    
    func loadOBJModel() {
        guard let objURL = objURL else {
            printLog("[3D] OBJ文件未找到，请确保 .obj 文件已添加到项目中")
            onModelLoadComplete?(false)
            return
        }
        
        loadModelInBackground(objURL: objURL) { [weak self] modelNode in
            guard let self = self, let modelNode = modelNode else {
                printLog("[3D] 模型加载失败: \(objURL.filePath)")
                
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
                
                // 标记模型已添加，等待渲染完成
                self.isModelLoaded = true
                printLog("[3D] 模型节点已添加到场景，等待渲染完成...")
            }
        }
    }
    
    private func loadModelInBackground(objURL: URL, completion: @escaping (SCNNode?) -> Void)
    {
        // 1. 派发到全局后台队列
        DispatchQueue.global(qos: .userInitiated).async {
            // 2. 在子线程中创建 MDLAsset 和 SCNNode
            let asset = MDLAsset(url: objURL)
            guard let object = asset.object(at: 0) as? MDLMesh else {
                printLog("[3D] 无法加载 OBJ 模型")
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
            printLog("[3D] HDR文件未找到，请确保 .hdr 文件已添加到项目中")
            return
        }
        
        // scene.background.contents = hdrURL
        
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
        
        switch gestureRecognizer.state {
        case .began:
            isRotating = true
            stopInertia()
            
        case .changed:
            let rotationY = Float(translation.x) * .pi / 180.0 * 0.3
            let rotationX = Float(translation.y) * .pi / 180.0 * 0.3
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .default)
            
            containerNode.eulerAngles.x += rotationX
            containerNode.eulerAngles.y += rotationY
            
            SCNTransaction.commit()
            
            let systemVelocity = gestureRecognizer.velocity(in: sceneView)
            angularVelocity = systemVelocity
            
            printLog("[3D] 系统速度: (\(systemVelocity.x), \(systemVelocity.y))")
            
            gestureRecognizer.setTranslation(.zero, in: sceneView)
            
        case .ended, .cancelled:
            isRotating = false
            
            printLog("[3D] 手势结束，最终速度: (\(angularVelocity.x), \(angularVelocity.y))")
            startInertia()
            
        default:
            break
        }
    }
    
    private func stopInertia() {
        containerNode.removeAction(forKey: "inertia")
        inertiaAction = nil
        angularVelocity = .zero
    }
    
    private func startInertia() {
        let speed = sqrt(angularVelocity.x * angularVelocity.x + angularVelocity.y * angularVelocity.y)
        printLog("[3D] 计算速度: \(speed)")
        
        // 调整启动阈值
        let minSpeed: CGFloat = 50.0 // 提高阈值，因为系统速度值较大
        guard speed > minSpeed else {
            printLog("[3D] 速度不足，不启动惯性")
            return
        }
        
        // 计算惯性持续时间
        let duration = calculateInertiaDuration(speed: speed)
        
        // 创建惯性动画
        let inertiaAction = createInertiaAction(duration: duration)
        
        // 计算之后，停止之前的惯性动画
        stopInertia()
        // 开始惯性动画
        containerNode.runAction(inertiaAction, forKey: "inertia")
        
        printLog("[3D] 启动惯性，速度: \(speed), 持续时间: \(duration)")
    }
    
    private func calculateInertiaDuration(speed: CGFloat) -> TimeInterval {
        // 根据速度计算持续时间
        let minDuration: TimeInterval = 0.2
        let maxDuration: TimeInterval = 0.5
        let normalizedSpeed = min(speed / 1000.0, 0.5) // 标准化速度
        
        return minDuration + (maxDuration - minDuration) * TimeInterval(normalizedSpeed)
    }
    
    private func createInertiaAction(duration: TimeInterval) -> SCNAction {
        // 根据速度动态调整灵敏度
        let speed = sqrt(angularVelocity.x * angularVelocity.x + angularVelocity.y * angularVelocity.y)
        
        // 速度越大，灵敏度越高
        let sensitivity: Double = 0.002
        let speedFactor = min(speed / 500.0, 1.0) // 限制最大倍数
        let dynamicSensitivity = sensitivity * (1.0 + speedFactor)
        
        let rotationY = Double(-angularVelocity.x) * dynamicSensitivity * Double(duration)
        let rotationX = Double(-angularVelocity.y) * dynamicSensitivity * Double(duration)
        
        printLog("[3D] 动态惯性 - 速度: \(speed), 灵敏度: \(dynamicSensitivity), 旋转: (\(rotationX), \(rotationY))")
        
        let rotateAction = SCNAction.rotateBy(
            x: CGFloat(-rotationX),
            y: CGFloat(-rotationY),
            z: 0,
            duration: duration
        )
        rotateAction.timingMode = .easeOut
        
        return rotateAction
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
    
    // MARK: - Memory Management
    deinit {
        stopInertia()
    }
}

extension S3DModelView: SCNSceneRendererDelegate {
    // MARK: - SCNSceneRendererDelegate
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 每帧调用，可以在这里检测渲染状态
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // 场景渲染完成后调用
        if isModelLoaded {
            // 延迟一帧确保完全渲染
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.notifyLoadCompletion(success: true)
                self.isModelLoaded = false // 重置状态
            }
        }
    }
    
    private func notifyLoadCompletion(success: Bool, error: Error? = nil) {
        printLog("[3D] 模型加载完成: \(success ? "成功" : "失败")")
        onModelLoadComplete?(success)
    }
}
