import UIKit
import AVFoundation

let videoUrl = URL(string: "")!
let asset = AVURLAsset(url: videoUrl)
let (duration, isPlayable) = try await asset.load(.duration, .isPlayable)

let item = AVPlayerItem(asset: asset)
let player = AVPlayer(playerItem: item)
player.play()
player.pause()

let time = CMTime(seconds: 90, preferredTimescale: 600)
let time2 = CMTime(value: 5400, timescale: 600)
player.seek(to: time)
