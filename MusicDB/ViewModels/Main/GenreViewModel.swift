//
//  GenreViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 29/04/2022.
//

import Foundation
import FirebaseAuth

protocol GenreViewModelDelegate: AnyObject {
    func reloadTableViewData()
    func reloadTableViewRows(indexPath: IndexPath)
    func stopAnimation()
    func animateCells()
    func addLoafMessage(track: Track)
    func removeLoafMessage(track: Track)
}

class GenreViewModel {
    
    let genreDS = GenreAPIDataSource()
    var tracks: [Track] = []

    var titleGenre: String?
    var path: String = ""
    
    let cellNib = "LikedGenreTableViewCell"
    let trackText = "track"
    let isGenreText = "isGenre"
    let toDetailsText = "toDetails"
    
    weak var delegate: GenreViewModelDelegate?
}

//MARK: - Functions
extension GenreViewModel {
    
    func addObservers() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        //Gets the indexpath from the button, to determine what track to add to the firestore database
        NotificationCenter.default.addObserver(forName: .IndexAdd, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                
                let track = self.tracks[indexPath.row]
                FirestoreManager.shared.addTrack(track: track, userID: userID)
                self.delegate?.addLoafMessage(track: track)
            }
        }
        //Gets the indexpath from the button, to determine what track to remove to the firestore database
        NotificationCenter.default.addObserver(forName: .IndexRemove, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                
                let track = self.tracks[indexPath.row]
                FirestoreManager.shared.removeTrack(track: track, userID: userID)
                self.delegate?.removeLoafMessage(track: track)
            }
        }
        //Gets the indexpath from the button, to determine what cell to reload
        NotificationCenter.default.addObserver(forName: .SendIndexPath, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                self.delegate?.reloadTableViewRows(indexPath: indexPath)
            }
        }
    }

    func fetchTracks() {
        genreDS.fetchGenres(from: .chart, with: path, with: ["limit" : 150]) {[weak self] tracks, error in
            guard let self = self else {return}

            if let tracks = tracks {
                
                self.tracks = tracks
                self.delegate?.reloadTableViewData()
                self.delegate?.stopAnimation()
                
                self.delegate?.animateCells()
            } else if let error = error {
                print(error)
                self.delegate?.stopAnimation()
            }
        }
    }
}
