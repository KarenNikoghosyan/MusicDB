//
//  LikedMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 10/07/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Loaf

class LikedMusicViewController: BaseTableViewController {
    
    let noLikedLabel = UILabel()
    let ds = SingleTrackAPIDataSource()
    let db = Firestore.firestore()
    var tracks: [Track] = []
    var tracksIDs: [Int]?
    
    var numOfCalls: Int = 0
    var i: Int = 0
    
    @IBOutlet weak var likedTableView: UITableView!
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        showAlertAndSegue(title: "Sign out from MusicDB?", message: "You're about to sign out, do you want to proceed?")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Connectivity.isConnectedToInternet {
            getUserLikedTracks()
            loadActivityIndicator()
        }
        
        likedTableView.delegate = self
        likedTableView.dataSource = self
        
        let nib = UINib(nibName: "LikedGenreTableViewCell", bundle: .main)
        likedTableView.register(nib, forCellReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(forName: .AddTrack, object: nil, queue: .main) {[weak self] notification in
            if let track = notification.userInfo?["track"] as? Track {
                guard let self = self else {return}
                
                self.tracks.append(track)
                self.likedTableView.reloadData()
                
                if self.tracks.count > 0 && self.tracks.count <= 1 {
                    self.noLikedLabel.isHidden = true
                    self.likedTableView.separatorColor = UIColor.darkGray
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .RemoveTrack, object: nil, queue: .main) {[weak self] notification in
            if let track = notification.userInfo?["track"] as? Track {
                guard let self = self else {return}
                print(track)
                for (index, _) in self.tracks.enumerated() {
                    if self.tracks[index].id == track.id{
                        self.tracks.remove(at: index)
                        self.likedTableView.reloadData()
                        
                        if self.tracks.count == 0 {
                            self.noLikedLabel.isHidden = false
                        }
                        return
                    }
                }
            }
        }
        loadNoLikedLabel()
        
        likedTableView.separatorColor = UIColor.clear

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Futura-Bold", size: 16) as Any], for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTabBarSwipe(enabled: false)
        
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: "No Internet Connection", message: "Failed to connect to the internet")
        }
    }
    
    func getUserLikedTracks() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            self.tracksIDs = snapshot?.get("trackIDs") as? [Int] ?? nil
            self.numOfCalls = self.tracksIDs?.count ?? 0

            self.fetchTracks()
        }
    }
    
    func fetchTracks() {
        if tracksIDs?.count == 0 {
            activityIndicatorView.stopAnimating()
            noLikedLabel.isHidden = false
            return
        }
        
        ds.fetchTracks(from: .track, id: tracksIDs?[i], with: ["limit" : 100]) {[weak self] track, error in
            if let track = track {
                guard let self = self else {return}
                self.i += 1
                self.tracks.append(track)
                
                self.numOfCalls -= 1
                if self.numOfCalls > 0 {
                    self.fetchTracks()
                } else {
                    self.i = 0
                    
                    self.likedTableView.separatorColor = UIColor.darkGray
                    self.likedTableView.reloadData()
                    
                    let cells = self.likedTableView.visibleCells
                    UIView.animate(views: cells, animations: [self.animation])
                    self.activityIndicatorView.stopAnimating()
                }
                
            } else if let error = error {
                print(error)
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func loadNoLikedLabel() {
        noLikedLabel.text = "No liked tracks, start adding some."
        noLikedLabel.font = UIFont.init(name: "Futura", size: 18)
        noLikedLabel.textColor = .white
        
        view.addSubview(noLikedLabel)
        noLikedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noLikedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noLikedLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noLikedLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        noLikedLabel.isHidden = true
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        let status = navigationItem.leftBarButtonItem?.title
        
        if status == "Edit" {
            likedTableView.setEditing(true, animated: true)
            navigationItem.leftBarButtonItem?.title = "Done"
        } else {
            likedTableView.setEditing(false, animated: true)
            navigationItem.leftBarButtonItem?.title = "Edit"
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if !Connectivity.isConnectedToInternet {
                showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
                return
            }
            
            guard let userID = Auth.auth().currentUser?.uid else {return}

            Loaf("The track was removed from your liked page", state: .custom(.init(backgroundColor: .systemGreen, textColor: .white, tintColor: .white, icon: UIImage(systemName: "i.circle"), iconAlignment: .left)), location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
            
            let track = tracks[indexPath.row]
            db.collection("users").document(userID).updateData([
                "trackIDs" : FieldValue.arrayRemove([track.id as Any])
            ]) {[weak self] error in
                if let error = error {
                    print("\(error.localizedDescription)")
                }
                self?.tracks.remove(at: indexPath.item)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if self?.tracks.count == 0 {
                    self?.noLikedLabel.isHidden = false
                }
            }
        }
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

extension LikedMusicViewController {
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
