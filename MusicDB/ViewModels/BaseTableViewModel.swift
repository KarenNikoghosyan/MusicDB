//
//  BaseTableViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 12/02/2022.
//

import Foundation
import AVFAudio

protocol BaseTableViewModelDelegate: AnyObject {
    func changeButtonImageAndReloadRows(prevIndexPath: IndexPath)
}

class BaseTableViewModel {
    
    weak var delegate: BaseTableViewModelDelegate?
    
    var prevIndexPath: IndexPath?
    var arrIndexPaths: [IndexPath] = []
    var isPlaying: Bool = false
    
    var tracks: [Track] = []
    var albums: [TopAlbums] = []
    var albumTracks: [AlbumTrack] = []
    
    let ds = TrackAPIDataSource()
    
    let cellIdentifier = "cell"
    
    let chevronRightImage = "chevron.right"
    let playFillImage = "play.fill"
    let pauseFillImage = "pause.fill"
}

//MARK: - Functions
extension BaseTableViewModel {

    func playTrackIfFromAlbumsScreen(selectedIndexPath: IndexPath) {
        if !albumTracks.isEmpty {
            let albumTrack = albumTracks[selectedIndexPath.row]
            if let urlPreview = URL(string: "\(albumTrack.preview)") {
                MediaPlayer.shared.loadAudio(url: urlPreview)
            }
        }
    }
    
    func playTrackIfOtherScreen(selectedIndexPath: IndexPath) {
        if !tracks.isEmpty {
            //Stops button animation
            NotificationCenter.default.post(name: .StopButtonAnimation, object: nil)
            let track = tracks[selectedIndexPath.row]
            if let urlPreview = URL(string: "\(track.preview)") {
                MediaPlayer.shared.loadAudio(url: urlPreview)
            }
        }
    }
    
    func changeButtonStateAfterAudioStopsPlaying() {
        MediaPlayer.shared.stopAudio()
            
        if let prevIndexPath = self.prevIndexPath {
            self.clearArrIndexPath()
            self.delegate?.changeButtonImageAndReloadRows(prevIndexPath: prevIndexPath)
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
