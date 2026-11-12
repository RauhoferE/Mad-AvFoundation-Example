//
//  CameraPreview.swift
//  CameraExample
//
//  Created by emre on 11.11.26.
//

import SwiftUI
import AVFoundation
// Swift has no built in camera preview but UIKit has one
// Thats why we use UIViewRepresentable here
struct CameraPreview: UIViewRepresentable {
    // Session of whose images are to be shown
    let session: AVCaptureSession
    
    // Creates the view and hands it to swiftui
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        // Connects preview layer to session
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    // Protocol requires this method for updates but unused in our example
    func updateUIView(_ uiView: PreviewView, context: Context) {
        
    }
    
    
    final class PreviewView: UIView {
        // Overrides the views layer as the camera preview layer instead
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        // Convenience property
        // layer is delcared as CALAyer so you have to cast it to reach session
        // We can simlpy force cast it since the line above guarantees the layer has this type
        var previewLayer: AVCaptureVideoPreviewLayer{
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}

