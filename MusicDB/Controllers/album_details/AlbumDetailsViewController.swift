//
//  AlbumDetailsViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import UIKit
import SDWebImage
import ViewAnimator
import SafariServices
import FirebaseAuth
import WCLShineButton
import Loaf

class AlbumDetailsViewController: BaseTableViewController {
    var album: TopAlbums?
    
    let albumTracksDS = AlbumTrackAPIDataSource()
    
    var isLiked: Bool = false
    
    var indexPath: IndexPath?
    var isHome: Bool? = false
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var numberOfTracks: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var tracksTableView: UITableView!
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        Loaf.dismiss(sender: self, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var likedButton: WCLShineButton!
    @IBAction func likedButtonTapped(_ sender: WCLShineButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            if !isLiked {
                likedButton.isSelected = false
            } else {
                likedButton.isSelected = true
            }
            return
        }
        guard let userID = Auth.auth().currentUser?.uid,
              let album = album else {return}
        
        if !isLiked {
            FirestoreManager.shared.addAlbum(album: album, userID: userID)
            loafMessageAddedAlbum(album: album)

            isLiked = true
        } else {
            FirestoreManager.shared.removeAlbum(album: album, userID: userID)
            loafMessageRemovedAlbum(album: album)

            isLiked = false
        }
        
        guard let isHome = isHome else {return}
        if isHome {
            NotificationCenter.default.post(name: .ReloadFromHome, object: nil, userInfo: nil)
        } else {
            NotificationCenter.default.post(name: .SendIndexPathAlbum, object: nil, userInfo: ["indexPath" : indexPath as Any])
        }
        
    }
    
    func portraitConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewHeightConstraint.constant = 130
        case .iPhoneSE2:
            imageViewHeightConstraint.constant = 200
        case .iPhone8:
            imageViewHeightConstraint.constant = 200
        case .iPhone12ProMax:
            imageViewHeightConstraint.constant = 280
        default:
            imageViewHeightConstraint.constant = 240
        }
    }
    
    func landscapeConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewHeightConstraint.constant = 130
        case .iPhoneSE2:
            imageViewHeightConstraint.constant = 160
        case .iPhone8:
            imageViewHeightConstraint.constant = 160
        case .iPhone12ProMax:
            imageViewHeightConstraint.constant = 180
        default:
            imageViewHeightConstraint.constant = 160
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIDevice.current.orientation.isLandscape {
            landscapeConstraints()
        } else {
            portraitConstraints()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
        } else {
            fetchTracks()
            loadActivityIndicator()
            checkLikedStatus()
        }
        
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        
        let notifactionCenter = NotificationCenter.default
        notifactionCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        guard let album = album else {return}
        self.title = album.title
        guard let str = album.coverBig,
              let url = URL(string: str) else {
            
            setUpImageView()
            albumImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
    
        setUpImageView()
        albumImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        albumImageView.sd_setImage(with: url)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MediaPlayer.shared.stopAudio()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumTracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailsTableViewCell
        
        populateCell(indexPath: indexPath, cell: cell, tableView: tracksTableView)
        
        if let album = album {
            cell.populate(album: album, track: albumTracks[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let oldTrack = albumTracks[indexPath.row]
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
        
        MediaPlayer.shared.stopAudio()
        if let prevIndexPath = prevIndexPath {
            arrIndexPaths.removeAll()
            prevButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            tracksTableView.reloadRows(at: [prevIndexPath], with: .none)
        }
        performSegue(withIdentifier: "toDetails", sender: dict)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? DetailsMusicViewController,
              let data = sender as? Dictionary<String, Any> else {return}
        
        targetController.track = data["track"] as? Track
        targetController.album = data["album"] as? TopAlbums
        targetController.isAlbumDetails = data["isAlbumDetails"] as? Bool
    }
    
    @objc func appMovedToBackground() {
        MediaPlayer.shared.stopAudio()
        prevButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        arrIndexPaths.removeAll()
        if let prevIndexPath = prevIndexPath {
            tracksTableView.reloadRows(at: [prevIndexPath], with: .none)
        }
    }
    
    func setUpImageView() {
        albumImageView.tintColor = .white
        albumImageView.layer.cornerRadius = 15
        albumImageView.layer.masksToBounds = true
    }
    
    func fetchTracks() {
        guard let album = album else {return}

        let start = album.tracklist.index(album.tracklist.startIndex, offsetBy: 28)
        let end = album.tracklist.index(album.tracklist.endIndex, offsetBy: 0)
        let result = album.tracklist[start..<end] 
        let newTrackList = String(result)
        
        albumTracksDS.fetchTracks(from: .album, path: newTrackList, with: ["limit" : 100]) {[weak self] tracks, error in
            guard let self = self else {return}
            
            if let tracks = tracks {
                self.albumTracks = tracks
                self.tracksTableView.reloadData()
                self.numberOfTracks.text = String(tracks.count)
                
                let cells = self.tracksTableView.visibleCells
                UIView.animate(views: cells, animations: [self.animation])
                self.activityIndicatorView.stopAnimating()
                
            } else if let error = error {
                print(error)
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func checkLikedStatus() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            guard let arrIDs: [Int] = snapshot?.get("albumIDs") as? [Int] else {return}
            if arrIDs.contains(self.album?.id ?? 0) {
                self.likedButton.isSelected = true
                self.isLiked = true
            } else {
                self.likedButton.isSelected = false
                self.isLiked = false
            }
        }
    }
    
    override func loadActivityIndicator() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.centerYAnchor.constraint(equalTo: tracksTableView.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: tracksTableView.centerXAnchor)
        ])
        
        activityIndicatorView.startAnimating()
    }
}

extension AlbumDetailsViewController {
    func showAlertWithActions(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: "Retry", style: .cancel, handler: {[weak self] action in
            if !Connectivity.isConnectedToInternet {
                self?.showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
            } else {
                self?.fetchTracks()
                self?.loadActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
}
