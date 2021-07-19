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
        
        let button = createViewAllButton(label: label)
        button.addTarget(self, action: #selector(popViewAllTapped(_:)), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func popViewAllTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: .ToViewAll, object: nil, userInfo: ["viewAll" : "Pop", "genre" : "/132/tracks"])
    }
}
