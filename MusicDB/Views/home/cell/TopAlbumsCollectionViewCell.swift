//
//  TopAlbumsCollectionViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 28/06/2021.
//

import UIKit
import SDWebImage

class TopAlbumsCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "topAlbumsCell"

    let subtitle = UILabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        subtitle.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitle.textColor = .white

        imageView.tintColor = .white
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true

        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let stackview = UIStackView(arrangedSubviews: [imageView, subtitle])
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.alignment = .center
        stackview.spacing = 10
        contentView.addSubview(stackview)

        NSLayoutConstraint.activate([
            stackview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackview.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }
    
    func configure(album: TopAlbums) {
        subtitle.text = album.title
        
        guard let str = album.coverSmall,
              let url = URL(string: str) else {
            
            imageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        imageView.sd_setImage(with: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
