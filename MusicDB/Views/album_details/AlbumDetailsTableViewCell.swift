//
//  AlbumDetailsTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import UIKit
import SDWebImage

class AlbumDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackArtistNameLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    
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
}
