# AR Measure App

This project is a simple AR measurement application built using Swift and ARKit. The app allows users to place points in the real world and measure the distance between them. It features a crosshair for precise placement of points at the center of the screen.

## Features

- Place points in the real world by tapping the screen.
- Measure the distance between two points.
- Display the distance in centimeters.
- Crosshair for precise point placement.

## Requirements

- iOS 12.0 or later
- Xcode 12 or later
- Device with ARKit support (e.g., iPhone 6s or later)

## Project Structure

The project is divided into multiple Swift files for better organization:

1. **ContentView.swift**: Defines the main view of the application.
2. **ARViewContainer.swift**: Sets up the AR view and handles its configuration.
3. **Coordinator.swift**: Manages the gesture handling and AR entity creation.
4. **CrosshairView.swift**: Displays a crosshair at the center of the screen.

## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/ARMeasureApp.git
    ```
2. Open the project in Xcode:
    ```sh
    cd ARMeasureApp
    open ARMeasureApp.xcodeproj
    ```
3. Build and run the project on a physical iOS device.

## Usage

1. Launch the application on your device.
2. Point your camera at a surface and move the device to detect planes.
3. Tap the screen to place a point at the center crosshair.
4. Tap again to place a second point and measure the distance between the two points.

## File Descriptions

### ContentView.swift
This file contains the main view of the application, combining the AR view container and the crosshair view.

### ARViewContainer.swift
This file sets up the AR view, configures ARKit, and adds a tap gesture recognizer to handle user interactions.

### Coordinator.swift
This file manages the gesture handling and AR entity creation. It contains methods to handle taps, create points, lines, and text entities to display measurements.

### CrosshairView.swift
This file defines a SwiftUI view that displays a crosshair at the center of the screen to aid in precise point placement.

## Code Explanation

### ContentView.swift
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            CrosshairView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

### ARViewContainer.swift
```swift
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
```

### Coordinator.swift
```swift
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
```

### CrosshairView.swift
```swift
import SwiftUI

struct CrosshairView: View {
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            Path { path in
                path.move(to: CGPoint(x: center.x - 10, y: center.y))
                path.addLine(to: CGPoint(x: center.x + 10, y: center.y))
                
                path.move(to: CGPoint(x: center.x, y: center.y - 10))
                path.addLine(to: CGPoint(x: center.x, y: center.y + 10))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 2)
    }
}
```

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a new Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
