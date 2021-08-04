//
//  BaseTableViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/07/2021.
//

import UIKit
import NVActivityIndicatorView
import ViewAnimator
import SafariServices
import Loaf

class BaseTableViewController: UIViewController {
    
    var tableView = UITableView()
    var prevIndexPath: IndexPath?
    var prevButton: UIButton = UIButton()
    var arrIndexPaths: [IndexPath] = []
    var isPlaying: Bool = false
    
    var tracks: [Track] = []
    var albums: [TopAlbums] = []
    var albumTracks: [AlbumTrack] = []
    
    let ds = TrackAPIDataSource()
    
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .systemGreen, padding: 0)
    let animation = AnimationType.from(direction: .right, offset: 30.0)

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
    
    func accessoryArrow(cell: UITableViewCell) {
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
        cell.tintColor = .white
    }
    
    func openWebsite(albums: [TopAlbums], sender: UIButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let selectedIndexPath = IndexPath.init(row: sender.tag, section: 0)
        let album = albums[selectedIndexPath.row]
        
        guard let url = URL(string: "\(album.link)") else {return}
        let sfVC = SFSafariViewController(url: url)
        Loaf.dismiss(sender: self, animated: true)
        self.present(sfVC, animated: true)
    }
    
    func populateCell(indexPath: IndexPath, cell: DetailsTableViewCell, tableView: UITableView) {
        
        self.tableView = tableView
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(btnTapped(_:)), for: .touchUpInside)
        
        if arrIndexPaths.contains(indexPath) {
            cell.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            cell.playButton.tintColor = .white
        } else {
            cell.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            cell.playButton.tintColor = .darkGray
        }
    }
    
    @IBAction func btnTapped(_ sender: UIButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let selectedIndexPath = IndexPath.init(row: sender.tag, section: 0)
        
        if arrIndexPaths.contains(selectedIndexPath) {
            arrIndexPaths.removeAll()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            sender.tintColor = .darkGray
            
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
            MediaPlayer.shared.stopAudio()
            return
        }
        
        if arrIndexPaths.count == 1 {
            arrIndexPaths.removeAll()
            prevButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
            if let prevIndexPath = prevIndexPath {
                tableView.reloadRows(at: [prevIndexPath], with: .none)
            }
            MediaPlayer.shared.stopAudio()
        }
        
        prevIndexPath = selectedIndexPath
        prevButton = sender
        arrIndexPaths.append(selectedIndexPath)
        tableView.reloadRows(at: [selectedIndexPath], with: .none)
        
        if !albumTracks.isEmpty {
            let albumTrack = albumTracks[selectedIndexPath.row]
            if let urlPreview = URL(string: "\(albumTrack.preview)") {
                MediaPlayer.shared.loadAudio(url: urlPreview)
            }
        }
        
        if !tracks.isEmpty {
            let track = tracks[selectedIndexPath.row]
            if let urlPreview = URL(string: "\(track.preview)") {
                MediaPlayer.shared.loadAudio(url: urlPreview)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {[weak self] in
            MediaPlayer.shared.stopAudio()
            guard let self = self else {return}
            
            if let prevIndexPath = self.prevIndexPath {
                self.arrIndexPaths.removeAll()
                self.prevButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                self.tableView.reloadRows(at: [prevIndexPath], with: .none)
            }
        }
    }
}

extension BaseTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            if let cell = tableView.cellForRow(at: indexPath) as? LikedGenreTableViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            } else if let cell = tableView.cellForRow(at: indexPath) as? AlbumsTableViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            } else if let cell = tableView.cellForRow(at: indexPath) as? DetailsTableViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            } else if let cell = tableView.cellForRow(at: indexPath) as? SearchMusicTableViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            if let cell = tableView.cellForRow(at: indexPath) as? LikedGenreTableViewCell {
                cell.contentView.backgroundColor = .clear
            } else if let cell = tableView.cellForRow(at: indexPath) as? AlbumsTableViewCell {
                cell.contentView.backgroundColor = .clear
            } else if let cell = tableView.cellForRow(at: indexPath) as? DetailsTableViewCell {
                cell.contentView.backgroundColor = .clear
            } else if let cell = tableView.cellForRow(at: indexPath) as? SearchMusicTableViewCell {
                cell.contentView.backgroundColor = .clear
            }
        }
    }
}
