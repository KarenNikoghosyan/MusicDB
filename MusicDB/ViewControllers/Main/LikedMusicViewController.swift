//
//  LikedMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 10/07/2021.
//

import UIKit
import Loaf

class LikedMusicViewController: BaseViewController {
    
    private let likedMusicViewModel = LikedMusicViewModel()
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var likedTableView: UITableView!
    
    let noLikedLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegatesAndDataSources()
        setUpSegmentedControl()
        
        checkConnectivity()
        
        setupNibs()
        likedMusicViewModel.setUpObservers()
        setupNoLikedLabel()
        setupPortraitConstraints()
        
        likedTableView.separatorColor = UIColor.darkGray
        setupNavigationItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTabBarSwipe(enabled: false)
        
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
        }
    }
    
    @IBAction private func logOutTapped(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
    
    @IBAction private func openWebsiteTapped(_ sender: UIButton) {
        openWebsite(albums: likedMusicViewModel.likedAlbums, sender: sender)
    }
}

//MARK: - Functions
extension LikedMusicViewController {
    
    private func setupDelegatesAndDataSources() {
        likedMusicViewModel.likedMusicDelegate = self
        likedTableView.delegate = self
        likedTableView.dataSource = self
    }
    
    //Sets up the segmented control
    private func setUpSegmentedControl() {
        let tintColor = UIColor.white
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: tintColor], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.black], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentTapped(_:)), for: .valueChanged)
    }
    
    //When the segmented control gets tapped it will load the correct data based on the selected index
    @IBAction private func segmentTapped(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if likedMusicViewModel.isTrackLoaded == true {
                likedTableView.reloadData()
                reloadTableViewWithAnimation()
                
                if likedMusicViewModel.likedTracks.count > 0 {
                    noLikedLabel.isHidden = true
                } else {
                    noLikedLabel.isHidden = false
                }
            } else {
                noLikedLabel.isHidden = true
                setupActivityIndicator()
                
                likedTableView.reloadData()
                likedMusicViewModel.getUserLikedTracks()
                likedMusicViewModel.isTrackLoaded = true
            }
        case 1:
            if likedMusicViewModel.isAlbumLoaded == true {
                likedTableView.reloadData()
                reloadTableViewWithAnimation()
                if likedMusicViewModel.likedAlbums.count > 0 {
                    noLikedLabel.isHidden = true
                } else {
                    noLikedLabel.isHidden = false
                }
            } else {
                noLikedLabel.isHidden = true
                setupActivityIndicator()
                
                likedTableView.reloadData()
                likedMusicViewModel.getUserLikedAlbums()
                likedMusicViewModel.isAlbumLoaded = true
            }
        default:
            break
        }
    }
    
    //Checks the connectivity when the screen appears
    private func checkConnectivity() {
        if Connectivity.isConnectedToInternet {
            if segmentedControl.selectedSegmentIndex == 0 {
                likedMusicViewModel.getUserLikedTracks()
                likedMusicViewModel.isTrackLoaded = true
            } else {
                likedMusicViewModel.getUserLikedAlbums()
                likedMusicViewModel.isAlbumLoaded = true
            }
            
            setupActivityIndicator()
        }
    }
    
    private func setupNibs() {
        let tracksNib = UINib(nibName: likedMusicViewModel.tracksNibName, bundle: .main)
        likedTableView.register(tracksNib, forCellReuseIdentifier: likedMusicViewModel.trackCellReuseIdentifier)
        let albumsNib = UINib(nibName: likedMusicViewModel.albumsNibName, bundle: .main)
        likedTableView.register(albumsNib, forCellReuseIdentifier: likedMusicViewModel.albumCellReuseIdentifier)
    }
    
    //Modifing the edit button look(font, color)
    private func setupNavigationItem() {
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Constants.futuraBold, size: 16) as Any], for: .normal)
    }
    
    //Extension for an alert based on the LikedMusicViewController
    private func showAlertWithActions(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: "Retry", style: .cancel, handler: {[weak self] action in
            guard let self = self else {return}
            
            if !Connectivity.isConnectedToInternet {
                self.showAlertWithActions(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            } else {
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    self.likedMusicViewModel.getUserLikedTracks()
                    self.likedMusicViewModel.isTrackLoaded = true
                } else {
                    self.likedMusicViewModel.getUserLikedAlbums()
                    self.likedMusicViewModel.isAlbumLoaded = true
                }
                self.setupActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
    
    private func setupNoLikedLabel() {
        noLikedLabel.numberOfLines = 0
        noLikedLabel.textAlignment = .center
        noLikedLabel.text = likedMusicViewModel.noLikedTracksAndAlbumsText
        noLikedLabel.font = UIFont.init(name: Constants.futura, size: 18)
        noLikedLabel.textColor = .white
        
        view.addSubview(noLikedLabel)
        noLikedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noLikedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noLikedLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noLikedLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        noLikedLabel.isHidden = true
    }
    
    private func setupPortraitConstraints() {
        switch UIDevice().type {
        case .iPod7:
            noLikedLabel.font = UIFont.init(name: Constants.futura, size: 14)
        case .iPhoneSE2:
            noLikedLabel.font = UIFont.init(name: Constants.futura, size: 16)
        case .iPhone8:
            noLikedLabel.font = UIFont.init(name: Constants.futura, size: 16)
        default:
            break
        }
    }
}

//MARK: - Functions
extension LikedMusicViewController {
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        let status = navigationItem.leftBarButtonItem?.title
        
        if status == likedMusicViewModel.editText {
            likedTableView.setEditing(true, animated: true)
            navigationItem.leftBarButtonItem?.title = likedMusicViewModel.doneText
        } else {
            likedTableView.setEditing(false, animated: true)
            navigationItem.leftBarButtonItem?.title = likedMusicViewModel.editText
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Checks the segue's identifier and based on that will send us to the correct screen
        if segue.identifier == likedMusicViewModel.toDetailsText {
            guard let dest = segue.destination as? UINavigationController,
                  let targetController = dest.topViewController as? DetailsMusicViewController,
                  let track = sender as? Track else {return}
            
            targetController.detailsMusicViewModel.track = track
        } else if segue.identifier == likedMusicViewModel.toAlbumDetailsText {
            guard let dest = segue.destination as? UINavigationController,
                  let targetController = dest.topViewController as? AlbumDetailsViewController,
                  let album = sender as? TopAlbums else {return}
            
            targetController.albumDetailsViewModel.album = album
        }
    }
}

//MARK: - UITableView Functions
extension LikedMusicViewController {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if !Connectivity.isConnectedToInternet {
                showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
                return
            }
            //Deletes a cell based on the selected segment
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                loafMessageRemoved(track: likedMusicViewModel.likedTracks[indexPath.row])
                
                likedMusicViewModel.removeSingleTrack(track: likedMusicViewModel.likedTracks[indexPath.row], tableView: tableView, indexPath: indexPath)
            case 1:
                loafMessageRemovedAlbum(album: likedMusicViewModel.likedAlbums[indexPath.row])
                
                likedMusicViewModel.removeSingleAlbum(album: likedMusicViewModel.likedAlbums[indexPath.row], tableView: tableView, indexPath: indexPath)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        //Performs segue based on the selected segment
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            Loaf.dismiss(sender: self, animated: true)
            performSegue(withIdentifier: likedMusicViewModel.toDetailsText, sender: likedMusicViewModel.likedTracks[indexPath.row])
        case 1:
            Loaf.dismiss(sender: self, animated: true)
            performSegue(withIdentifier: likedMusicViewModel.toAlbumDetailsText, sender: likedMusicViewModel.likedAlbums[indexPath.row])
        default:
            break
        }
    }
}

