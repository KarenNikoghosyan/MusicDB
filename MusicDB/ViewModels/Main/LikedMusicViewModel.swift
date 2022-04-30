//
//  LikedMusicViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 03/03/2022.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol LikedMusicViewModelDelegate: AnyObject {
    func isSelectedSegment(index: Int, isHidden: Bool)
    
    func isLikedEmpty(isHidden: Bool)
    
    func fetchLikedTracks()
    func fetchLikedAlbums()
    
    func reloadTableView()
    func reloadTableViewWithAnimation()
    func deleteRowsFromTableView(tableView: UITableView, indexPath: IndexPath)
    func stopActivityIndicatorAnimation()
}

class LikedMusicViewModel {
    
    let singleTrackDS = SingleTrackAPIDataSource()
    var tracksIDs: [Int]?
    var numOfCallsTrack: Int = 0
    var trackIndex: Int = 0
    var isTrackLoaded: Bool = false
    
    let singleAlbumDS = SingleAlbumAPIDataSource()
    var albumIDs: [Int]?
    var numOfCallsAlbum: Int = 0
    var albumIndex: Int = 0
    var isAlbumLoaded: Bool = false
    
    var likedTracks: [Track] = []
    var likedAlbums: [TopAlbums] = []
    
    weak var likedMusicDelegate: LikedMusicViewModelDelegate?
    
    let trackCellReuseIdentifier = "trackCell"
    let albumCellReuseIdentifier = "albumCell"
    
    let tracksNibName = "LikedTracksTableViewCell"
    let albumsNibName = "LikedAlbumsTableViewCell"
    
    let editText = "Edit"
    let doneText = "Done"
    
    let toDetailsText = "toDetails"
    let toAlbumDetailsText = "toAlbumDetails"
    
    let noLikedTracksAndAlbumsText = "No liked tracks/albums,\n start by adding some."
}

//MARK: - Functions
extension LikedMusicViewModel {
    
    func setUpObservers() {
        //An observer to get the track from other viewcontrollers to add it to the tableview
        NotificationCenter.default.addObserver(forName: .AddTrack, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}

            if let track = notification.userInfo?["track"] as? Track {
                
                if !self.isTrackLoaded {return}
                
                self.likedTracks.append(track)
                self.likedMusicDelegate?.reloadTableView()
                
                if self.likedTracks.count > 0 && self.likedTracks.count <= 1 {
                    self.likedMusicDelegate?.isSelectedSegment(index: 0, isHidden: true)
                }
            }
        }
        //An observer to notify what track to remove from the tableview
        NotificationCenter.default.addObserver(forName: .RemoveTrack, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}

