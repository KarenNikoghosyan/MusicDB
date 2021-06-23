//
//  AppPlayer.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 23/06/2021.
//

import AVFoundation
var player: AVAudioPlayer?

class MediaPlayer {
    
    public static let shared = MediaPlayer()
    
    func loadAudio(url: URL) {

        DispatchQueue.main.async {
            do {
                let data = try Data(contentsOf: url)
                player = try AVAudioPlayer(data: data)
            } catch {
                //TODO: Popup
                print(error)
            }
            if let player = player {
                player.prepareToPlay()
                player.volume = 1.0
                player.play()
            } else {
                print("Couldn't load the audio")
            }
        }
    }
    
    func stopAudio() {
        if let player = player {
            player.stop()
        }
    }
}
