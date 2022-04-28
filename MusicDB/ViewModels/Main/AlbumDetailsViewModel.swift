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
    func stopAnimation()
    func isLikedButtonSelected(isSelected: Bool)
    func loafMessageAdded(album: TopAlbums)
    func loafMessageRemoved(album: TopAlbums)
}

class AlbumDetailsViewModel {
    weak var delegate: AlbumDetailsViewModelDelegate?
    
    var albumTracks: [AlbumTrack] = []
    var album: TopAlbums?
    
    let albumTracksDS = AlbumTrackAPIDataSource()
    
    var isLiked: Bool = false
    
    var indexPath: IndexPath?
    var isHome: Bool? = false
    
    let toDetailsText = "toDetails"
    let trackText = "track"
    let albumText = "album"
    let isAlbumDetailsText = "isAlbumDetails"
}

//MARK: Functions
extension AlbumDetailsViewModel {
    
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
}
