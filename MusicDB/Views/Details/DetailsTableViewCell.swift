//
//  DetailsTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import UIKit
import SDWebImage
import MarqueeLabel

class DetailsTableViewCell: UITableViewCell {
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackTitleLabel: MarqueeLabel!
    @IBOutlet private weak var trackArtistNameLabel: UILabel!
    @IBOutlet private weak var trackDurationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
    }
}

//MARK: - Functions
extension DetailsTableViewCell {
    
    private func setupLabels() {
        trackTitleLabel.animationCurve = .linear
    }
    
    func populate(album: TopAlbums, track: AlbumTrack) {
        guard let str = album.cover,
              let url = URL(string: str) else {

            trackImageView.tintColor = .white
            trackImageView.layer.cornerRadius = 15
            trackImageView.layer.masksToBounds = true
            trackImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        trackImageView.tintColor = .white
        trackImageView.layer.cornerRadius = 15
        trackImageView.layer.masksToBounds = true
        
        trackImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        trackImageView.sd_setImage(with: url)
        
        trackTitleLabel.text = track.title
        trackArtistNameLabel.text = track.artist.name
        
        let minutes = track.duration / 60
        let seconds = track.duration % 60
        let newDuration = "\(minutes):\(seconds)"
        trackDurationLabel.text = newDuration
    }
    
    func populateTrack(track: Track) {
        guard let str = track.album?.cover,
              let url = URL(string: str) else {

            trackImageView.tintColor = .white
            trackImageView.layer.cornerRadius = 15
            trackImageView.layer.masksToBounds = true
            trackImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        trackImageView.tintColor = .white
        trackImageView.layer.cornerRadius = 15
        trackImageView.layer.masksToBounds = true
        
        trackImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        trackImageView.sd_setImage(with: url)
        
        trackTitleLabel.text = track.title
        trackArtistNameLabel.text = track.artist.name
        
        let minutes = track.duration / 60
        let seconds = track.duration % 60
        let newDuration = "\(minutes):\(seconds)"
        trackDurationLabel.text = newDuration
    }
}
