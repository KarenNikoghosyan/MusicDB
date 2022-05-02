//
//  TopArtistsCollectionReusableView.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 28/06/2021.
//

import UIKit

class TopArtistsCollectionReusableView: UICollectionReusableView {
        
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Top Artists"
        label.textColor = .white
        
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}
