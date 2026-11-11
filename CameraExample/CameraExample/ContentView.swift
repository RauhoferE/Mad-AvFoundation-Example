//
//  ContentView.swift
//  CameraExample
//
//  Created by emre on 11.11.26.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @State private var camera = Camera()
    
    var body: some View {
        ZStack(alignment: .bottom){
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
            Button("Take Photo"){
                camera.takePhoto()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
        }
        .task {
            // Background task that requests access to the camera and then starts it
            guard await AVCaptureDevice.requestAccess(for: .video) else { return }
            camera.start()
            // FOr audio
            //guard await AVCaptureDevice.requestAccess(for: .audio) else { return}
        
        }
    }
}
