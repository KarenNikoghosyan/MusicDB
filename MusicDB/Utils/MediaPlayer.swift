//
//  AppPlayer.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 23/06/2021.
//

import AVFoundation

protocol MediaPlayerDelegate: AnyObject {
    func changeButtonStateAfterAudioStopsPlaying()
}

class MediaPlayer: NSObject {
    public static let shared = MediaPlayer()
    var player: AVAudioPlayer?
    weak var delegate: MediaPlayerDelegate?
    
    override private init() {}
}

//MARK: - Functions
extension MediaPlayer {
    
    func loadAudio(url: URL) {

        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            
            do {
                let data = try Data(contentsOf: url)
                self.player = try AVAudioPlayer(data: data)
            } catch {
                print(error.localizedDescription)
            }
            if let player = self.player {
                player.prepareToPlay()
                player.volume = 1.0
                player.delegate = self
                player.play()
            } else {
                print("Couldn't load the audio")
                self.player = nil
            }
        }
    }
    
    func stopAudio() {
        if let player = player {
            player.stop()
        }
    }
}

//MARK: - Delegates
extension MediaPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            delegate?.changeButtonStateAfterAudioStopsPlaying()
        }
    }
}