            if let track = notification.userInfo?["track"] as? Track {
                
                for (index, _) in self.likedTracks.enumerated() {
                    if self.likedTracks[index].id == track.id{
                        self.likedTracks.remove(at: index)
                        self.likedMusicDelegate?.reloadTableView()
                        
                        if self.likedTracks.count == 0 {
                            self.likedMusicDelegate?.isSelectedSegment(index: 0, isHidden: false)
                        }
                        return
                    }
                }
            }
        }
        //An observer to get the album from other viewcontrollers to add it to the tableview
        NotificationCenter.default.addObserver(forName: .AddAlbumID, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}

            if let album = notification.userInfo?["album"] as? TopAlbums {
                
                if !self.isAlbumLoaded {return}
                
                self.likedAlbums.append(album)
                self.likedMusicDelegate?.reloadTableView()
                
                if self.likedAlbums.count > 0 && self.likedAlbums.count <= 1 {
                    self.likedMusicDelegate?.isSelectedSegment(index: 1, isHidden: true)
                }
            }
        }
        //An observer to notify what album to remove from the tableview
        NotificationCenter.default.addObserver(forName: .RemoveAlbumID, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}

            if let album = notification.userInfo?["album"] as? TopAlbums {
                
                for (index, _) in self.likedAlbums.enumerated() {
                    if self.likedAlbums[index].id == album.id{
                        self.likedAlbums.remove(at: index)
                        self.likedMusicDelegate?.reloadTableView()
                        
                        if self.likedAlbums.count == 0 {
                            self.likedMusicDelegate?.isSelectedSegment(index: 1, isHidden: false)
                        }
                        return
                    }
                }
            }
        }
    }
    
    //Gets the liked tracks ids from the firestore database
    func getUserLikedTracks() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            self.tracksIDs = snapshot?.get("trackIDs") as? [Int] ?? nil
            self.numOfCallsTrack = self.tracksIDs?.count ?? 0
            self.likedMusicDelegate?.fetchLikedTracks()
        }
    }
    
    //Recursive call, will fetch tracks one by one, when ready it will load the tableview with the correct data
    func fetchSingleTrackDS() {
        singleTrackDS.fetchTracks(from: .track, id: tracksIDs?[trackIndex]) {[weak self] track, error in
            guard let self = self else {return}

            if let track = track {
                
                self.trackIndex += 1
                self.likedTracks.append(track)
                
                self.numOfCallsTrack -= 1
                if self.numOfCallsTrack > 0 {
                    self.fetchSingleTrackDS()
                } else {
                    self.trackIndex = 0
                    
                    self.likedMusicDelegate?.reloadTableView()
                    self.likedMusicDelegate?.reloadTableViewWithAnimation()
                }
                
            } else if let error = error {
                print(error)
                self.likedMusicDelegate?.stopActivityIndicatorAnimation()
            }
        }
    }
    
    func removeSingleTrack(track: Track, tableView: UITableView, indexPath: IndexPath) {
        guard let userID = Auth.auth().currentUser?.uid else {return}

        FirestoreManager.shared.db.collection("users").document(userID).updateData([
            "trackIDs" : FieldValue.arrayRemove([track.id as Any])
        ]) {[weak self] error in
            guard let self = self else {return}
            
            if let error = error {
                print("\(error.localizedDescription)")
            }
            self.likedTracks.remove(at: indexPath.row)
            self.likedMusicDelegate?.deleteRowsFromTableView(tableView: tableView, indexPath: indexPath)
            
            if self.likedTracks.count == 0 {
                self.likedMusicDelegate?.isLikedEmpty(isHidden: false)
            }
        }
    }
    
    //Gets the liked albums ids from the firestore database
    func getUserLikedAlbums() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            self.albumIDs = snapshot?.get("albumIDs") as? [Int] ?? nil
            self.numOfCallsAlbum = self.albumIDs?.count ?? 0
            self.likedMusicDelegate?.fetchLikedAlbums()
        }
    }
    
    //Recursive call, will fetch albums one by one, when ready it will load the tableview with the correct data
    func fetchSingleAlbumDS() {
        singleAlbumDS.fetchAlbums(from: .album, id: albumIDs?[albumIndex]) {[weak self] album, error in
            guard let self = self else {return}

            if let album = album {
                
                self.albumIndex += 1
                self.likedAlbums.append(album)
                self.numOfCallsAlbum -= 1
                if self.numOfCallsAlbum > 0 {
                    self.fetchSingleAlbumDS()
                } else {
                    self.albumIndex = 0
                    
                    self.likedMusicDelegate?.reloadTableView()
                    self.likedMusicDelegate?.reloadTableViewWithAnimation()
                }
                
            } else if let error = error {
                print(error)
                self.likedMusicDelegate?.stopActivityIndicatorAnimation()
            }
        }
    }
    
    func removeSingleAlbum(album: TopAlbums, tableView: UITableView, indexPath: IndexPath) {
        guard let userID = Auth.auth().currentUser?.uid else {return}

        FirestoreManager.shared.db.collection("users").document(userID).updateData([
            "albumIDs" : FieldValue.arrayRemove([album.id as Any])
        ]) {[weak self] error in
            guard let self = self else {return}
            
            if let error = error {
                print("\(error.localizedDescription)")
            }
            self.likedAlbums.remove(at: indexPath.row)
            self.likedMusicDelegate?.deleteRowsFromTableView(tableView: tableView, indexPath: indexPath)

            NotificationCenter.default.post(name: .ReloadFromLiked, object: nil, userInfo: nil)
            
            if self.likedAlbums.count == 0 {
                self.likedMusicDelegate?.isLikedEmpty(isHidden: false)
            }
        }
    }
}
