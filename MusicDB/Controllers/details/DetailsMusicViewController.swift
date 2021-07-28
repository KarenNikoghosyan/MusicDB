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
import FirebaseFirestore
import FirebaseAuth

class DetailsMusicViewController: BaseViewController {
    
    var track: Track?
    var indexPath: IndexPath?
    var isGenre: Bool? = false

    let noTracksLabel = UILabel()
    var isLiked: Bool = false
    let db = Firestore.firestore()
    
    @IBOutlet weak var artistCollectionView: UICollectionView!
    
    @IBOutlet weak var detailsImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsTitleLabel: UILabel!
    
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
        
        UIView.animate(withDuration: 0.4) {[weak self] in
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
            addTrack(track: track, userID: userID)
            loafMessageAdded(track: track)

            isLiked = true
        } else {
            removeTrack(track: track, userID: userID)
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
        
        createLikeButton()
        loadNoTracksLabel()
  
        let notifactionCenter = NotificationCenter.default
        notifactionCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        artistCollectionView.delegate = self
        artistCollectionView.dataSource = self
        
        let nib = UINib(nibName: "DetailsSearchMusicCollectionViewCell", bundle: .main)
        artistCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
     
        setUpViews()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        artistCollectionView?.reloadData()
    }
    
    func checkLikedStatus() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
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
    
    func setUpViews() {
        self.previewButton.addTarget(self, action: #selector(animateButton(_:)), for: .touchUpInside)
        
        self.previewButton.setAnimation(LoadyAnimationType.android())
        
        guard let track = track,
              let url = URL(string: "\(track.album.coverMedium ?? "")") else {
            detailsImageView.tintColor = .white
            detailsImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            detailsImageView.layer.cornerRadius = 25
            return
        }
        
        detailsImageView.tintColor = .white
        detailsImageView.layer.cornerRadius = 25
        detailsImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        detailsImageView.sd_setImage(with: url)
        
        detailsTitleLabel.text = track.titleShort
        detailsArtistNameLabel.text = track.artist.name
        detailsAlbumTitleLabel.text = track.album.title
        
        let minutes = track.duration / 60
        let seconds = track.duration % 60
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
            noTracksLabel.topAnchor.constraint(equalTo: artistCollectionView.topAnchor, constant: 24),
            noTracksLabel.leadingAnchor.constraint(equalTo: artistCollectionView.leadingAnchor, constant: 0),
            noTracksLabel.trailingAnchor.constraint(equalTo: artistCollectionView.trailingAnchor, constant: 0)
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
        let animation = AnimationType.from(direction: .right, offset: 30.0)
        
        ds.fetchTracks(from: .artist, id: track?.artist.id, path: "/top", with: ["limit":200]) {[weak self] tracks, error in
            if let tracks = tracks {
                
                guard let self = self else {return}
                self.tracks = tracks
                self.artistCollectionView.reloadData()
                
                self.artistCollectionView.animate(animations: [animation])
                self.activityIndicatorView.stopAnimating()
                
                if tracks.count <= 0 {
                    self.noTracksLabel.isHidden = false
                } else {
                    self.noTracksLabel.isHidden = true
                }
                
            } else if let error = error {
                //TODO: Dialog
                print(error)
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    @objc func appMovedToBackground() {
        stopAudio()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Loaf.dismiss(sender: self, animated: true)
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let parentVC = presentingViewController
            
        dismiss(animated: true) {[weak self] in
            let detailsVC = DetailsMusicViewController.storyboardInstance(storyboardID: "Main", restorationID: "detailsScreen") as! DetailsMusicViewController
            
            let track = self?.tracks[indexPath.item]
            detailsVC.track = track
            parentVC?.present(detailsVC, animated: true)
        }
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
