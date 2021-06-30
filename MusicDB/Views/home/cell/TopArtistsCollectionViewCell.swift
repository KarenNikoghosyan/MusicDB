//
//  TopArtistsCollectionViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 28/06/2021.
//

import UIKit
import SDWebImage

class TopArtistsCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "topArtistsCell"

    let name = UILabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        name.font = UIFont.preferredFont(forTextStyle: .title2)
        name.textColor = .white

        imageView.tintColor = .white
        imageView.layer.cornerRadius = 28
        imageView.clipsToBounds = true

        let stackView = UIStackView(arrangedSubviews: [imageView, name])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 20
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(artist: TopArtists) {
        name.text = artist.name
        
        guard let url = URL(string: artist.pictureSmall ?? "") else {
            imageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        imageView.sd_setImage(with: url)
    }
}
