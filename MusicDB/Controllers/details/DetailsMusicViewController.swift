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

class DetailsMusicViewController: UIViewController {
    var track: Track?
    var tracks: [Track] = []
    var ds = TrackAPIDataSource()
    
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
        
        UIView.animate(withDuration: 0.4) {[weak self] in
            self?.goToWebsiteButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.4), for: .normal)
            self?.goToWebsiteButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        }
        
        guard let track = track,
              let url = URL(string: "\(track.link ?? "Can't load the link")") else {return}
        
        let sfVC = SFSafariViewController(url: url)
        present(sfVC, animated: true)
    }
    
    @IBOutlet weak var previewButton: LoadyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistCollectionView.delegate = self
        artistCollectionView.dataSource = self
        
        
        let nib = UINib(nibName: "DetailsMusicCollectionViewCell", bundle: .main)
        artistCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
     
        fetchTracks()
        
        self.previewButton.addTarget(self, action: #selector(animateButton(_:)), for: .touchUpInside)
        
        self.previewButton.setAnimation(LoadyAnimationType.android())
        
        guard let track = track,
              let url = URL(string: "\(track.album.cover_medium ?? "")") else {
            detailsImageView.tintColor = .white
            detailsImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            detailsImageView.layer.cornerRadius = 20
            return
        }
        
        detailsImageView.tintColor = .white
        detailsImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
        detailsImageView.layer.cornerRadius = 20
        
        detailsTitleLabel.text = track.title_short
        detailsArtistNameLabel.text = track.artist.name
        detailsAlbumTitleLabel.text = track.album.title
        
        let duration = Double(track.duration) / 60.0
        let durationString = String(format: "%.2f", duration) + " Minutes"
        let newDurationString = durationString.replacingOccurrences(of: ".", with: ":")
        detailsDurationLabel.text = newDurationString
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed {
            MediaPlayer.shared.stopAudio()
            previewButton.stopLoading()
            previewButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
    }
    
    @IBAction func animateButton(_ sender: UIButton) {
        if let button = sender as? LoadyButton {
            if button.loadingIsShowing() {
                button.stopLoading()
                button.setImage(UIImage(systemName: "play.circle"), for: .normal)
                MediaPlayer.shared.stopAudio()
                return
            }
            button.startLoading()
            button.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            guard let str = track?.preview,
                  let url = URL(string: str) else {return}
            MediaPlayer.shared.loadAudio(url: url)
        }
    }
    
    func fetchTracks() {
        ds.fetchTrucks(from: .artist, id: track?.artist.id, path: "/top", with: ["limit":100]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.tracks = tracks
                self?.artistCollectionView.reloadData()
            } else if let error = error {
                //TODO: Dialog
                print(error)
            }
        }
    }
}

extension DetailsMusicViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let track = tracks[indexPath.item]
            
        if let cell = cell as? DetailsMusicCollectionViewCell {
            cell.populate(track: track)
        }
        return cell
    }
}
//
//extension DetailsMusicViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 50, height: collectionView.bounds.height / 2)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets.zero
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//}
