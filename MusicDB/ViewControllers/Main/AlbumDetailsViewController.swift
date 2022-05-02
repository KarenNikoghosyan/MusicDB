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

class AlbumDetailsViewController: BaseViewController {
    
    let albumDetailsViewModel = AlbumDetailsViewModel()
    
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var numberOfTracks: UILabel!
    @IBOutlet private weak var albumImageView: UIImageView!
    @IBOutlet private weak var tracksTableView: UITableView!
    @IBOutlet private weak var likedButton: WCLShineButton!
    private var prevButton: UIButton = UIButton()
    
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
        albumDetailsViewModel.setupObservers()
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
    
    @IBAction private func likedButtonTapped(_ sender: WCLShineButton) {
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
    
    @IBAction private func backButtonTapped(_ sender: UIBarButtonItem) {
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
        MediaPlayer.shared.delegate = self
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
        if let prevIndexPath = albumDetailsViewModel.prevIndexPath {
            //Resests the play button state when segue to another screen
            albumDetailsViewModel.arrIndexPaths.removeAll()
            prevButton.setImage(UIImage(systemName: Constants.playFillText), for: .normal)
            tracksTableView.reloadRows(at: [prevIndexPath], with: .none)
        }
        performSegue(withIdentifier: albumDetailsViewModel.toDetailsText, sender: dict)
    }
    
    private func showAlertWithActions(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: Constants.retryText, style: .cancel, handler: {[weak self] action in
            if !Connectivity.isConnectedToInternet {
                self?.showAlertWithActions(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            } else {
                self?.albumDetailsViewModel.fetchTracks()
                self?.loadActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        albumDetailsViewModel.playButtonLogic(sender)
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
        cell.playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)

        cell.playButton.tag = indexPath.row
        
        if albumDetailsViewModel.arrIndexPaths.contains(indexPath) {
            cell.playButton.setImage(UIImage(systemName: Constants.pauseFillImage), for: .normal)
            cell.playButton.tintColor = .white
        } else {
            cell.playButton.setImage(UIImage(systemName: Constants.playFillImage), for: .normal)
            cell.playButton.tintColor = .darkGray
        }
        
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
    
    func reloadTableViewRows(selectedIndexPath: IndexPath) {
        tracksTableView.reloadRows(at: [selectedIndexPath], with: .none)
    }
    
    func assignPrevButton(_ sender: UIButton) {
        prevButton = sender
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
    
    func changeButtonImageAndReloadRows(prevIndexPath: IndexPath) {
        prevButton.setImage(UIImage(systemName: Constants.playFillImage), for: .normal)
        tracksTableView.reloadRows(at: [prevIndexPath], with: .none)
    }
}

extension AlbumDetailsViewController: MediaPlayerDelegate {
    func changeButtonStateAfterAudioStopsPlaying() {
        albumDetailsViewModel.changeButtonStateAfterAudioStopsPlaying()
    }
}
