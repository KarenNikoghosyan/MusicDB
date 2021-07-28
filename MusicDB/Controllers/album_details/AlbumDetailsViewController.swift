//
//  AlbumDetailsViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import UIKit
import SDWebImage
import ViewAnimator
import SafariServices

class AlbumDetailsViewController: BaseTableViewController {
    var album: TopAlbums?
    var tracks: [AlbumTrack] = []
    let ds = AlbumTrackAPIDataSource()
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var tracksTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Connectivity.isConnectedToInternet {
            fetchTracks()
            loadActivityIndicator()
        }
        
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        
        guard let album = album else {return}

        self.title = album.title
        guard let str = album.coverBig,
              let url = URL(string: str) else {
            
            setUpImageView()
            albumImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            return
        }
    
        setUpImageView()
        albumImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        albumImageView.sd_setImage(with: url)

        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let cell = cell as? AlbumDetailsTableViewCell,
           let album = album {
            
            let track = tracks[indexPath.row]
            cell.populate(album: album, track: track)
        }
        return cell
    }
    
    func setUpImageView() {
        albumImageView.tintColor = .white
        albumImageView.layer.cornerRadius = 15
        albumImageView.layer.masksToBounds = true
    }
    
    func fetchTracks() {
        guard let album = album else {return}

        let start = album.tracklist.index(album.tracklist.startIndex, offsetBy: 28)
        let end = album.tracklist.index(album.tracklist.endIndex, offsetBy: 0)
        let result = album.tracklist[start..<end] // The result is of type Substring
        let newTrackList = String(result)
        
        ds.fetchTracks(from: .album, path: newTrackList, with: ["limit" : 100]) {[weak self] tracks, error in
            guard let self = self else {return}
            
            if let tracks = tracks {
                self.tracks = tracks
                self.tracksTableView.reloadData()
                
                let cells = self.tracksTableView.visibleCells
                UIView.animate(views: cells, animations: [self.animation])
                self.activityIndicatorView.stopAnimating()
                
            } else if let error = error {
                print(error)
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    override func loadActivityIndicator() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.centerYAnchor.constraint(equalTo: tracksTableView.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: tracksTableView.centerXAnchor)
        ])
        
        activityIndicatorView.startAnimating()
    }
}
