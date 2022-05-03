//
//  RapHipHopCollectionReusableView.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 28/06/2021.
//

import UIKit

class RockCollectionReusableView: UICollectionReusableView {
      
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Rock"
        label.textColor = .white
        
        addSubview(label)
        
        let button = createViewAllButton(label: label)
        button.addTarget(self, action: #selector(rockViewAllTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    @IBAction func rockViewAllTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: .ToViewAll, object: nil, userInfo: ["viewAll" : "Rock", "genre" : "/152/tracks"])
    }
}
