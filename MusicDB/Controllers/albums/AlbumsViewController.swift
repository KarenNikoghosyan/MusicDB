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
    var albums: [TopAlbums] = []
    let ds = TopAlbumsAPIDataSource()

    @IBOutlet weak var albumsTableView: UITableView!
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        accessoryArrow(cell: cell)
        
        if let cell = cell as? AlbumsTableViewCell {
            cell.openWebsiteButton.tag = indexPath.row
            cell.openWebsiteButton.addTarget(self, action: #selector(openWebsiteTapped(_:)), for: .touchUpInside)
            
            let album = albums[indexPath.row]
            cell.populate(album: album)
        }
        return cell
    }
    
    @IBAction func openWebsiteTapped(_ sender: UIButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let selectedIndexPath = IndexPath.init(row: sender.tag, section: 0)
        let album = self.albums[selectedIndexPath.row]
        
        guard let url = URL(string: "\(album.link)") else {return}
        let sfVC = SFSafariViewController(url: url)
        Loaf.dismiss(sender: self, animated: true)
        self.present(sfVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let dict: [String : Any] = [
            "album" : albums[indexPath.row],
            "indexPath" : indexPath
        ]
        Loaf.dismiss(sender: self, animated: true)
        performSegue(withIdentifier: "toAlbumDetails", sender: dict)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? AlbumDetailsViewController,
              let data = sender as? Dictionary<String, Any> else {return}
        
        targetController.album = data["album"] as? TopAlbums
    }
    
    func addObservers() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        NotificationCenter.default.addObserver(forName: .AddAlbumID, object: nil, queue: .main) {[weak self] notification in
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                guard let album = self?.albums[indexPath.row] else {return}
                
                self?.addAlbum(album: album, userID: userID)
                self?.loafMessageAddedAlbum(album: album)
            }
        }
        NotificationCenter.default.addObserver(forName: .RemoveAlbumID, object: nil, queue: .main) {[weak self] notification in
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                guard let album = self?.albums[indexPath.row] else {return}
                
                self?.removeAlbum(album: album, userID: userID)
                self?.loafMessageRemovedAlbum(album: album)
            }
        }
    }
    
    func fetchAlbums() {
        ds.fetchTopAlbums(from: .chart, with: "/0/albums", with: ["limit" : 150]) {[weak self] albums, error in
            guard let self = self else {return}
            
            if let albums = albums {
                self.albums = albums
                self.albumsTableView.reloadData()
                
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
