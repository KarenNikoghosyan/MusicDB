//
//  DetailsMusicCollectionViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 23/06/2021.
//

import UIKit
import SDWebImage

class DetailsMusicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var detailsTrackLabel: UILabel!
    @IBOutlet weak var detailsTrackImageView: UIImageView!
    
    func populate(track: Track) {
        detailsTrackLabel.text = track.titleShort
        
        guard let url = URL(string: "\(track.album?.cover ?? "No Image Found")") else {
            detailsTrackImageView.tintColor = .white
            
            detailsTrackImageView.layer.cornerRadius = 25
            detailsTrackImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        detailsTrackImageView.tintColor = .white
        detailsTrackImageView.layer.cornerRadius = 25
        
        detailsTrackImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        detailsTrackImageView.sd_setImage(with: url)
    }
}
