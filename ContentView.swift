//
// ContentView.swift
//
// Created by Speedyfriend67 on 18.06.24
//
 
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