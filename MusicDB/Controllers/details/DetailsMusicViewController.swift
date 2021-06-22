//
//  DetailsMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 20/06/2021.
//

import UIKit
import SDWebImage
import SafariServices

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
    
    @IBAction func goToWebsiteTapped(_ sender: UIButton) {
        guard let track = track,
              let url = URL(string: "\(track.link)") else {return}
        
        let sfVC = SFSafariViewController(url: url)
        present(sfVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let track = track,
              let url = URL(string: "\(track.album.cover_medium ?? "")") else {
            detailsImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            detailsImageView.layer.cornerRadius = 20
            return
        }
        
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
}
