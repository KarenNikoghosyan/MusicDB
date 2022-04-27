//
//  AlbumsViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import UIKit
import ViewAnimator
import Loaf
import SafariServices
import WCLShineButton
import FirebaseAuth

class AlbumsViewController: BaseTableViewController {

    let topAlbumsDS = TopAlbumsAPIDataSource()
    
    @IBOutlet weak var albumsTableView: UITableView!
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Checks the connectivity when loading the screen
        if Connectivity.isConnectedToInternet {
            addObservers()
            fetchAlbums()
            loadActivityIndicator()
        }
        
        albumsTableView.delegate = self
        albumsTableView.dataSource = self
        
        let nib = UINib(nibName: "AlbumsTableViewCell", bundle: .main)
        albumsTableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTabBarSwipe(enabled: true)
        
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
        }
    }
    
    //Link to open a website
    @IBAction func openWebsiteTapped(_ sender: UIButton) {
        openWebsite(albums: baseViewModel.albums, sender: sender)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let dict: [String : Any] = [
            "album" : baseViewModel.albums[indexPath.row],
            "indexPath" : indexPath
        ]
        Loaf.dismiss(sender: self, animated: true)
        performSegue(withIdentifier: "toAlbumDetails", sender: dict)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? AlbumDetailsViewController,
              let data = sender as? Dictionary<String, Any> else {return}
        
        targetController.albumDetailsViewModel.album = data["album"] as? TopAlbums
        targetController.albumDetailsViewModel.indexPath = data["indexPath"] as? IndexPath
    }
    
    func addObservers() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        //Gets the indexpath from the button, to determine what album to add to the firestore database
        NotificationCenter.default.addObserver(forName: .AddAlbumID, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                
                let album = self.baseViewModel.albums[indexPath.row]
                FirestoreManager.shared.addAlbum(album: album, userID: userID)
                self.loafMessageAddedAlbum(album: album)
            }
        }
        //Gets the indexpath from the button, to determine what album to remove from the firestore database
        NotificationCenter.default.addObserver(forName: .RemoveAlbumID, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                
                let album = self.baseViewModel.albums[indexPath.row]
                FirestoreManager.shared.removeAlbum(album: album, userID: userID)
                self.loafMessageRemovedAlbum(album: album)
            }
        }
        //Gets the indexpath from the button, to determine what cell to reload
        NotificationCenter.default.addObserver(forName: .SendIndexPathAlbum, object: nil, queue: .main) {[weak self] notification in
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                self?.albumsTableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        //Observers to reload the tableview
        NotificationCenter.default.addObserver(forName: .ReloadFromHome, object: nil, queue: .main) {[weak self] _ in
            self?.albumsTableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .ReloadFromLiked, object: nil, queue: .main) {[weak self] _ in
            self?.albumsTableView.reloadData()
        }
    }
    
    //Fetches albums
    func fetchAlbums() {
        topAlbumsDS.fetchTopAlbums(from: .chart, with: "/0/albums", with: ["limit" : 150]) {[weak self] albums, error in
            guard let self = self else {return}
            
            if let albums = albums {
                self.baseViewModel.albums = albums
                self.albumsTableView.reloadData()
                
                //Animates the cells
                let cells = self.albumsTableView.visibleCells
                UIView.animate(views: cells, animations: [self.animation])
                
                self.activityIndicatorView.stopAnimating()
            } else if let error = error {
                print(error)
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
}

//Extension for an alert based on the viewcontroller
extension AlbumsViewController {
    func showAlertWithActions(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: "Retry", style: .cancel, handler: {[weak self] action in
            if !Connectivity.isConnectedToInternet {
                self?.showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
            } else {
                self?.fetchAlbums()
                self?.loadActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
}

extension AlbumsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseViewModel.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        accessoryArrow(cell: cell)
        
        if let cell = cell as? AlbumsTableViewCell {
            cell.openWebsiteButton.tag = indexPath.row
            cell.openWebsiteButton.addTarget(self, action: #selector(openWebsiteTapped(_:)), for: .touchUpInside)
            
            let album = baseViewModel.albums[indexPath.row]
            cell.populate(album: album)
            cell.cellConstraints()
        }
        return cell
    }
}
