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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var likedTableView: UITableView!
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSegmentedControl()
        
        NotificationCenter.default.addObserver(forName: .IndexRemove, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
                let track = self.tracks[indexPath.row]
                guard let userID = Auth.auth().currentUser?.uid else {return}

                self.db.collection("users").document(userID).updateData([
                    "trackIDs" : FieldValue.arrayRemove([track.id as Any])
                ]) {[weak self] error in
                    guard let self = self else {return}
                    
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.tracks.remove(at: indexPath.row)
                            self.likedTableView.deleteRows(at: [indexPath], with: .automatic)
                            self.loafMessageRemoved(track: track)
                        }
                    }
                }
            }
        }
        
        likedTableView.delegate = self
        likedTableView.dataSource = self
        
        if Connectivity.isConnectedToInternet {
            getUserLikedTracks()
            loadActivityIndicator()
        }

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
    
    func setUpSegmentedControl() {
        let tintColor = UIColor.white
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: tintColor], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.black], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentTapped(_:)), for: .valueChanged)
    }
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print(0)
        case 1:
            print(1)
        default:
            break
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
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//            print("0")
//        case 1:
//            print("1")
//        default:
//            break
//        }
        accessoryArrow(cell: cell)

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

            let track = tracks[indexPath.row]
            loafMessageRemoved(track: track)
            
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
        Loaf.dismiss(sender: self, animated: true)
        performSegue(withIdentifier: "toDetails", sender: tracks[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? DetailsMusicViewController,
              let track = sender as? Track else {return}
        targetController.track = track
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
