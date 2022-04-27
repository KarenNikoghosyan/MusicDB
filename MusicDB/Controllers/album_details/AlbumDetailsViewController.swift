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
import WCLShineButton
import Loaf

class AlbumDetailsViewController: BaseTableViewController {
    
    let albumDetailsViewModel = AlbumDetailsViewModel()
    
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var numberOfTracks: UILabel!
    @IBOutlet private weak var albumImageView: UIImageView!
    @IBOutlet private weak var tracksTableView: UITableView!
    @IBOutlet private weak var likedButton: WCLShineButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Checks the connectivity on launch
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
        } else {
            albumDetailsViewModel.fetchTracks()
            loadActivityIndicator()
            albumDetailsViewModel.checkLikedStatus()
        }
        
        setupDelegates()
        loadImage()
        setupObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if navigationController?.isBeingDismissed ?? false {
            MediaPlayer.shared.stopAudio()
            NotificationCenter.default.post(name: .ResetPlayButton, object: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIDevice.current.orientation.isLandscape {
            setupLandscapeConstraints()
        } else {
            setupPortraitConstraints()
        }
    }
    
    @IBAction func likedButtonTapped(_ sender: WCLShineButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            
            if !albumDetailsViewModel.isLiked {
                likedButton.isSelected = false
            } else {
                likedButton.isSelected = true
            }
            return
        }
        
        albumDetailsViewModel.removeAddAlbumToFromFirebase()
        
        //Checks whether we came from the home screen or not
        albumDetailsViewModel.isHomeScreen()
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        Loaf.dismiss(sender: self, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? DetailsMusicViewController,
              let data = sender as? Dictionary<String, Any> else {return}
        
        targetController.track = data[albumDetailsViewModel.trackText] as? Track
        targetController.album = data[albumDetailsViewModel.albumText] as? TopAlbums
        targetController.isAlbumDetails = data[albumDetailsViewModel.isAlbumDetailsText] as? Bool
    }
}

//MARK: Functions
extension AlbumDetailsViewController {
    
    private func setupDelegates() {
        albumDetailsViewModel.delegate = self
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
    }
    
    private func setupPortraitConstraints() {
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
    
    private func setupLandscapeConstraints() {
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
    
    private func loadImage() {
        guard let album = albumDetailsViewModel.album else {return}
        self.title = album.title
        guard let str = albumDetailsViewModel.album?.coverBig,
              let url = URL(string: str) else {
            
            setUpImageView()
            albumImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
    
        setUpImageView()
        albumImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        albumImageView.sd_setImage(with: url)
    }
    
    //Sets up the ImageView
    private func setUpImageView() {
        albumImageView.tintColor = .white
        albumImageView.layer.cornerRadius = 15
        albumImageView.layer.masksToBounds = true
    }
    
    private func setupObservers() {
        //An observer to check if the app moved to background
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    //Shows the activity indicator(when the tableview is loading it's data)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        
        //Converts albumTrack to Track and sends it via segue
        let dict = albumDetailsViewModel.convertAlbumTrackToTrack(indexPathRow: indexPath.row)
        
        MediaPlayer.shared.stopAudio()
        if let prevIndexPath = baseViewModel.prevIndexPath {
            //Resests the play button state when segue to another screen
            baseViewModel.arrIndexPaths.removeAll()
            prevButton.setImage(UIImage(systemName: Constants.playFillText), for: .normal)
            tracksTableView.reloadRows(at: [prevIndexPath], with: .none)
        }
        performSegue(withIdentifier: albumDetailsViewModel.toDetailsText, sender: dict)
    }
    
    //Handles the play button state when the app moves to background
    @objc private func appMovedToBackground() {
        MediaPlayer.shared.stopAudio()
        prevButton.setImage(UIImage(systemName: Constants.playFillText), for: .normal)
        baseViewModel.arrIndexPaths.removeAll()
        if let prevIndexPath = baseViewModel.prevIndexPath {
            tracksTableView.reloadRows(at: [prevIndexPath], with: .none)
        }
    }
    
    private func showAlertWithActions(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: albumDetailsViewModel.retryText, style: .cancel, handler: {[weak self] action in
            if !Connectivity.isConnectedToInternet {
                self?.showAlertWithActions(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            } else {
                self?.albumDetailsViewModel.fetchTracks()
                self?.loadActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
}

//MARK: DataSource
extension AlbumDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumDetailsViewModel.albumTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! DetailsTableViewCell
        
        populateCell(indexPath: indexPath, cell: cell, tableView: tracksTableView)
        
        if let album = albumDetailsViewModel.album {
            cell.populate(album: album, track: albumDetailsViewModel.albumTracks[indexPath.row])
        }
        return cell
    }
}

//MARK: Delegates
extension AlbumDetailsViewController: AlbumDetailsViewModelDelegate {
    
    func reloadTableView(albumTracks: [AlbumTrack]) {
        self.tracksTableView.reloadData()
        self.numberOfTracks.text = String(albumTracks.count)
        
        let cells = self.tracksTableView.visibleCells
        UIView.animate(views: cells, animations: [self.animation])
    }
    
    func stopAnimation() {
        self.activityIndicatorView.stopAnimating()
    }
    
    func isLikedButtonSelected(isSelected: Bool) {
        self.likedButton.isSelected = isSelected
    }
    
    func loafMessageAdded(album: TopAlbums) {
        loafMessageAddedAlbum(album: album)
    }
    
    func loafMessageRemoved(album: TopAlbums) {
        loafMessageRemovedAlbum(album: album)
    }
}
