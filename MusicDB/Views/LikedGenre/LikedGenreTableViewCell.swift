//
//  LikedGenreTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/07/2021.
//

import UIKit
import SDWebImage
import WCLShineButton
import FirebaseAuth

class LikedGenreTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackTitleLabel: UILabel!
    @IBOutlet private weak var trackArtistNameLabel: UILabel!
    @IBOutlet private weak var trackAlbumNameLabel: UILabel!
    @IBOutlet private weak var trackDurationLabel: UILabel!
    @IBOutlet private weak var likedButton: WCLShineButton!
    
    private var isLiked: Bool = false
    
    @IBAction private func likedButtonTapped(_ sender: WCLShineButton) {
        if likedButton.isSelected {
            NotificationCenter.default.post(name: .IndexRemove, object: nil, userInfo: ["indexPath" : getIndexPath() as Any])
        } else {
            NotificationCenter.default.post(name: .IndexAdd, object: nil, userInfo: ["indexPath" : getIndexPath() as Any])
        }
    }
}

//MARK: - Functions
extension LikedGenreTableViewCell {
    
    func setupCellConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewWidthConstraint.constant = 95
        default:
            imageViewWidthConstraint.constant = 130
        }
    }
 
    func populate(track: Track) {
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            guard let arrIDs: [Int] = snapshot?.get("trackIDs") as? [Int] else {return}
            if arrIDs.contains(track.id) {
                self.likedButton.isSelected = true
                self.isLiked = true
            } else {
                self.likedButton.isSelected = false
                self.isLiked = false
            }
        }
        trackTitleLabel.text = track.titleShort
        trackArtistNameLabel.text = track.artist.name
        trackAlbumNameLabel.text = track.album?.title
        
        let minutes = track.duration / 60
        let seconds = track.duration % 60
        trackDurationLabel.text = "\(minutes):\(seconds)"
        
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
