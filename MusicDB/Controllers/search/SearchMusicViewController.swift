//
//  SearchMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/06/2021.
//

import UIKit
import SDWebImage
import ViewAnimator
import NVActivityIndicatorView

private let reuseIdentifier = "cell"

class SearchMusicViewController: UIViewController {
    var tracks: [Track] = []
    var ds = TrackAPIDataSource()
    
    @IBOutlet weak var trackSearchBar: UISearchBar!
    @IBOutlet weak var searchTracksCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackSearchBar.delegate = self
        searchTracksCollectionView.delegate = self
        searchTracksCollectionView.dataSource = self
        
        trackSearchBar.searchTextField.textColor = .white
        trackSearchBar.searchTextField.leftView?.tintColor = .white
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        searchTracksCollectionView.reloadData()
    }
}

extension SearchMusicViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .white, padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        activityIndicatorView.startAnimating()
        
        tracks.removeAll()
        searchTracksCollectionView.reloadData()
        
        if searchText.count <= 0 {
            activityIndicatorView.stopAnimating()
            return
        }
        
        let animation = AnimationType.from(direction: .top, offset: 30.0)
        
            ds.fetchTrucks(from: .search, with: ["q":searchText]) {[weak self] tracks, error in
                if let tracks = tracks {
                    guard let self = self else {return}
                    
                    self.tracks = tracks
                    self.searchTracksCollectionView.reloadData()
                    
                    self.searchTracksCollectionView.animate(animations: [animation])
                    activityIndicatorView.stopAnimating()
                } else if let error = error {
                    //TODO: Popup message
                    print(error)
                    activityIndicatorView.stopAnimating()
                }
            }
    }
}

extension SearchMusicViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let cell = cell as? SearchTrackCollectionViewCell {
            let track = tracks[indexPath.item]
            
            if let url = URL(string: "\(track.album.cover)") {
                cell.searchTrackImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
            }
            else {
                cell.searchTrackImageView.layer.cornerRadius = 10
                cell.searchTrackImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            }
        
            cell.searchTrackImageView.layer.cornerRadius = 10
            cell.searchTrackTitle.text = track.title_short
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let track = tracks[indexPath.item]
        performSegue(withIdentifier: "toDetails", sender: track)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? DetailsMusicViewController,
              let track = sender as? Track else {return}
        
        dest.track = track
    }
}

extension SearchMusicViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height{
            return CGSize(width: collectionView.bounds.width / 6.0, height: 160)
        } else {
            return CGSize(width: collectionView.bounds.width / 3.0, height: 160)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
