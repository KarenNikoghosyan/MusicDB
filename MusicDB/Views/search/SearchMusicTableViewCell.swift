//
//  SearchMusicTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 31/07/2021.
//

import UIKit
import SDWebImage

class SearchMusicTableViewCell: UITableViewCell {
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackArtistNameLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    
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
