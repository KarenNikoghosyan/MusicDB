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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var likedTableView: UITableView!
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
    
    func portraitConstraints() {
        switch UIDevice().type {
        case .iPod7:
            noLikedLabel.font = UIFont.init(name: "Futura", size: 14)
        case .iPhoneSE2:
            noLikedLabel.font = UIFont.init(name: "Futura", size: 16)
        case .iPhone8:
            noLikedLabel.font = UIFont.init(name: "Futura", size: 16)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        likedTableView.delegate = self
        likedTableView.dataSource = self
        
        setUpSegmentedControl()
        
        //Checks the connectivity when the screen appears
        if Connectivity.isConnectedToInternet {
            if segmentedControl.selectedSegmentIndex == 0 {
                getUserLikedTracks()
                isTrackLoaded = true
            } else {
                getUserLikedAlbums()
                isAlbumLoaded = true
            }

            loadActivityIndicator()
        }

        let tracksNib = UINib(nibName: "LikedTracksTableViewCell", bundle: .main)
        likedTableView.register(tracksNib, forCellReuseIdentifier: "trackCell")
        let albumsNib = UINib(nibName: "LikedAlbumsTableViewCell", bundle: .main)
        likedTableView.register(albumsNib, forCellReuseIdentifier: "albumCell")
        
        setUpObservers()
        
        loadNoLikedLabel()
        portraitConstraints()
        
        likedTableView.separatorColor = UIColor.darkGray

        //Modifing the edit button look(font, color)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        //Returns the number of rows based on the selected segment
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
        let tracksCell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! LikedTracksTableViewCell
        let albumsCell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! LikedAlbumsTableViewCell
        
        //Loads the cells based on the selected segment
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            accessoryArrow(cell: tracksCell)
            let track = tracks[indexPath.row]
            tracksCell.populate(track: track)
            
            tracksCell.cellConstraints()
        case 1:
            accessoryArrow(cell: albumsCell)
            let album = albums[indexPath.row]
            albumsCell.populate(album: album)
            
            albumsCell.cellConstraints()
            
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

            //Deletes a cell based on the selected segment
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                let track = tracks[indexPath.row]
                loafMessageRemoved(track: track)
                
                FirestoreManager.shared.db.collection("users").document(userID).updateData([
                    "trackIDs" : FieldValue.arrayRemove([track.id as Any])
                ]) {[weak self] error in
                    guard let self = self else {return
                        
                    }
                    if let error = error {
                        print("\(error.localizedDescription)")
                    }
                    self.tracks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    if self.tracks.count == 0 {
                        self.noLikedLabel.isHidden = false
                    }
                }
            case 1:
                let album = albums[indexPath.row]
                loafMessageRemovedAlbum(album: album)
                
                FirestoreManager.shared.db.collection("users").document(userID).updateData([
                    "albumIDs" : FieldValue.arrayRemove([album.id as Any])
                ]) {[weak self] error in
                    guard let self = self else {return}
                    
                    if let error = error {
                        print("\(error.localizedDescription)")
                    }
                    self.albums.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    NotificationCenter.default.post(name: .ReloadFromLiked, object: nil, userInfo: nil)
                    
                    if self.albums.count == 0 {
                        self.noLikedLabel.isHidden = false
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
        //Performs segue based on the selected segment
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
        //Checks the segue's identifier and based on that will send us to the correct screen
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
    
    func setUpObservers() {
        //An observer to get the track from other viewcontrollers to add it to the tableview
        NotificationCenter.default.addObserver(forName: .AddTrack, object: nil, queue: .main) {[weak self] notification in
            if let track = notification.userInfo?["track"] as? Track {
                guard let self = self else {return}
                self.tracks.append(track)
                self.likedTableView.reloadData()
                
                if self.tracks.count > 0 && self.tracks.count <= 1 {
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        self.noLikedLabel.isHidden = true
                    }
                }
            }
        }
        //An observer to notify what track to remove from the tableview
        NotificationCenter.default.addObserver(forName: .RemoveTrack, object: nil, queue: .main) {[weak self] notification in
            if let track = notification.userInfo?["track"] as? Track {
                guard let self = self else {return}
                for (index, _) in self.tracks.enumerated() {
                    if self.tracks[index].id == track.id{
                        self.tracks.remove(at: index)
                        self.likedTableView.reloadData()

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
        //An observer to get the album from other viewcontrollers to add it to the tableview
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
        //An observer to notify what album to remove from the tableview
        NotificationCenter.default.addObserver(forName: .RemoveAlbumID, object: nil, queue: .main) {[weak self] notification in
            if let album = notification.userInfo?["album"] as? TopAlbums {
                guard let self = self else {return}

                for (index, _) in self.albums.enumerated() {
                    if self.albums[index].id == album.id{
                        self.albums.remove(at: index)
                        self.likedTableView.reloadData()
                        
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
    }
    
    //Sets up the segmented control
    func setUpSegmentedControl() {
        let tintColor = UIColor.white
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: tintColor], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.black], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentTapped(_:)), for: .valueChanged)
    }
    
    //When the segmented control gets tapped it will load the correct data based on the selected index
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if isTrackLoaded == true {
                likedTableView.reloadData()
                reloadTableViewWithAnimation()
                
                if tracks.count > 0 {
                    noLikedLabel.isHidden = true
                } else {
                    noLikedLabel.isHidden = false
                }
            } else {
                noLikedLabel.isHidden = true
                loadActivityIndicator()

                likedTableView.reloadData()
                getUserLikedTracks()
                isTrackLoaded = true
            }
        case 1:
            if isAlbumLoaded == true {
                likedTableView.reloadData()
                reloadTableViewWithAnimation()
                if albums.count > 0 {
                    noLikedLabel.isHidden = true
                } else {
                    noLikedLabel.isHidden = false
                }
            } else {
                noLikedLabel.isHidden = true
                loadActivityIndicator()
                
                likedTableView.reloadData()
                getUserLikedAlbums()
                isAlbumLoaded = true
            }
            
        default:
            break
        }
    }
    
    //Gets the liked tracks ids from the firestore database
    func getUserLikedTracks() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            self.tracksIDs = snapshot?.get("trackIDs") as? [Int] ?? nil
            self.numOfCallsTrack = self.tracksIDs?.count ?? 0
            self.fetchTracks()
        }
    }
    
    //if the tracksIDs is empty it won't fetch the tracks
    func fetchTracks() {
        if tracksIDs?.count == 0 {
            if segmentedControl.selectedSegmentIndex == 0 {
                noLikedLabel.isHidden = false
            }
            activityIndicatorView.stopAnimating()
            return
        }
        
        //Recursive call, will fetch tracks one by one, when ready it will load the tableview with the correct data
        singleTrackDS.fetchTracks(from: .track, id: tracksIDs?[trackIndex]) {[weak self] track, error in
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
    
    //Gets the liked albums ids from the firestore database
    func getUserLikedAlbums() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            self.albumIDs = snapshot?.get("albumIDs") as? [Int] ?? nil
            self.numOfCallsAlbum = self.albumIDs?.count ?? 0
            self.fetchAlbums()
        }
    }
    
    //if the albumsIDs is empty it won't fetch the albums
    func fetchAlbums() {
        if albumIDs?.count == 0 {
            if segmentedControl.selectedSegmentIndex == 1 {
                noLikedLabel.isHidden = false
            }
            activityIndicatorView.stopAnimating()
            return
        }
        
        //Recursive call, will fetch albums one by one, when ready it will load the tableview with the correct data
        singleAlbumDS.fetchAlbums(from: .album, id: albumIDs?[albumIndex]) {[weak self] album, error in
            if let album = album {
                guard let self = self else {return}
                
                self.albumIndex += 1
                self.albums.append(album)
                self.numOfCallsAlbum -= 1
                if self.numOfCallsAlbum > 0 {
                    self.fetchAlbums()
                } else {
                    self.albumIndex = 0
                    
                    self.likedTableView.reloadData()
                    self.reloadTableViewWithAnimation()
                }
                
            } else if let error = error {
                print(error)
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    //Tableview reload animation
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
}

//Extension for an alert based on the viewcontroller
extension LikedMusicViewController {
    func showAlertWithActions(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: "Retry", style: .cancel, handler: {[weak self] action in
            guard let self = self else {return}
            
            if !Connectivity.isConnectedToInternet {
                self.showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
            } else {
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    self.getUserLikedTracks()
                    self.isTrackLoaded = true
                } else {
                    self.getUserLikedAlbums()
                    self.isAlbumLoaded = true
                }
                self.loadActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
}
