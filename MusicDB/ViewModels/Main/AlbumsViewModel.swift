//
//  AlbumsViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 28/04/2022.
//

import Foundation
import FirebaseAuth

protocol AlbumsViewModelDelegate: AnyObject {
    func reloadTableView()
    func reloadTableViewData()
    func reloadTableViewRows(indexPath: IndexPath)
    func stopAnimation()
    func addLoafMessage(album: TopAlbums)
    func removeLoafMessage(album: TopAlbums)
}

class AlbumsViewModel {
    
    let topAlbumsDS = TopAlbumsAPIDataSource()
    var albums: [TopAlbums] = []
    
    let cellNib = "AlbumsTableViewCell"
    let albumDetailsIdentifier = "toAlbumDetails"
    let albumText = "album"

    weak var delegate: AlbumsViewModelDelegate?
}

//MARK: - Functions
extension AlbumsViewModel {
    
    func addObservers() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        //Gets the indexpath from the button, to determine what album to add to the firestore database
        NotificationCenter.default.addObserver(forName: .AddAlbumID, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                
                let album = self.albums[indexPath.row]
                FirestoreManager.shared.addAlbum(album: album, userID: userID)
                self.delegate?.addLoafMessage(album: album)
            }
        }
        //Gets the indexpath from the button, to determine what album to remove from the firestore database
        NotificationCenter.default.addObserver(forName: .RemoveAlbumID, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                
                let album = self.albums[indexPath.row]
                FirestoreManager.shared.removeAlbum(album: album, userID: userID)
                self.delegate?.removeLoafMessage(album: album)
            }
        }
        //Gets the indexpath from the button, to determine what cell to reload
        NotificationCenter.default.addObserver(forName: .SendIndexPathAlbum, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                self.delegate?.reloadTableViewRows(indexPath: indexPath)
            }
        }
        //Observers to reload the tableview
        NotificationCenter.default.addObserver(forName: .ReloadFromHome, object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {return}
            
            self.delegate?.reloadTableViewData()
        }
        NotificationCenter.default.addObserver(forName: .ReloadFromLiked, object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {return}
            
            self.delegate?.reloadTableViewData()
        }
    }

    func fetchAlbums() {
        topAlbumsDS.fetchTopAlbums(from: .chart, with: "/0/albums", with: ["limit" : 150]) {[weak self] albums, error in
            guard let self = self else {return}
            
            if let albums = albums {
                self.albums = albums
                self.delegate?.reloadTableView()
                self.delegate?.stopAnimation()
                
            } else if let error = error {
                print(error)
                self.delegate?.stopAnimation()
            }
        }
    }
}
