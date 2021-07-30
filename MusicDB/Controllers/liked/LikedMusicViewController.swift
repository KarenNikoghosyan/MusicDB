//
//  LikedMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 10/07/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Loaf

class LikedMusicViewController: BaseTableViewController {
    
    let noLikedLabel = UILabel()
    
    let dsTrack = SingleTrackAPIDataSource()
    var tracks: [Track] = []
    var tracksIDs: [Int]?
    var numOfCallsTrack: Int = 0
    var trackIndex: Int = 0
    
    let dsAlbum = SingleAlbumAPIDataSource()
    var albums: [TopAlbums] = []
    var albumIDs: [Int]?
    var numOfCallsAlbum: Int = 0
    var albumIndex: Int = 0
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var likedTableView: UITableView!
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likedTableView.delegate = self
        likedTableView.dataSource = self
        
        setUpSegmentedControl()
        
        if Connectivity.isConnectedToInternet {
            getUserLikedTracks()
            getUserLikedAlbums()
            loadActivityIndicator()
        }

        let tracksNib = UINib(nibName: "LikedGenreTableViewCell", bundle: .main)
        likedTableView.register(tracksNib, forCellReuseIdentifier: "trackCell")
        let albumsNib = UINib(nibName: "AlbumsTableViewCell", bundle: .main)
        likedTableView.register(albumsNib, forCellReuseIdentifier: "albumCell")
        
        setUpObservers()
        loadNoLikedLabel()
        
