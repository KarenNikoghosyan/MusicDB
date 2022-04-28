//
//  GenreMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/07/2021.
//

import UIKit
import Firebase
import Loaf

class GenreMusicViewController: BaseTableViewController {
    
    let genreDS = GenreAPIDataSource()
    
    var titleGenre: String?
    var path: String = ""

    @IBOutlet weak var genreTableView: UITableView!
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        Loaf.dismiss(sender: self, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Checks the connectivity status when the screen appears.
        if Connectivity.isConnectedToInternet {
            addObservers()
            fetchTracks()
            loadActivityIndicator()
        }
        
        genreTableView.delegate = self
        genreTableView.dataSource = self
        
        let nib = UINib(nibName: "LikedGenreTableViewCell", bundle: .main)
        genreTableView.register(nib, forCellReuseIdentifier: "cell")
        
        self.title = titleGenre
        setupNavigationItems(tableView: genreTableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let dict: [String : Any] = [
            "track" : baseViewModel.tracks[indexPath.row],
            "indexPath" : indexPath,
            "isGenre" : true
        ]
        Loaf.dismiss(sender: self, animated: true)
        performSegue(withIdentifier: "toDetails", sender: dict)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? DetailsMusicViewController,
              let data = sender as? Dictionary<String, Any> else {return}
        
        targetController.track = data["track"] as? Track
        targetController.indexPath = data["indexPath"] as? IndexPath
        targetController.isGenre = data["isGenre"] as? Bool
    }
    
    //Fetches tracks
    func fetchTracks() {
        genreDS.fetchGenres(from: .chart, with: path, with: ["limit" : 150]) {[weak self] tracks, error in
            if let tracks = tracks {
                guard let self = self else {return}
                
                self.baseViewModel.tracks = tracks
                self.genreTableView.reloadData()
                self.activityIndicatorView.stopAnimating()
                
                //Animates cells
                let cells = self.genreTableView.visibleCells
                UIView.animate(views: cells, animations: [self.animation])
            } else if let error = error {
                print(error)
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func addObservers() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        //Gets the indexpath from the button, to determine what track to add to the firestore database
        NotificationCenter.default.addObserver(forName: .IndexAdd, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                
                let track = self.baseViewModel.tracks[indexPath.row]
                FirestoreManager.shared.addTrack(track: track, userID: userID)
                self.loafMessageAdded(track: track)
            }
        }
        //Gets the indexpath from the button, to determine what track to remove to the firestore database
        NotificationCenter.default.addObserver(forName: .IndexRemove, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                
                let track = self.baseViewModel.tracks[indexPath.row]
                FirestoreManager.shared.removeTrack(track: track, userID: userID)
                self.loafMessageRemoved(track: track)
            }
        }
        //Gets the indexpath from the button, to determine what cell to reload
        NotificationCenter.default.addObserver(forName: .SendIndexPath, object: nil, queue: .main) {[weak self] notification in
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                self?.genreTableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

//Extension for an alert based on the viewcontroller
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

extension GenreMusicViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseViewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        accessoryArrow(cell: cell)

        if let cell = cell as? LikedGenreTableViewCell {
            let track = baseViewModel.tracks[indexPath.row]
            
            cell.populate(track: track)
            cell.cellConstraints()
        }
        
        return cell
    }
}
