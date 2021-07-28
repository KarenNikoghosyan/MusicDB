//
//  AlbumsTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import UIKit
import SDWebImage
import WCLShineButton

class AlbumsTableViewCell: UITableViewCell {
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumArtistNameLabel: UILabel!
    @IBOutlet weak var likedButton: WCLShineButton!
    @IBAction func likedButtonTapped(_ sender: WCLShineButton) {
    }
    @IBAction func openWebsiteTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: .OpenLinkInSafari, object: nil, userInfo: ["sender" : sender])
    }
    
    func populate(album: TopAlbums) {
        guard let str = album.coverMedium,
              let url = URL(string: str) else {
            
            albumImageView.tintColor = .white
            albumImageView.layer.cornerRadius = 25
            albumImageView.layer.masksToBounds = true
            albumImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        albumImageView.tintColor = .white
        albumImageView.layer.cornerRadius = 25
        albumImageView.layer.masksToBounds = true
        
        albumImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        albumImageView.sd_setImage(with: url)
        
        albumTitleLabel.text = album.title
        albumArtistNameLabel.text = album.artist.name
    }
}
