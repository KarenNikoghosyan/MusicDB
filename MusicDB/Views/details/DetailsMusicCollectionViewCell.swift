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
        detailsTrackLabel.text = track.title_short
        
        guard let url = URL(string: "\(track.album?.cover ?? "")") else {
            print("Test")
            detailsTrackImageView.layer.cornerRadius = 20
            detailsTrackImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        detailsTrackImageView.layer.cornerRadius = 20
        detailsTrackImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
    }
}
