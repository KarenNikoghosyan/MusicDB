//
//  PopCollectionReusableView.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 28/06/2021.
//

import UIKit

class PopCollectionReusableView: UICollectionReusableView {
        
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Pop"
        label.textColor = .white
        
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
