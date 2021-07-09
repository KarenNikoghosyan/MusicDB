//
//  LikedTableViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 06/07/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import ViewAnimator
import NVActivityIndicatorView
import Loaf

class LikedTableViewController: UITableViewController {
    
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .white, padding: 0)
    
    let ds = SingleTrackAPIDataSource()
    let db = Firestore.firestore()
    var tracks: [Track] = []
    var tracksIDs: [Int]?
    
    var numOfCalls: Int = 0
    var i: Int = 0
    
    //var ds = DetailsMusicViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadActivityIndicator()
        
        //ds.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clear

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Futura-Bold", size: 16) as Any], for: .normal)
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            self.tracksIDs = snapshot?.get("trackIDs") as? [Int] ?? nil
            self.numOfCalls = self.tracksIDs?.count ?? 0

            self.fetchTracks()
        }
    }
   

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
        cell.tintColor = .white

        if let cell = cell as? LikedTableViewCell {
            let track = tracks[indexPath.row]
            
            cell.populate(track: track)
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
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
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetails", sender: tracks[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let track = sender as? Track,
              let dest = segue.destination as? DetailsMusicViewController else {
            return
        }
        dest.track = track
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) {[weak self] in
            if let cell = self?.tableView.cellForRow(at: indexPath) {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) {[weak self] in
            if let cell = self?.tableView.cellForRow(at: indexPath) {
                cell.contentView.backgroundColor = .clear
            }
        }
    }
    
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
    
    func fetchTracks() {
        if tracksIDs?.count == 0 {
            activityIndicatorView.stopAnimating()
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
                    
                    let animation = AnimationType.from(direction: .right, offset: 30.0)

                    self.tableView.separatorColor = UIColor.darkGray
                    self.tableView.reloadData()
                    let cells = self.tableView.visibleCells
                    
                    UIView.animate(views: cells, animations: [animation])
                    self.activityIndicatorView.stopAnimating()
                }
                
            } else if let error = error {
                print(error)
            }
        }
    }
}

extension LikedTableViewController: LikedTracksDelegate {
    func addTrack(track: Track) {
        print("Add")
    }
    
    func removeTrack(track: Track) {
        print("Remove")
    }
}
