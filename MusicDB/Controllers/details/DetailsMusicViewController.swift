//
//  DetailsMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 20/06/2021.
//

import UIKit
import SDWebImage
import SafariServices
import Loady
import ViewAnimator
import WCLShineButton
import Loaf
import FirebaseAuth

class DetailsMusicViewController: BaseTableViewController {
    
    var track: Track?
    var album: TopAlbums?
    
    var isLiked: Bool = false
    
    var indexPath: IndexPath?
    var isGenre: Bool? = false
    var isAlbumDetails: Bool? = false

    let noTracksLabel = UILabel()
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        stopAudio()
        Loaf.dismiss(sender: self, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var artistTableView: UITableView!
    
    @IBOutlet weak var detailsImageView: UIImageView!
        
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var detailsArtistNameLabel: UILabel!
    
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var detailsAlbumTitleLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var detailsDurationLabel: UILabel!
    
    @IBOutlet weak var goToWebsiteButton: UIButton!
    @IBAction func goToWebsiteTapped(_ sender: UIButton) {
        Loaf.dismiss(sender: self, animated: true)
        
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.goToWebsiteButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.4), for: .normal)
            self?.goToWebsiteButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        }
        
        guard let track = track,
              let url = URL(string: "\(track.link ?? "Can't load the link")") else {return}
        
        let sfVC = SFSafariViewController(url: url)
        present(sfVC, animated: true)
        stopAudio()
    }
    
    @IBOutlet weak var previewButton: LoadyButton!
    @IBOutlet weak var likedButton: WCLShineButton!
    @IBAction func likedButtonTapped(_ sender: WCLShineButton) {
        guard let track = track else {return}
        
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            if !isLiked {
                likedButton.isSelected = false
            } else {
                likedButton.isSelected = true
            }
            return
        }
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        if !isLiked {
            FirestoreManager.shared.addTrack(track: track, userID: userID)
            loafMessageAdded(track: track)

            isLiked = true
        } else {
            FirestoreManager.shared.removeTrack(track: track, userID: userID)
            loafMessageRemoved(track: track)

            isLiked = false
        }
        guard let isGenre = isGenre else {return}
        if isGenre {
            NotificationCenter.default.post(name: .SendIndexPath, object: nil, userInfo: ["indexPath" : indexPath as Any])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Connectivity.isConnectedToInternet {
            fetchTracks()
            checkLikedStatus()
            loadActivityIndicator()
        }
        
        self.title = track?.titleShort
        createLikeButton()
        loadNoTracksLabel()
  
        let notifactionCenter = NotificationCenter.default
        notifactionCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        artistTableView.delegate = self
        artistTableView.dataSource = self
     
        guard let isAlbumDetails = isAlbumDetails else {return}
        if !isAlbumDetails {
            setUpViewsFromTrack()
        } else {
            setUpViewsFromAlbumDetails()
        }
    }
    
    func portraitConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewHeightConstraint.constant = 130
        case .iPhoneSE2:
            imageViewHeightConstraint.constant = 150
        case .iPhone8:
            imageViewHeightConstraint.constant = 150
        default:
            break
        }
    }
    
    func landscapeConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewHeightConstraint.constant = 100
        case .iPhoneSE2:
            imageViewHeightConstraint.constant = 100
        case .iPhone8:
            imageViewHeightConstraint.constant = 100
        default:
            break
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Connectivity.isConnectedToInternet {
            showAlertAndReload(title: "No Internet Connection", message: "Failed to connect to the internet")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            stopAudio()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailsTableViewCell
        
        populateCell(indexPath: indexPath, cell: cell, tableView: artistTableView)
        
        cell.populateTrack(track: tracks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Loaf.dismiss(sender: self, animated: true)
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let parentVC = presentingViewController
            
        dismiss(animated: true) {[weak self] in
            guard let detailsVC = DetailsMusicViewController.storyboardInstance(storyboardID: "Main", restorationID: "detailsScreen") as? UINavigationController,
                  let targetController = detailsVC.topViewController as? DetailsMusicViewController else {return}
            
            let track = self?.tracks[indexPath.row]
            targetController.track = track
            parentVC?.present(detailsVC, animated: true)
        }
    }
    
    func checkLikedStatus() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            guard let arrIDs: [Int] = snapshot?.get("trackIDs") as? [Int] else {return}
            if arrIDs.contains(self.track?.id ?? 0) {
                self.likedButton.isSelected = true
                self.isLiked = true
            } else {
                self.likedButton.isSelected = false
                self.isLiked = false
            }
        }
    }
    
    func setUpViewsFromTrack() {
        self.previewButton.addTarget(self, action: #selector(animateButton(_:)), for: .touchUpInside)
        
        self.previewButton.setAnimation(LoadyAnimationType.android())
        
        guard let track = track,
              let url = URL(string: "\(track.album?.coverMedium ?? "")") else {
            
            detailsImageView.tintColor = .white
            detailsImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            detailsImageView.layer.cornerRadius = 25
            return
        }
        
        detailsImageView.tintColor = .white
        detailsImageView.layer.cornerRadius = 25
        detailsImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        detailsImageView.sd_setImage(with: url)
        
        detailsArtistNameLabel.text = track.artist.name
        detailsAlbumTitleLabel.text = track.album?.title
        
        let minutes = track.duration / 60
        let seconds = track.duration % 60
        detailsDurationLabel.text = "\(minutes):\(seconds)"
    }
    
    func setUpViewsFromAlbumDetails() {
        self.previewButton.addTarget(self, action: #selector(animateButton(_:)), for: .touchUpInside)
        
        self.previewButton.setAnimation(LoadyAnimationType.android())
        
        guard let album = album,
              let url = URL(string: "\(album.coverMedium ?? "")") else {
            
            detailsImageView.tintColor = .white
            detailsImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            detailsImageView.layer.cornerRadius = 25
            return
        }
        
        detailsImageView.tintColor = .white
        detailsImageView.layer.cornerRadius = 25
        detailsImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        detailsImageView.sd_setImage(with: url)
        
        detailsArtistNameLabel.text = track?.artist.name
        detailsAlbumTitleLabel.text = track?.album?.title
        
        guard let duration = track?.duration else {return}
        let minutes = duration / 60
        let seconds = duration % 60
        detailsDurationLabel.text = "\(minutes):\(seconds)"
    }
  
    func createLikeButton() {
        var param = WCLShineParams()
        param.bigShineColor = UIColor(rgb: (153,152,38))
        param.smallShineColor = UIColor(rgb: (102,102,102))
        
        likedButton.image = .heart
        
        likedButton.fillColor = UIColor(rgb: (255,0,0))
        likedButton.color = UIColor(rgb: (100,100,100))
    }
    
    func loadNoTracksLabel() {
        noTracksLabel.text = "No Tracks Found"
        noTracksLabel.font = UIFont.init(name: "Futura", size: 20)
        noTracksLabel.textColor = .white
        noTracksLabel.textAlignment = .center
        
        view.addSubview(noTracksLabel)
        
        noTracksLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noTracksLabel.topAnchor.constraint(equalTo: artistTableView.topAnchor, constant: 24),
            noTracksLabel.leadingAnchor.constraint(equalTo: artistTableView.leadingAnchor, constant: 0),
            noTracksLabel.trailingAnchor.constraint(equalTo: artistTableView.trailingAnchor, constant: 0)
        ])
        noTracksLabel.isHidden = true
    }
    
    @IBAction func animateButton(_ sender: UIButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        
        if let button = sender as? LoadyButton {
            if button.loadingIsShowing() {
                stopAudio()
                return
            }
            button.startLoading()
            button.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            guard let str = track?.preview,
                  let url = URL(string: str) else {return}
            MediaPlayer.shared.loadAudio(url: url)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {[weak self] in
                self?.stopAudio()
            }
        }
    }
    
    func stopAudio() {
        MediaPlayer.shared.stopAudio()
        previewButton.stopLoading()
        previewButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
    }
    
    func fetchTracks() {
        ds.fetchTracks(from: .artist, id: track?.artist.id, path: "/top", with: ["limit":200]) {[weak self] tracks, error in
            if let tracks = tracks {
                guard let self = self else {return}
                
                self.tracks = tracks
                self.artistTableView.reloadData()
                
                let cells = self.artistTableView.visibleCells
                UIView.animate(views: cells, animations: [self.animation])
                self.activityIndicatorView.stopAnimating()
                
                if tracks.count <= 0 {
                    self.noTracksLabel.isHidden = false
                } else {
                    self.noTracksLabel.isHidden = true
                }
                
            } else if let error = error {
                print(error)
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    @objc func appMovedToBackground() {
        stopAudio()
    }
}

extension DetailsMusicViewController {
    func showAlertAndReload(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: "Retry", style: .cancel, handler: {[weak self] action in
            if !Connectivity.isConnectedToInternet {
                self?.showAlertAndReload(title: "No Internet Connection", message: "Failed to connect to the internet")
            } else {
                self?.fetchTracks()
                self?.checkLikedStatus()
                self?.loadActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
}
