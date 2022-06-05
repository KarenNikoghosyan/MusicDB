//
//  SearchMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/06/2021.
//

import UIKit
import ViewAnimator

class SearchMusicViewController: BaseViewController {
    
    private let searchViewModel = SearchMusicViewModel()
    
    @IBOutlet private weak var trackSearchBar: UISearchBar!
    @IBOutlet private weak var searchTracksTableView: UITableView!
    
    private let searchLabel = UILabel()
    private let noTracksLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTapped()

        setupDelegates()
        setupNavigationItems()
        setupSearchLabel()
        setupNoTracksLabel()
        dismissKeyboardOnScroll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        trackSearchBar.becomeFirstResponder()
        setTabBarSwipe(enabled: true)
    }
    
    @IBAction private func signOut(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
}

//MARK: - Functions
extension SearchMusicViewController {
    
    private func setupDelegates() {
        searchTracksTableView.dataSource = self
        searchTracksTableView.delegate = self
        trackSearchBar.delegate = self
        searchViewModel.searchDelegate = self
    }
    
    private func setupSearchLabel() {
        trackSearchBar.searchTextField.textColor = .white
        trackSearchBar.searchTextField.leftView?.tintColor = .white
        
        //Creates a label, and will be only shows when the search bar is empty
        searchLabel.text = searchViewModel.searchForArtistsText
        searchLabel.font = UIFont.init(name: Constants.futura, size: 18)
        searchLabel.textColor = .white
        
        view.addSubview(searchLabel)
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupNoTracksLabel() {
        //Creates a label, and will be only shown if no tracks were found
        noTracksLabel.text = searchViewModel.noTracksFoundText
        noTracksLabel.font = UIFont.init(name: Constants.futura, size: 20)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? DetailsMusicViewController,
              let track = sender as? Track else {return}
        
        targetController.detailsMusicViewModel.track = track
    }
    
    private func dismissKeyboardOnScroll() {
        searchTracksTableView.keyboardDismissMode = .onDrag
    }
}

//MARK: - UITableView Functions
extension SearchMusicViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        performSegue(withIdentifier: searchViewModel.toDetailsIdentifier, sender: searchViewModel.searchTracks[indexPath.row])
    }
}

//MARK: - DataSources
extension SearchMusicViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.searchTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchViewModel.searchCellIdentifier, for: indexPath)
        
        if let cell = cell as? SearchMusicTableViewCell {
            let track = searchViewModel.searchTracks[indexPath.row]
            cell.populate(track: track)
        }
        
        return cell
    }
}

//MARK: - Delegates
extension SearchMusicViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        
        //Adds a delay, when the user stops typing the func will run after 0.5 seconds to prevent unnecessary network calls
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.5)
    }
    
    @objc private func reload(_ searchBar: UISearchBar) {
        setupActivityIndicator()
        self.searchLabel.isHidden = true
        
        searchViewModel.searchTracks.removeAll()
        searchTracksTableView.reloadData()
        
        guard let text = searchBar.text else {return}
        
        //Shows a label when the search bar is empty
        if text.count <= 0 {
            activityIndicatorView.stopAnimating()
            searchLabel.isHidden = false
            noTracksLabel.isHidden = true
            return
        }
        
        searchViewModel.fetchTracks(text: text)
    }
}

extension SearchMusicViewController: SearchMusicViewModelDelegate {
    func searchInitiated(tracks: [Track]) {
        
        self.searchTracksTableView.reloadData()
        
        let animation = AnimationType.from(direction: .top, offset: 30.0)
                
        //Loads the cells with animation
        let cells = self.searchTracksTableView.visibleCells
        UIView.animate(views: cells, animations: [animation])
        self.activityIndicatorView.stopAnimating()
        
        if tracks.count <= 0 {
            self.noTracksLabel.isHidden = false
        } else {
            self.noTracksLabel.isHidden = true
        }
    }
    
    func stopAnimation() {
        self.activityIndicatorView.stopAnimating()
    }
}
