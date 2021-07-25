//
//  GenreMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/07/2021.
//

import UIKit
import Firebase
import FirebaseFirestore

class GenreMusicViewController: BaseTableViewController {
    
    var titleGenre: String?
    var tracks: [Track] = []
    var ds = GenreAPIDataSource()
    var path: String = ""

    @IBOutlet weak var genreTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        NotificationCenter.default.addObserver(forName: .IndexAdd, object: nil, queue: .main) {[weak self] notification in
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                guard let track = self?.tracks[indexPath.row] else {return}
                
                self?.addTrack(track: track, userID: userID)
                self?.loafMessageAdded()
            }
        }
        NotificationCenter.default.addObserver(forName: .IndexRemove, object: nil, queue: .main) {[weak self] notification in
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                guard let track = self?.tracks[indexPath.row] else {return}
                
                self?.removeTrack(track: track, userID: userID)
                self?.loafMessageRemoved()
            }
        }
        
        if Connectivity.isConnectedToInternet {
            fetchTracks()
            loadActivityIndicator()
        }
        
        genreTableView.delegate = self
        genreTableView.dataSource = self
        
        let nib = UINib(nibName: "LikedGenreTableViewCell", bundle: .main)
        genreTableView.register(nib, forCellReuseIdentifier: "cell")
        
        self.title = titleGenre
        setupNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
        }
    }
    
    func fetchTracks() {
        ds.fetchGenres(from: .chart, with: path, with: ["limit" : 150]) {[weak self] tracks, error in
            if let tracks = tracks {
                guard let self = self else {return}
                
                self.tracks = tracks
                self.genreTableView.reloadData()
                self.activityIndicatorView.stopAnimating()
                
                let cells = self.genreTableView.visibleCells
                UIView.animate(views: cells, animations: [self.animation])
            } else if let error = error {
                print(error)
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func setupNavigationItems() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        genreTableView.separatorColor = UIColor.darkGray
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
        cell.tintColor = .white

        if let cell = cell as? LikedGenreTableViewCell {
            let track = tracks[indexPath.row]
            
            cell.populate(track: track)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        performSegue(withIdentifier: "toDetails", sender: tracks[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let track = sender as? Track,
              let dest = segue.destination as? DetailsMusicViewController else {
            return
        }
        dest.track = track
    }
}

extension GenreMusicViewController {
    func showAlertWithActions(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: "Retry", style: .cancel, handler: {[weak self] action in
            if !Connectivity.isConnectedToInternet {
                self?.showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
             } else {
                self?.fetchTracks()
                self?.loadActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
}
