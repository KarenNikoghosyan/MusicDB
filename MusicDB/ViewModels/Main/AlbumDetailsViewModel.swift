//
//  AlbumDetailsViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 07/03/2022.
//

import Foundation
import FirebaseAuth

protocol AlbumDetailsViewModelDelegate: AnyObject {
    func reloadTableView(albumTracks: [AlbumTrack])
    func reloadTableViewRows(selectedIndexPath: IndexPath)
    func assignPrevButton(_ sender: UIButton)
    func stopAnimation()
    func isLikedButtonSelected(isSelected: Bool)
    func loafMessageAdded(album: TopAlbums)
    func loafMessageRemoved(album: TopAlbums)
    func changeButtonImageAndReloadRows(prevIndexPath: IndexPath)
}

class AlbumDetailsViewModel {
    weak var delegate: AlbumDetailsViewModelDelegate?
    
    var albumTracks: [AlbumTrack] = []
    var album: TopAlbums?
    var prevIndexPath: IndexPath?
    var arrIndexPaths: [IndexPath] = []
    
    let albumTracksDS = AlbumTrackAPIDataSource()
    
    var isLiked: Bool = false
    
    var indexPath: IndexPath?
    var isHome: Bool? = false
    
    let toDetailsText = "toDetails"
    let trackText = "track"
    let albumText = "album"
    let isAlbumDetailsText = "isAlbumDetails"
}

//MARK: - Functions
extension AlbumDetailsViewModel {
    
    func setupObservers() {
        //An observer to check if the app moved to background
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(forName: .ResetPlayButton, object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {return}
            
            self.resetPlayButton()
        }
    }
    
    //Handles the play button state when the app moves to background
    @objc private func appMovedToBackground() {
        MediaPlayer.shared.stopAudio()
        arrIndexPaths.removeAll()
        if let prevIndexPath = prevIndexPath {
            delegate?.changeButtonImageAndReloadRows(prevIndexPath: prevIndexPath)
        }
    }
    
    //Fetches the tracks
    func fetchTracks() {
        guard let album = album else {return}

        //Substring the string to send it to the fetch tracks func
        let start = album.tracklist.index(album.tracklist.startIndex, offsetBy: 28)
        let end = album.tracklist.index(album.tracklist.endIndex, offsetBy: 0)
        let result = album.tracklist[start..<end]
        
        let newTrackList = String(result)
        
        albumTracksDS.fetchTracks(from: .album, path: newTrackList, with: ["limit" : 100]) {[weak self] albumTracks, error in
            guard let self = self else {return}
            
            if let albumTracks = albumTracks {
                self.albumTracks = albumTracks
                
                self.delegate?.reloadTableView(albumTracks: albumTracks)
                self.delegate?.stopAnimation()
                
            } else if let error = error {
                print(error)
                self.delegate?.stopAnimation()
            }
        }
    }
    
    //Checks the liked button status when moving to this screen
    func checkLikedStatus() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            //Gets the albumIDs from firestore
            guard let arrIDs: [Int] = snapshot?.get("albumIDs") as? [Int] else {return}
            if arrIDs.contains(self.album?.id ?? 0) {
                self.delegate?.isLikedButtonSelected(isSelected: true)
                self.isLiked = true
            } else {
                self.delegate?.isLikedButtonSelected(isSelected: false)
                self.isLiked = false
            }
        }
    }
    
    func convertAlbumTrackToTrack(indexPathRow: Int) -> [String : Any] {
        let oldTrack = albumTracks[indexPathRow]
        let track = Track(
            id: oldTrack.id,
            title: oldTrack.title,
            titleShort: oldTrack.titleShort,
            titleVersion: oldTrack.titleVersion,
            link: oldTrack.link,
            duration: oldTrack.duration,
            rank: oldTrack.rank,
            explicitLyrics: oldTrack.explicitLyrics,
            explicitContentLyrics: oldTrack.explicitContentLyrics,
            explicitContentCover: oldTrack.explicitContentCover,
            preview: oldTrack.preview,
            md5Image: oldTrack.md5Image,
            position: nil,
            artist: oldTrack.artist,
            album: nil,
            type: oldTrack.type)
        
        let dict: [String : Any] = [
            "track" : track,
            "album" : album as Any,
            "isAlbumDetails" : true
        ]
        
        return dict
    }
    
    func removeAddAlbumToFromFirebase() {
        guard let userID = Auth.auth().currentUser?.uid,
              let album = album else {return}
        
        if !isLiked {
            //Adds an ablum
            FirestoreManager.shared.addAlbum(album: album, userID: userID)
            delegate?.loafMessageAdded(album: album)

            isLiked = true
        } else {
            //Removes an album
            FirestoreManager.shared.removeAlbum(album: album, userID: userID)
            delegate?.loafMessageRemoved(album: album)

            isLiked = false
        }
    }
    
    func isHomeScreen() {
        guard let isHome = isHome else {return}

        if isHome {
            NotificationCenter.default.post(name: .ReloadFromHome, object: nil, userInfo: nil)
        } else {
            NotificationCenter.default.post(name: .SendIndexPathAlbum, object: nil, userInfo: [Constants.indexPathText : indexPath as Any])
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
        if !albumTracks.isEmpty {
            playAlbumTrack(selectedIndexPath: selectedIndexPath)
        }
    }
    
    func playAlbumTrack(selectedIndexPath: IndexPath) {
        let albumTrack = albumTracks[selectedIndexPath.row]
        if let urlPreview = URL(string: "\(albumTrack.preview)") {
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
