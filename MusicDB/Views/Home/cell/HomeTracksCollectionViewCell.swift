//
//  HomeTracksCollectionViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/06/2021.
//

import UIKit
import SDWebImage
import MarqueeLabel

class HomeTracksCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "topChartsCell"
    
    private let label = MarqueeLabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.animationCurve = .linear
        label.font = UIFont.init(name: "Futura", size: 14)
        label.textColor = .white
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)

        imageView.tintColor = .white
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [label, imageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Functions
extension HomeTracksCollectionViewCell {
    
    func configure(track: Track, with imageQuality: String) {
        label.text = "  " + track.titleShort
        
        guard let url = URL(string: imageQuality) else {
            imageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        imageView.sd_setImage(with: url)
    }
}
