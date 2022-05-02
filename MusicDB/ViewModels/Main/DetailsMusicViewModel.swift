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
    func reloadTableView()
    func animateTableViewCells()
    func stopAnimating()
    func isNoTracksLabelHidden(isHidden: Bool)
    func assignPrevButton(_ sender: UIButton)
    func changeButtonImageAndReloadRows(prevIndexPath: IndexPath)
    func changePreviewButtonState()
    func isLikedButtonSelected(isSelected: Bool)
    func stopAudioPlaying()
    func showAlertPopup()
    func loafMessageWasAdded(track: Track)
    func loafMessageWasRemoved(track: Track)
}

class DetailsMusicViewModel {
    
    let ds = TrackAPIDataSource()
    
    var tracks: [Track] = []
    var track: Track?
    var album: TopAlbums?
    
    var isLiked: Bool = false
    
    var indexPath: IndexPath?
    var isGenre: Bool? = false
    var isAlbumDetails: Bool? = false
    
    var prevIndexPath: IndexPath?
    var arrIndexPaths: [IndexPath] = []
    
    weak var delegate: DetailsMusicViewModelDelegate?
    
    let storyboardID = "Main"
    let storyboardRestorationID = "detailsScreen"
    
    let playCircleImage = "play.circle"
    let pauseCircleImage = "pause.circle"
    let noTracksFoundText = "No Tracks Found"
    let cantLoadLinkText = "Can't load the link"
}

//MARK: - Functions
extension DetailsMusicViewModel {
    
    func setupBaseObservers() {
        NotificationCenter.default.addObserver(forName: .ResetPlayButton, object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {return}
            
            self.resetPlayButton()
        }
        
        //Adds an observer to observe if the app moved to the backgroud
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        //Stops button animation
        NotificationCenter.default.addObserver(forName: .StopButtonAnimation, object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {return}
            
            self.delegate?.changePreviewButtonState()
        }
    }
    
    //Fetches the tracks
    func fetchTracks() {
        ds.fetchTracks(from: .artist, id: track?.artist.id, path: "/top", with: ["limit":200]) {[weak self] tracks, error in
            guard let self = self else {return}

            if let tracks = tracks {
                
                self.tracks = tracks
                self.delegate?.reloadTableView()
                
                self.delegate?.animateTableViewCells()
                self.delegate?.stopAnimating()
                
                if tracks.count <= 0 {
                    self.delegate?.isNoTracksLabelHidden(isHidden: false)
                } else {
                    self.delegate?.isNoTracksLabelHidden(isHidden: true)
                }
                
            } else if let error = error {
                print(error)
                self.delegate?.stopAnimating()
            }
        }
    }
    
    func getMinutesAndSeconds() -> (Int, Int) {
        return ((track?.duration ?? 0) / 60, (track?.duration ?? 0) % 60)
    }
    
    //Checks the liked status of a track(liked/unliked)
    func checkLikedStatus() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            //Gets the tracksIDs from the firestore database
            guard let arrIDs: [Int] = snapshot?.get("trackIDs") as? [Int] else {return}
            if arrIDs.contains(self.track?.id ?? 0) {
                self.delegate?.isLikedButtonSelected(isSelected: true)
                self.isLiked = true
            } else {
                self.delegate?.isLikedButtonSelected(isSelected: false)
                self.isLiked = false
            }
        }
    }
    
    func toggleLikedButton() {
        guard let track = track else {return}
        
        //Checks the connectivity status
        if !Connectivity.isConnectedToInternet {
            delegate?.showAlertPopup()
            if !isLiked {
                delegate?.isLikedButtonSelected(isSelected: false)
            } else {
                delegate?.isLikedButtonSelected(isSelected: true)
            }
            return
        }
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        //Will add/remove tracks based on their liked status
        if !isLiked {
            FirestoreManager.shared.addTrack(track: track, userID: userID)
            delegate?.loafMessageWasAdded(track: track)

            isLiked = true
        } else {
            FirestoreManager.shared.removeTrack(track: track, userID: userID)
            delegate?.loafMessageWasRemoved(track: track)

            isLiked = false
        }
        //Checks if we came from the genre screen and will send an indexpath to change the cell's liked status.
        guard let isGenre = isGenre else {return}
        if isGenre {
            NotificationCenter.default.post(name: .SendIndexPath, object: nil, userInfo: ["indexPath" : indexPath as Any])
        }
    }
    
    //Stops the audio if the app moved to background
    @objc func appMovedToBackground() {
        delegate?.stopAudioPlaying()
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
