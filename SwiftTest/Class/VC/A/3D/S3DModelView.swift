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
//            scene.background.contents = backgroundColor
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
    
    // 相机节点
    private lazy var cameraNode: SCNNode = {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = cameraPosition
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
        return cameraNode
    }()
    
    // 模型节点
    private var modelNode: SCNNode?
    
    // 记录初始旋转状态
    private var initialRotation: SCNVector4?
    private var isRotating = false
    
    // 记录相机位置
    private var cameraPosition: SCNVector3 = SCNVector3Zero
    
    // 惯性相关属性
    // 角速度
    private var angularVelocity: CGPoint = .zero
    // 惯性事件
    private var inertiaAction: SCNAction?
    
    // 渲染完成回调
    private var isModelLoaded = false
    public var onModelLoadComplete: ((Bool) -> Void)?
    
    // 模型
    private let objURL: URL?
    private let hdrURL: URL?
    
    public init(frame: CGRect, objURL: URL?, hdrURL: URL?) {
        self.objURL = objURL
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
    public func loadHDREnvironment() {
        guard let hdrURL = hdrURL else {
            printLog("[3D] HDR文件未找到，请确保 .hdr 文件已添加到项目中")
            return
        }
        
        scene.background.contents = hdrURL
        
        // 设置 HDR 环境贴图
        scene.lightingEnvironment.contents = hdrURL
        scene.lightingEnvironment.intensity = 1.0 // 调整强度
    }
    
    /// 加载模型
    func loadOBJModel()
    {
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
    
    /// 加载模型
    /// - Parameters:
    ///   - objURL: 模型URL
    ///   - completion: 加载完成回调
    private func loadModelInBackground(objURL: URL, completion: @escaping (SCNNode?) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = MDLAsset(url: objURL)
            guard let object = asset.object(at: 0) as? MDLMesh else {
                printLog("[3D] 无法加载 OBJ 模型")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let modelNode = SCNNode(mdlObject: object)
            DispatchQueue.main.async {
                completion(modelNode)
            }
        }
    }
    
    /// 设置模型
    /// - Parameter modelNode: 3D模型
    func setupSceneWithModel(_ modelNode: SCNNode)
    {
        // 1. 首先将模型添加到场景
        scene.rootNode.addChildNode(modelNode)
        
        // 2. 计算模型边界和中心
        let boundingBox = modelNode.boundingBox
        let center = SCNVector3((boundingBox.min.x + boundingBox.max.x) * 0.5,
                                (boundingBox.min.y + boundingBox.max.y) * 0.5,
                                (boundingBox.min.z + boundingBox.max.z) * 0.5)
        
        let size = SCNVector3(boundingBox.max.x - boundingBox.min.x,
                              boundingBox.max.y - boundingBox.min.y,
                              boundingBox.max.z - boundingBox.min.z)
        
        // 3. 根据模型尺寸动态设置相机位置
        cameraPosition = calculateCameraPosition(modelSize: size,
                                                 modelCenter: center)
        
        // 5. 调整模型位置（居中显示）
        modelNode.position = SCNVector3(-center.x, -center.y, -center.z)
    }
    
    /// 获取相机位置参数
    /// - Parameters:
    ///   - modelSize: 模型尺寸
    ///   - modelCenter: 模型中心位置
    ///   - desiredScreenCoverage: 模型希望占据屏幕的比例 (0-1)，默认0.8
    ///   - cameraFOV: 相机视野角度(度)，默认60.0
    /// - Returns: 相机位置
    private func calculateCameraPosition(modelSize: SCNVector3,
                                         modelCenter: SCNVector3,
                                         desiredScreenCoverage: Float = 0.8,
                                         cameraFOV: Float = 60.0) -> SCNVector3
    {
        
        // 获取模型包围盒的最大尺寸
        let modelMaxDimension = max(modelSize.x, modelSize.y, modelSize.z)
        
        // 根据FOV和期望的屏幕覆盖率计算理想相机距离
        let fovRadians = cameraFOV * .pi / 180.0
        let idealDistance = (modelMaxDimension / desiredScreenCoverage) / tan(fovRadians / 2)
        
        // 设置基础距离和最小安全距离
        let baseDistance = max(idealDistance, 2.0) // 最小距离2.0避免穿模
        let maxDistance: Float = 50.0 // 最大距离限制
        
        var cameraPosition: SCNVector3
        
        if modelMaxDimension < 0.5 {
            // 微小模型：稍微拉远相机，让用户看到全貌
            cameraPosition = SCNVector3(0, 0, min(baseDistance * 1.5, maxDistance))
        } else if modelMaxDimension > 15.0 {
            // 超大模型：拉远相机，确保完整显示
            cameraPosition = SCNVector3(0, modelSize.y * 0.3, min(baseDistance * 1.2, maxDistance))
        } else {
            // 常规模型：标准观看距离，稍微俯视
            cameraPosition = SCNVector3(0, modelSize.y * 0.2, min(baseDistance, maxDistance))
        }
        
        // 将相机位置偏移到模型中心
        cameraPosition = SCNVector3(
            modelCenter.x + cameraPosition.x,
            modelCenter.y + cameraPosition.y,
            modelCenter.z + cameraPosition.z
        )
        
        return cameraPosition
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
    }
    
    /// 重置模型
    @objc private func resetView() {
        stopInertia() // 重置时停止所有惯性
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.8
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        // 重置容器旋转
        containerNode.eulerAngles = SCNVector3(0, 0, 0)
        
        if let modelNode = modelNode {
            setupSceneWithModel(modelNode)
        }
        
        SCNTransaction.commit()
    }
    
    deinit {
        stopInertia()
    }
}

// MARK: - 旋转手势
extension S3DModelView {
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: sceneView)
        
        switch gestureRecognizer.state {
        case .began:
            isRotating = true
            stopInertia()
            
        case .changed:
            let rotationY = Float(translation.x) * .pi / 180.0 * 0.3
            let rotationX = Float(translation.y) * .pi / 180.0 * 0.3
            
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
            isRotating = false
            startInertia()
            
        default:
            break
        }
    }
}

// MARK: - 惯性动画
extension S3DModelView {
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

// MARK: - SCNSceneRendererDelegate
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
        cameraNode.position = cameraPosition
    }
}
