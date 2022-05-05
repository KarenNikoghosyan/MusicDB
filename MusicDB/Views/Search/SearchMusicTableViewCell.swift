//
//  SearchMusicTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 31/07/2021.
//

import UIKit
import SDWebImage
import MarqueeLabel

class SearchMusicTableViewCell: UITableViewCell {
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackTitleLabel: MarqueeLabel!
    @IBOutlet private weak var trackArtistNameLabel: UILabel!
    @IBOutlet private weak var trackDurationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
    }
}

//MARK: - Functions
extension SearchMusicTableViewCell {
    
    private func setupLabels() {
        trackTitleLabel.animationCurve = .linear
    }
    
    func populate(track: Track) {
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
        
        trackTitleLabel.text = track.titleShort
        trackArtistNameLabel.text = track.artist.name
        
        let minutes = track.duration / 60
        let seconds = track.duration % 60
        trackDurationLabel.text = "\(minutes):\(seconds)"
    }
}
