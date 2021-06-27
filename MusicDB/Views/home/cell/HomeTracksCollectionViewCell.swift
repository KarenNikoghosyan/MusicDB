//
//  TopChartsCollectionViewCell.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/06/2021.
//

import UIKit
import SDWebImage

class HomeTracksCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifer = "topChartsCell"
    let topChartImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        topChartImageView.tintColor = .white
        topChartImageView.layer.cornerRadius = 20
        topChartImageView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(track: Track, with imageQuality: String) {
        
        topChartImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topChartImageView)
        
        NSLayoutConstraint.activate([
            topChartImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topChartImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topChartImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topChartImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        guard let url = URL(string: imageQuality) else {
            
            topChartImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
        
        topChartImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
    }
}
