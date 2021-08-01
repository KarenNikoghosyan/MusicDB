//
//  SearchMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/06/2021.
//

import UIKit
import ViewAnimator

class SearchMusicViewController: BaseTableViewController {
   
    let searchLabel = UILabel()
    let noTracksLabel = UILabel()
    
    @IBOutlet weak var trackSearchBar: UISearchBar!
    @IBOutlet weak var searchTracksTableView: UITableView!
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTapped()
        
        trackSearchBar.delegate = self
        searchTracksTableView.delegate = self
        searchTracksTableView.dataSource = self
                
        setupNavigationItems()
        
        loadSearchLabel()
        loadNoTracksLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackSearchBar.becomeFirstResponder()
        setTabBarSwipe(enabled: true)
    }
    
    func loadSearchLabel() {
        trackSearchBar.searchTextField.textColor = .white
        trackSearchBar.searchTextField.leftView?.tintColor = .white
        
        searchLabel.text = "Search for artists, songs and more."
        searchLabel.font = UIFont.init(name: "Futura", size: 18)
        searchLabel.textColor = .white
        
        view.addSubview(searchLabel)
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func loadNoTracksLabel() {
        noTracksLabel.text = "No Tracks Found"
        noTracksLabel.font = UIFont.init(name: "Futura", size: 20)
        noTracksLabel.textColor = .white
        noTracksLabel.textAlignment = .center
        
        view.addSubview(noTracksLabel)
        
        noTracksLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noTracksLabel.topAnchor.constraint(equalTo: searchTracksTableView.topAnchor, constant: 24),
            noTracksLabel.leadingAnchor.constraint(equalTo: searchTracksTableView.leadingAnchor, constant: 0),
            noTracksLabel.trailingAnchor.constraint(equalTo: searchTracksTableView.trailingAnchor, constant: 0)
        ])
        noTracksLabel.isHidden = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let cell = cell as? SearchMusicTableViewCell {
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
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? DetailsMusicViewController,
              let track = sender as? Track else {return}
        
        targetController.track = track
    }
}

extension SearchMusicViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
            perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.5)
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        loadActivityIndicator()
        self.searchLabel.isHidden = true
        
        tracks.removeAll()
        searchTracksTableView.reloadData()
        
        guard let text = searchBar.text else {return}
        
        if text.count <= 0 {
            activityIndicatorView.stopAnimating()
            searchLabel.isHidden = false
            noTracksLabel.isHidden = true
            return
        }
        
        let animation = AnimationType.from(direction: .top, offset: 30.0)
        
        ds.fetchTracks(from: .search, id: nil, path: nil, with: ["q":text]) {[weak self] tracks, error in
                if let tracks = tracks {
                    guard let self = self else {return}
                    
                    self.tracks = tracks
                    self.searchTracksTableView.reloadData()
                    
                    self.searchTracksTableView.animate(animations: [animation])
                    self.activityIndicatorView.stopAnimating()
                    
                    if tracks.count <= 0 {
                        self.noTracksLabel.isHidden = false
                    } else {
                        self.noTracksLabel.isHidden = true
                    }
                    
                } else if let error = error {
                    print(error)
                    self?.activityIndicatorView.stopAnimating()
                }
            }
    }
}
