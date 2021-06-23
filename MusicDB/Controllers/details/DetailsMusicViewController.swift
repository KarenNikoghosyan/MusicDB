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
              let url = URL(string: "\(track.link)") else {return}
        
        let sfVC = SFSafariViewController(url: url)
        present(sfVC, animated: true)
    }
    
    @IBOutlet weak var previewButton: LoadyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
