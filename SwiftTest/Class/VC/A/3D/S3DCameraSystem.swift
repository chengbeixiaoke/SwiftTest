//
//  S3DCameraSystem.swift
//  SwiftTest
//
//  Created by yyw on 2025/11/27.
//

import UIKit
import SceneKit

class S3DCameraSystem {
    @discardableResult
    static func setupOptimalCamera(modelNode: SCNNode,
                                   sceneView: SCNView) -> SCNNode
    {
        // 获取模型几何信息
        let (center, size) = getModelGeometry(modelNode)
        
        // 计算相机参数
        let cameraConfig = calculateCameraConfiguration(modelNode: modelNode, size: size, center: center)
        printLog("[3D] cameraConfig: \(cameraConfig)")
        
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
