//
// CrossHairView.swift
//
// Created by Speedyfriend67 on 18.06.24
//
 
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
}