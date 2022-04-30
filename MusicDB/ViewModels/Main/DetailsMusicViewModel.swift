//
//  DetailsMusicViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 29/04/2022.
//

import Foundation
import FirebaseAuth

protocol DetailsMusicViewModelDelegate: AnyObject {
    func reloadTableViewRows(selectedIndexPath: IndexPath)
    func assignPrevButton(_ sender: UIButton)
    func changeButtonImageAndReloadRows(prevIndexPath: IndexPath)
}

class DetailsMusicViewModel {
    
    let ds = TrackAPIDataSource()
    var tracks: [Track] = []
    
    var prevIndexPath: IndexPath?
    var arrIndexPaths: [IndexPath] = []
    
    weak var delegate: DetailsMusicViewModelDelegate?
}

//MARK: Functions
extension DetailsMusicViewModel {
    
    func setupBaseObservers() {
        NotificationCenter.default.addObserver(forName: .ResetPlayButton, object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {return}
            
            self.resetPlayButton()
        }
    }
    
    func playButtonLogic(_ sender: UIButton) {
        let selectedIndexPath = IndexPath.init(row: sender.tag, section: 0)
        
        //Resets the play button state
        if arrIndexPaths.contains(selectedIndexPath) {
            clearArrIndexPath()
            sender.setImage(UIImage(systemName: Constants.playFillImage), for: .normal)
            sender.tintColor = .darkGray
            
            delegate?.reloadTableViewRows(selectedIndexPath: selectedIndexPath)
            MediaPlayer.shared.stopAudio()
            return
        }
        
        //If we tapping on a second button it will reset the state of the previous button
        if arrIndexPaths.count == 1 {
            resetPlayButton()
        }
        
        //Saves the previous index and the button
        prevIndexPath = selectedIndexPath
        delegate?.assignPrevButton(sender)
        arrIndexPaths.append(selectedIndexPath)
        delegate?.reloadTableViewRows(selectedIndexPath: selectedIndexPath)
        
        //Plays the albums tracks
        if !tracks.isEmpty {
            playTrack(selectedIndexPath: selectedIndexPath)
        }
    }
    
    func playTrack(selectedIndexPath: IndexPath) {
        //Stops button animation
        NotificationCenter.default.post(name: .StopButtonAnimation, object: nil)
        let track = tracks[selectedIndexPath.row]
        if let urlPreview = URL(string: "\(track.preview)") {
            MediaPlayer.shared.loadAudio(url: urlPreview)
        }
    }
    
    func changeButtonStateAfterAudioStopsPlaying() {
        MediaPlayer.shared.stopAudio()
            
        if let prevIndexPath = self.prevIndexPath {
            clearArrIndexPath()
            delegate?.changeButtonImageAndReloadRows(prevIndexPath: prevIndexPath)
        }
    }
    
    func resetPlayButton() {
        clearArrIndexPath()
        
        if let prevIndexPath = prevIndexPath {
            delegate?.changeButtonImageAndReloadRows(prevIndexPath: prevIndexPath)
        }
        MediaPlayer.shared.stopAudio()
    }
    
    func clearArrIndexPath() {
        arrIndexPaths.removeAll()
    }
}
