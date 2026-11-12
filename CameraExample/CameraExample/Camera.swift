//
//  Camera.swift
//  CameraExample
//
//  Created by emre on 11.11.26.
//

import SwiftUI
import AVFoundation

// nonisolated so XCode does not assume that this runs on the main thread
// unchecked so the object is safe to use from several threads
nonisolated final class Camera:NSObject, @unchecked Sendable {
    // Creates a session that connects input to output
    let session = AVCaptureSession()
    // Creates an output for still photos
    private let photoOutput = AVCapturePhotoOutput()
    // Audio
    private let audioDataOutput = AVCaptureMovieFileOutput()
    // A queue where tasks run one at a time
    // Label so it shows up in the debugger
    private let sessionQueue = DispatchQueue(label: "camera.session")
    
    func start() {
        // Hands closure to the background queue and returns immediatly, so the UI never waits
        sessionQueue.async {
            // Tells swift that you keep self alive and allows to write session instead of self session
            [self] in
            // Starts batch of changes
            session.beginConfiguration()
            // Chooses quality preset (full resolution images) other presets .high, .low
            // Not needed in audio
            session.sessionPreset = .photo
            
            // Asks system for a physical camera (wide angel, video camera rather than microphone, and the camera on the back)
            if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
               // Wraps camera as an input the session can use
               // try? turns any error into nil
               let input = try? AVCaptureDeviceInput(device: camera),
               // CHecks if session can add the input
               session.canAddInput(input){
                session.addInput(input)
                // Here the pipeline is
                // camera -> input -> session
            }
            
            // FOr audio
            
            //if let audio = AVCaptureDevice.default(for: .audio),
            //   let input = try? AVCaptureDeviceInput(device: audio),
            //   session.canAddInput(input){
            //    session.addInput(input)
            //}
            
            // Checks if session can add output
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                // camera -> input -> session -> output
            }
            
            // Applies configuration
            session.commitConfiguration()
            // Starts the flow of data through the session
            // Its synchronous and does not return until the camera is running
            // Blocks only background thread since function only runs in background thread
            session.startRunning()
        }
    }
    
    
    func takePhoto() {
        // Takes picture and uses the same queue, so photo cant be requested while it is still being configured
        sessionQueue.async{
            [self] in
            // Asks photo output to take one picture with the default options described in the photo settigns
            // You can also change things like flash
            // The delate is where the result is send
            photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            
            // FOr audio
            //let url = URL.documentsDirectory.appending(path: "audio.mov")
            //try? FileManager.default.removeItem(at: url) // Remove file if it already exists
            //audioDataOutput.startRecording(to: url ,recordingDelegate:self)
        }
    }
    
    func stopRecording(){
        sessionQueue.async{
            [self] in
            audioDataOutput.stopRecording()
        }
    }
}
// An extension for camera so it can receive the photo
// Nonisolated needed because otherwise swift thinks the delegate runs in the main thread
nonisolated extension Camera: AVCapturePhotoCaptureDelegate {
    // This method is called when the photo is ready
    // Output is the photo output that took the the picture
    // photo is the result
    // and an optional error
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // TUrns photo into bytes
        // The guard is only here to catch if something goes wrong
        guard let data = photo.fileDataRepresentation() else { return }
        print("Captured photo")
    }
}

extension Camera: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard let data = outputFileURL.absoluteString.data(using: .utf8) else { return }
        print("Captured audio")
    }
}
