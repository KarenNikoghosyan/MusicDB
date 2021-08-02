//
//  LikedAlbumsTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 02/08/2021.
//

import UIKit
import SDWebImage

class LikedAlbumsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumArtistNameLabel: UILabel!
    
    @IBOutlet weak var openWebsiteButton: UIButton!
    
    func cellConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewHeightConstraint.constant = 110
            openWebsiteButton.titleLabel?.font = UIFont(name: "Futura-Bold", size: 11)
        default:
            imageViewHeightConstraint.constant = 130
            openWebsiteButton.titleLabel?.font = UIFont(name: "Futura-Bold", size: 14)
        }
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
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
}
