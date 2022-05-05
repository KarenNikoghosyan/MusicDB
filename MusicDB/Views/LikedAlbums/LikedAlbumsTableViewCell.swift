//
//  LikedAlbumsTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 02/08/2021.
//

import UIKit
import SDWebImage
import MarqueeLabel

class LikedAlbumsTableViewCell: UITableViewCell {

    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var albumImageView: UIImageView!
    @IBOutlet private weak var albumTitleLabel: MarqueeLabel!
    @IBOutlet private weak var albumArtistNameLabel: MarqueeLabel!
    @IBOutlet weak var openWebsiteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
    }
}

//MARK: - Functions
extension LikedAlbumsTableViewCell {
    
    private func setupLabels() {
        albumTitleLabel.animationCurve = .linear
        albumArtistNameLabel.animationCurve = .linear
    }
    
    func setupCellConstraints() {
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
    
    private func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
}
