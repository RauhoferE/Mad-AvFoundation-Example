//
//  ContentView.swift
//  VideoExample
//
//  Created by emre on 10.11.26.
//

import SwiftUI
import SwiftData
import AVFoundation
import AVKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    let videoURL = URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4")
    let fileUrl = Bundle.main.url(forResource: "exampleVideo", withExtension: "mp4")
    
    @State private var player: AVPlayer?
    @State private var durationText = "-:--"
    @State private var errorMessage: String?

    var body: some View {
        VStack{
            if let player {
                VideoPlayer(player: player)
                    .frame(height: 200)
            }else if let errorMessage{
                Text(errorMessage)
            }else{
                ProgressView()
            }
        }
        .task {
            var asset: AVURLAsset
            // Basically a description of the media
            // Nothing is load here yet
            if let url = fileUrl {
                asset = AVURLAsset(url: url)
            }else{
                errorMessage = "No url provided"
                return
            }
             
            
            do{
                // Then we can load its duration via the load function
                // we use try here since a network call can fail
                // Load basically fetches the properties
                let (duration, playable) = try await asset.load(.duration, .isPlayable)
                
                guard playable else {
                    errorMessage = "Video format cannot be played"
                    return
                }
                
                durationText = Duration.seconds(duration.seconds).formatted(.time(pattern: .minuteSecond))
                
                let item = AVPlayerItem(asset: asset)
                
                let newPlayer = AVPlayer(playerItem: item)
                player = newPlayer
//                await newPlayer.seek(to: CMTime(seconds: 90, preferredTimescale: 600))
                newPlayer.play()
                
                
            }catch{
                errorMessage = "Video could not be loaded: '\(error.localizedDescription)'"
            }
        }
        //Cancelling the task does not stop the player, thats why we need the extra code
        .onDisappear{
            player?.pause()
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
