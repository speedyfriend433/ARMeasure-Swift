//
// Coordinator.swift
//
// Created by Speedyfriend67 on 19.06.24
//
 
import ARKit
import RealityKit

class Coordinator: NSObject {
    var parent: ARViewContainer
    var arView: ARView?
    var startPoint: SIMD3<Float>?
    
    init(_ parent: ARViewContainer) {
        self.parent = parent
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        let location = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        let results = arView.hitTest(location, types: [.featurePoint, .existingPlaneUsingExtent])
        
        if let firstResult = results.first {
            let position = SIMD3<Float>(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)
            
            if let startPoint = startPoint {
                let endPoint = position
                let distance = simd_distance(startPoint, endPoint)
                
                let lineEntity = createLineEntity(startPoint: startPoint, endPoint: endPoint)
                let textEntity = createTextEntity(text: String(format: "%.2f cm", distance * 100), position: endPoint)
                
                let anchorEntity = AnchorEntity(world: startPoint)
                let startPointEntity = createPointEntity(at: startPoint)
                let endPointEntity = createPointEntity(at: endPoint)
                
                anchorEntity.addChild(lineEntity)
                anchorEntity.addChild(textEntity)
                anchorEntity.addChild(startPointEntity)
                anchorEntity.addChild(endPointEntity)
                
                arView.scene.anchors.append(anchorEntity)
                
                self.startPoint = nil
            } else {
                self.startPoint = position
                let pointEntity = createPointEntity(at: position)
                let anchorEntity = AnchorEntity(world: position)
                anchorEntity.addChild(pointEntity)
                arView.scene.anchors.append(anchorEntity)
            }
        }
    }
    
    func createLineEntity(startPoint: SIMD3<Float>, endPoint: SIMD3<Float>) -> ModelEntity {
        let distance = simd_distance(startPoint, endPoint)
        let lineMesh = MeshResource.generateBox(size: [0.002, 0.002, distance])
        var material = SimpleMaterial()
        material.baseColor = .color(.yellow)
        let lineEntity = ModelEntity(mesh: lineMesh, materials: [material])
        let midPoint = (startPoint + endPoint) / 2.0
        lineEntity.position = midPoint
        let direction = normalize(endPoint - startPoint)
        let rotation = simd_quatf(from: SIMD3<Float>(0, 0, 1), to: direction)
        lineEntity.orientation = rotation
        return lineEntity
    }
    
    func createTextEntity(text: String, position: SIMD3<Float>) -> ModelEntity {
        let textMesh = MeshResource.generateText(text, extrusionDepth: 0.01, font: .systemFont(ofSize: 0.1), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
        var material = SimpleMaterial()
        material.baseColor = .color(.yellow)
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        textEntity.position = position + SIMD3<Float>(0, 0.05, 0)
        return textEntity
    }
    
    func createPointEntity(at position: SIMD3<Float>) -> ModelEntity {
        let sphere = MeshResource.generateSphere(radius: 0.01)
        var material = SimpleMaterial()
        material.baseColor = .color(.red)
        let sphereEntity = ModelEntity(mesh: sphere, materials: [material])
        sphereEntity.position = position
        return sphereEntity
    }
}