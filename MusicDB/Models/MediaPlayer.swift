//
//  AppPlayer.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 23/06/2021.
//

import AVFoundation

class MediaPlayer {
    var player: AVAudioPlayer?
    
    public static let shared = MediaPlayer()
    
    func loadAudio(url: URL) {

        DispatchQueue.main.async {[weak self] in
            do {
                let data = try Data(contentsOf: url)
                self?.player = try AVAudioPlayer(data: data)
            } catch {
                //TODO: Popup
                print(error)
            }
            if let player = self?.player {
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
