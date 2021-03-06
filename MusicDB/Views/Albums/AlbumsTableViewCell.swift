//
//  AlbumsTableViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import UIKit
import SDWebImage
import WCLShineButton
import FirebaseAuth
import MarqueeLabel

class AlbumsTableViewCell: UITableViewCell {
    var isLiked: Bool = false

    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var albumImageView: UIImageView!
    @IBOutlet private weak var albumTitleLabel: MarqueeLabel!
    @IBOutlet private weak var albumArtistNameLabel: MarqueeLabel!
    @IBOutlet private weak var likedButton: WCLShineButton!
    @IBOutlet weak var openWebsiteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
    }
    
    @IBAction func likedButtonTapped(_ sender: WCLShineButton) {
        if likedButton.isSelected {
            NotificationCenter.default.post(name: .RemoveAlbumID, object: nil, userInfo: ["indexPath" : getIndexPath() as Any])
        } else {
            NotificationCenter.default.post(name: .AddAlbumID, object: nil, userInfo: ["indexPath" : getIndexPath() as Any])
        }
    }
}

//MARK: - Functions
extension AlbumsTableViewCell {
    
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
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            guard let arrIDs: [Int] = snapshot?.get("albumIDs") as? [Int] else {return}
            if arrIDs.contains(album.id) {
                self.likedButton.isSelected = true
                self.isLiked = true
            } else {
                self.likedButton.isSelected = false
                self.isLiked = false
            }
        }
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
