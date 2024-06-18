//
// ARViewContainer.swift
//
// Created by Speedyfriend67 on 19.06.24
//
 
import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    @State var arView: ARView?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        self.arView = arView
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        context.coordinator.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}