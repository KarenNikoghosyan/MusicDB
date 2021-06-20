//
//  DetailsMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 20/06/2021.
//

import UIKit
import SDWebImage

class DetailsMusicViewController: UIViewController {
    var track: Track?
    
    @IBOutlet weak var detailsImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let track = track,
              let url = URL(string: "\(track.album.cover_medium ?? "")") else {
            detailsImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            detailsImageView.layer.cornerRadius = 20
            return
        }
        
        detailsImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
        detailsImageView.layer.cornerRadius = 20
    }
}
