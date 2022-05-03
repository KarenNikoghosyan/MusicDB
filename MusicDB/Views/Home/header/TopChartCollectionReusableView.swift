//
//  GenresCollectionReusableView.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/06/2021.
//

import UIKit

class TopChartCollectionReusableView: UICollectionReusableView {
     
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Top Tracks"
        label.textColor = .white
        
        addSubview(label)
        
        let button = createViewAllButton(label: label)
        button.addTarget(self, action: #selector(topTracksViewAllTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    @IBAction func topTracksViewAllTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: .ToViewAll, object: nil, userInfo: ["viewAll" : "Top Tracks", "genre" : "/0/tracks"])
    }
    
}
