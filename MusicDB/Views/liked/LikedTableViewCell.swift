//
//  LikedTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 06/07/2021.
//

import UIKit
import SDWebImage

class LikedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var likedTrackImageView: UIImageView!
    @IBOutlet weak var likedTrackTitleLabel: UILabel!
    @IBOutlet weak var likedTrackArtistNameLabel: UILabel!
    @IBOutlet weak var likedTrackAlbumNameLabel: UILabel!
    @IBOutlet weak var likedTrackDurationLabel: UILabel!
    
    func populate(track: Track) {
        likedTrackTitleLabel.text = track.titleShort
        likedTrackArtistNameLabel.text = track.artist.name
        likedTrackAlbumNameLabel.text = track.album.title
        
        let duration = Double(track.duration) / 60.0
        let durationString = String(format: "%.2f", duration) + " Minutes"
        let newDurationString = durationString.replacingOccurrences(of: ".", with: ":")
        likedTrackDurationLabel.text = newDurationString
        
        guard let url = URL(string: "\(track.album.cover ?? "No Image Found")") else {
            likedTrackImageView.tintColor = .white
            
            likedTrackImageView.layer.cornerRadius = 25
            likedTrackImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        likedTrackImageView.tintColor = .white
        likedTrackImageView.layer.cornerRadius = 25
        
        likedTrackImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        likedTrackImageView.sd_setImage(with: url)
    }
}
