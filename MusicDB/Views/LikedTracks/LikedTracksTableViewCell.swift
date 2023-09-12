//
//  LikedTracksTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 02/08/2021.
//

import UIKit
import SDWebImage
import MarqueeLabel

class LikedTracksTableViewCell: UITableViewCell {

    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackTitleLabel: MarqueeLabel!
    @IBOutlet private weak var trackArtistNameLabel: MarqueeLabel!
    @IBOutlet private weak var trackAlbumNameLabel: MarqueeLabel!
    @IBOutlet private weak var trackDurationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
    }
}

//MARK: - Functions
extension LikedTracksTableViewCell {
    
    private func setupLabels() {
        trackTitleLabel.animationCurve = .linear
        trackArtistNameLabel.animationCurve = .linear
        trackAlbumNameLabel.animationCurve = .linear
    }
    
    func setupCellConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewWidthConstraint.constant = 95
        default:
            imageViewWidthConstraint.constant = 130
        }
    }
 
    func populate(track: Track) {
        trackTitleLabel.text = track.titleShort
        trackArtistNameLabel.text = track.artist.name
        trackAlbumNameLabel.text = track.album?.title
        
        let minutes = track.duration / 60
        let formattedSeconds = String(format: "%02d", track.duration % 60)
        trackDurationLabel.text = "\(minutes):\(formattedSeconds)"
        
        guard let url = URL(string: "\(track.album?.cover ?? "No Image Found")") else {
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
    
    private func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
}
