//
//  LikedGenreTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/07/2021.
//

import UIKit
import SDWebImage

class LikedGenreTableViewCell: UITableViewCell {

    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackArtistNameLabel: UILabel!
    @IBOutlet weak var trackAlbumNameLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    
    func populate(track: Track) {
        trackTitleLabel.text = track.titleShort
        trackArtistNameLabel.text = track.artist.name
        trackAlbumNameLabel.text = track.album.title
        
        let duration = Double(track.duration) / 60.0
        let durationString = String(format: "%.2f", duration) + " Minutes"
        let newDurationString = durationString.replacingOccurrences(of: ".", with: ":")
        trackDurationLabel.text = newDurationString
        
        guard let url = URL(string: "\(track.album.cover ?? "No Image Found")") else {
            trackImageView.tintColor = .white
            
            trackImageView.layer.cornerRadius = 25
            trackImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        trackImageView.tintColor = .white
        trackImageView.layer.cornerRadius = 25
        trackImageView.layer.masksToBounds = true
        
        trackImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        trackImageView.sd_setImage(with: url)
    }
    
}