//MARK: - DataSources
extension LikedMusicViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        //Returns the number of rows based on the selected segment
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            numberOfRows = likedMusicViewModel.likedTracks.count
        case 1:
            numberOfRows = likedMusicViewModel.likedAlbums.count
        default:
            break
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tracksCell = tableView.dequeueReusableCell(withIdentifier: likedMusicViewModel.trackCellReuseIdentifier, for: indexPath) as! LikedTracksTableViewCell
        let albumsCell = tableView.dequeueReusableCell(withIdentifier: likedMusicViewModel.albumCellReuseIdentifier, for: indexPath) as! LikedAlbumsTableViewCell
        
        //Loads the cells based on the selected segment
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            accessoryArrow(cell: tracksCell)
            tracksCell.populate(track: likedMusicViewModel.likedTracks[indexPath.row])
            
            tracksCell.setupCellConstraints()
        case 1:
            accessoryArrow(cell: albumsCell)
            albumsCell.populate(album: likedMusicViewModel.likedAlbums[indexPath.row])
            
            albumsCell.setupCellConstraints()
            
            albumsCell.openWebsiteButton.tag = indexPath.row
            albumsCell.openWebsiteButton.addTarget(self, action: #selector(openWebsiteTapped(_:)), for: .touchUpInside)
            return albumsCell
        default:
            break
        }
        return tracksCell
    }
}

//MARK: - Delegates
extension LikedMusicViewController: LikedMusicViewModelDelegate {
    
    func isSelectedSegment(index: Int, isHidden: Bool) {
        if self.segmentedControl.selectedSegmentIndex == index {
            self.noLikedLabel.isHidden = isHidden
        }
    }
    
    func isLikedEmpty(isHidden: Bool) {
        self.noLikedLabel.isHidden = isHidden
    }
    
    //if the tracksIDs is empty it won't fetch the albums
    func fetchLikedTracks() {
        if likedMusicViewModel.tracksIDs?.count == 0 {
            if segmentedControl.selectedSegmentIndex == 0 {
                noLikedLabel.isHidden = false
            }
            activityIndicatorView.stopAnimating()
            return
        }
        
        likedMusicViewModel.fetchSingleTrackDS()
    }
    
    //if the albumsIDs is empty it won't fetch the albums
    func fetchLikedAlbums() {
        if likedMusicViewModel.albumIDs?.count == 0 {
            if segmentedControl.selectedSegmentIndex == 1 {
                noLikedLabel.isHidden = false
            }
            activityIndicatorView.stopAnimating()
            return
        }
        
        likedMusicViewModel.fetchSingleAlbumDS()
    }
    
    func reloadTableView() {
        likedTableView.reloadData()
    }
    
    func reloadTableViewWithAnimation() {
        let cells = self.likedTableView.visibleCells
        UIView.animate(views: cells, animations: [self.animation])
        self.activityIndicatorView.stopAnimating()
    }
    
    func deleteRowsFromTableView(tableView: UITableView, indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func stopActivityIndicatorAnimation() {
        activityIndicatorView.stopAnimating()
    }
}
