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

class AlbumsViewController: BaseTableViewController {
    
    let albumsViewModel = AlbumsViewModel()
    
    @IBOutlet private weak var albumsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Checks the connectivity when loading the screen
        if Connectivity.isConnectedToInternet {
            albumsViewModel.addObservers()
            albumsViewModel.fetchAlbums()
            loadActivityIndicator()
        }
        
        setupDelegates()
        setupNib()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTabBarSwipe(enabled: true)
        
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
        }
    }
    
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
    
    //Link to open a website
    @IBAction func openWebsiteTapped(_ sender: UIButton) {
        openWebsite(albums: albumsViewModel.albums, sender: sender)
    }
}

//MARK: Functions
extension AlbumsViewController {
    
    private func setupDelegates() {
        albumsViewModel.delegate = self
        albumsTableView.delegate = self
        albumsTableView.dataSource = self
    }
    
    private func setupNib() {
        let nib = UINib(nibName: albumsViewModel.cellNib, bundle: .main)
        albumsTableView.register(nib, forCellReuseIdentifier: Constants.cellIdentifier)
    }
    
    private func showAlertWithActions(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: albumsViewModel.retryText, style: .cancel, handler: {[weak self] action in
            guard let self = self else {return}
            
            if !Connectivity.isConnectedToInternet {
                self.showAlertWithActions(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            } else {
                self.albumsViewModel.fetchAlbums()
                self.loadActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        let dict: [String : Any] = [
            albumsViewModel.albumText : albumsViewModel.albums[indexPath.row],
            albumsViewModel.indexPathText : indexPath
        ]
        Loaf.dismiss(sender: self, animated: true)
        performSegue(withIdentifier: albumsViewModel.albumDetailsIdentifier, sender: dict)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? AlbumDetailsViewController,
              let data = sender as? Dictionary<String, Any> else {return}
        
        targetController.albumDetailsViewModel.album = data[albumsViewModel.albumText] as? TopAlbums
        targetController.albumDetailsViewModel.indexPath = data[albumsViewModel.indexPathText] as? IndexPath
    }
}

extension AlbumsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsViewModel.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        
        accessoryArrow(cell: cell)
        
        if let cell = cell as? AlbumsTableViewCell {
            cell.openWebsiteButton.tag = indexPath.row
            cell.openWebsiteButton.addTarget(self, action: #selector(openWebsiteTapped(_:)), for: .touchUpInside)
            
            let album = albumsViewModel.albums[indexPath.row]
            cell.populate(album: album)
            cell.cellConstraints()
        }
        return cell
    }
}

extension AlbumsViewController: AlbumsViewModelDelegate {
    func reloadTableView() {
        self.albumsTableView.reloadData()
        
        //Animates the cells
        let cells = self.albumsTableView.visibleCells
        UIView.animate(views: cells, animations: [self.animation])
    }
    
    func reloadTableViewData() {
        self.albumsTableView.reloadData()
    }
    
    func reloadTableViewRows(indexPath: IndexPath) {
        self.albumsTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func stopAnimation() {
        self.activityIndicatorView.stopAnimating()
    }
    
    func addLoafMessage(album: TopAlbums) {
        self.loafMessageAddedAlbum(album: album)
    }
    
    func removeLoafMessage(album: TopAlbums) {
        self.loafMessageRemovedAlbum(album: album)
    }
}