        likedTableView.separatorColor = UIColor.darkGray

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Futura-Bold", size: 16) as Any], for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTabBarSwipe(enabled: false)
        
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
        }
    }
    
    func setUpObservers() {
        NotificationCenter.default.addObserver(forName: .AddTrack, object: nil, queue: .main) {[weak self] notification in
            if let track = notification.userInfo?["track"] as? Track {
                guard let self = self else {return}
                print("Add")
                self.tracks.append(track)
                self.likedTableView.reloadData()
                
                if self.tracks.count > 0 && self.tracks.count <= 1 {
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        self.noLikedLabel.isHidden = true
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .RemoveTrack, object: nil, queue: .main) {[weak self] notification in
            if let track = notification.userInfo?["track"] as? Track {
                guard let self = self else {return}
                print("Test1")
                for (index, _) in self.tracks.enumerated() {
                    if self.tracks[index].id == track.id{
                        self.tracks.remove(at: index)
                        self.likedTableView.reloadData()
                        print("Test2")
                        if self.tracks.count == 0 {
                            if self.segmentedControl.selectedSegmentIndex == 0 {
                                self.noLikedLabel.isHidden = false
                            }
                        }
                        return
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .AddAlbumID, object: nil, queue: .main) {[weak self] notification in
            if let album = notification.userInfo?["album"] as? TopAlbums {
                guard let self = self else {return}
                
                self.albums.append(album)
                self.likedTableView.reloadData()
                
                if self.albums.count > 0 && self.albums.count <= 1 {
                    if self.segmentedControl.selectedSegmentIndex == 1 {
                        self.noLikedLabel.isHidden = true
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .RemoveAlbumID, object: nil, queue: .main) {[weak self] notification in
            if let album = notification.userInfo?["album"] as? TopAlbums {
                guard let self = self else {return}
                print("Test4")
                for (index, _) in self.albums.enumerated() {
                    if self.albums[index].id == album.id{
                        self.albums.remove(at: index)
                        self.likedTableView.reloadData()
                        print("Test4")
                        if self.albums.count == 0 {
                            if self.segmentedControl.selectedSegmentIndex == 1 {
                                self.noLikedLabel.isHidden = false
                            }
                        }
                        return
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .IndexRemove, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                let track = self.tracks[indexPath.row]
                guard let userID = Auth.auth().currentUser?.uid else {return}

                FirestoreManager.shared.db.collection("users").document(userID).updateData([
                    "trackIDs" : FieldValue.arrayRemove([track.id as Any])
                ]) {[weak self] error in
                    guard let self = self else {return}
                    
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.tracks.remove(at: indexPath.row)
                            self.likedTableView.deleteRows(at: [indexPath], with: .automatic)
                            self.loafMessageRemoved(track: track)
                            
                            if self.tracks.count == 0 {
                                if self.segmentedControl.selectedSegmentIndex == 0 {
                                    self.noLikedLabel.isHidden = false
                                }
                            }
                        }
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .RemoveAlbumID, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                let album = self.albums[indexPath.row]
                guard let userID = Auth.auth().currentUser?.uid else {return}

                FirestoreManager.shared.db.collection("users").document(userID).updateData([
                    "albumIDs" : FieldValue.arrayRemove([album.id as Any])
                ]) {[weak self] error in
                    guard let self = self else {return}
                    
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.albums.remove(at: indexPath.row)
                            self.likedTableView.deleteRows(at: [indexPath], with: .automatic)
                            self.loafMessageRemovedAlbum(album: album)
                            
                            if self.albums.count == 0 {
                                if self.segmentedControl.selectedSegmentIndex == 1 {
                                    self.noLikedLabel.isHidden = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setUpSegmentedControl() {
        let tintColor = UIColor.white
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: tintColor], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.black], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentTapped(_:)), for: .valueChanged)
    }
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            likedTableView.reloadData()
            reloadTableViewWithAnimation()
            if tracks.count > 0 {
                noLikedLabel.isHidden = true
            } else {
                noLikedLabel.isHidden = false
            }
        case 1:
            likedTableView.reloadData()
            reloadTableViewWithAnimation()
            if albums.count > 0 {
                noLikedLabel.isHidden = true
            } else {
                noLikedLabel.isHidden = false
            }
        default:
            break
        }
    }
    
    func getUserLikedTracks() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            self.tracksIDs = snapshot?.get("trackIDs") as? [Int] ?? nil
            self.numOfCallsTrack = self.tracksIDs?.count ?? 0
            self.fetchTracks()
        }
    }
    
    func fetchTracks() {
        if tracksIDs?.count == 0 {
            if segmentedControl.selectedSegmentIndex == 0 {
                noLikedLabel.isHidden = false
            }
            activityIndicatorView.stopAnimating()
            return
        }
        
        dsTrack.fetchTracks(from: .track, id: tracksIDs?[trackIndex]) {[weak self] track, error in
            if let track = track {
                guard let self = self else {return}
                
                self.trackIndex += 1
                self.tracks.append(track)
                
                self.numOfCallsTrack -= 1
                if self.numOfCallsTrack > 0 {
                    self.fetchTracks()
                } else {
                    self.trackIndex = 0
                    self.likedTableView.reloadData()
                    
                    self.reloadTableViewWithAnimation()
                }
                
            } else if let error = error {
                print(error)
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func getUserLikedAlbums() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            self.albumIDs = snapshot?.get("albumIDs") as? [Int] ?? nil
            self.numOfCallsAlbum = self.albumIDs?.count ?? 0
            self.fetchAlbums()
        }
    }
    
    func fetchAlbums() {
        if albumIDs?.count == 0 {
            if segmentedControl.selectedSegmentIndex == 1 {
                noLikedLabel.isHidden = false
            }
            activityIndicatorView.stopAnimating()
            return
        }
        
        dsAlbum.fetchAlbums(from: .album, id: albumIDs?[albumIndex]) {[weak self] album, error in
            if let album = album {
                guard let self = self else {return}
                
                self.albumIndex += 1
                self.albums.append(album)
                self.numOfCallsAlbum -= 1
                if self.numOfCallsAlbum > 0 {
                    self.fetchAlbums()
                } else {
                    self.albumIndex = 0
                    //self.likedTableView.reloadData()
                    
                    //self.reloadTableViewWithAnimation()
                }
                
            } else if let error = error {
                print(error)
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func reloadTableViewWithAnimation() {
        let cells = self.likedTableView.visibleCells
        UIView.animate(views: cells, animations: [self.animation])
        self.activityIndicatorView.stopAnimating()
    }
    
    func loadNoLikedLabel() {
        noLikedLabel.text = "No liked tracks/albums, start adding some."
        noLikedLabel.font = UIFont.init(name: "Futura", size: 18)
        noLikedLabel.textColor = .white
        
        view.addSubview(noLikedLabel)
        noLikedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noLikedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noLikedLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noLikedLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        noLikedLabel.isHidden = true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            numberOfRows = tracks.count
        case 1:
            numberOfRows = albums.count
        default:
            break
        }
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tracksCell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! LikedGenreTableViewCell
        let albumsCell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! AlbumsTableViewCell
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            accessoryArrow(cell: tracksCell)
            let track = tracks[indexPath.row]
            tracksCell.populate(track: track)
        case 1:
            accessoryArrow(cell: albumsCell)
            let album = albums[indexPath.row]
            albumsCell.populate(album: album)
            
            albumsCell.openWebsiteButton.tag = indexPath.row
            albumsCell.openWebsiteButton.addTarget(self, action: #selector(openWebsiteTapped(_:)), for: .touchUpInside)
            return albumsCell
        default:
            break
        }
        return tracksCell
    }
    
    @IBAction func openWebsiteTapped(_ sender: UIButton) {
        openWebsite(albums: albums, sender: sender)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        let status = navigationItem.leftBarButtonItem?.title
        
        if status == "Edit" {
            likedTableView.setEditing(true, animated: true)
            navigationItem.leftBarButtonItem?.title = "Done"
        } else {
            likedTableView.setEditing(false, animated: true)
            navigationItem.leftBarButtonItem?.title = "Edit"
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if !Connectivity.isConnectedToInternet {
                showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
                return
            }
            guard let userID = Auth.auth().currentUser?.uid else {return}

            switch segmentedControl.selectedSegmentIndex {
            case 0:
                let track = tracks[indexPath.row]
                loafMessageRemoved(track: track)
                
                FirestoreManager.shared.db.collection("users").document(userID).updateData([
                    "trackIDs" : FieldValue.arrayRemove([track.id as Any])
                ]) {[weak self] error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    }
                    self?.tracks.remove(at: indexPath.item)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    if self?.tracks.count == 0 {
                        self?.noLikedLabel.isHidden = false
                    }
                }
            case 1:
                let album = albums[indexPath.row]
                loafMessageRemovedAlbum(album: album)
                
                FirestoreManager.shared.db.collection("users").document(userID).updateData([
                    "albumIDs" : FieldValue.arrayRemove([album.id as Any])
                ]) {[weak self] error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    }
                    self?.albums.remove(at: indexPath.item)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    if self?.albums.count == 0 {
                        self?.noLikedLabel.isHidden = false
                    }
                }
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            Loaf.dismiss(sender: self, animated: true)
            performSegue(withIdentifier: "toDetails", sender: tracks[indexPath.row])
        case 1:
            Loaf.dismiss(sender: self, animated: true)
            performSegue(withIdentifier: "toAlbumDetails", sender: albums[indexPath.row])
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails" {
            guard let dest = segue.destination as? UINavigationController,
                  let targetController = dest.topViewController as? DetailsMusicViewController,
                  let track = sender as? Track else {return}
            targetController.track = track
        } else if segue.identifier == "toAlbumDetails" {
            guard let dest = segue.destination as? UINavigationController,
                  let targetController = dest.topViewController as? AlbumDetailsViewController,
                  let album = sender as? TopAlbums else {return}
            targetController.album = album
        }
    }
}

extension LikedMusicViewController {
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
