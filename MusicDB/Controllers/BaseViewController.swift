//
//  BaseViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 25/06/2021.
//

import UIKit
import NVActivityIndicatorView

class BaseViewController: UIViewController {
    var tracks: [Track] = []
    var ds = TrackAPIDataSource()
    
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .white, padding: 0)
    
    func loadActivityIndicator() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        activityIndicatorView.startAnimating()
    }
}

extension BaseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
                
        if let cell = cell as? DetailsMusicCollectionViewCell {
            let track = tracks[indexPath.item]
            cell.populate(track: track)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) {
            if let cell = collectionView.cellForItem(at: indexPath) as? DetailsMusicCollectionViewCell {
                cell.detailsTrackImageView.transform = .init(scaleX: 0.98, y: 0.98)
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) {
            if let cell = collectionView.cellForItem(at: indexPath) as? DetailsMusicCollectionViewCell {
                cell.detailsTrackImageView.transform = .identity
                cell.contentView.backgroundColor = .clear
            }
        }
    }
}

extension BaseViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height{
            return CGSize(width: collectionView.bounds.width / 6.0, height: 160)
        } else {
            return CGSize(width: collectionView.bounds.width / 3.0, height: 160)
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}