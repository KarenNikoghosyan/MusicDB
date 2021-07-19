//
//  UIButton+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/07/2021.
//

import UIKit

extension UICollectionReusableView {
    func createViewAllButton(label: UILabel) -> UIButton {
        let button = UIButton(type: .system)

        button.setTitle("View All", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont(name: "Futura", size: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            button.topAnchor.constraint(equalTo: label.topAnchor),
            button.bottomAnchor.constraint(equalTo: label.bottomAnchor)
        ])
        
        return button
    }
}
