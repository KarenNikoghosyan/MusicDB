//
//  GenreMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/07/2021.
//

import UIKit
import Loaf

class GenreMusicViewController: BaseViewController {
    
    let genreViewModel = GenreViewModel()

    @IBOutlet private weak var genreTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Checks the connectivity status when the screen appears.
        if Connectivity.isConnectedToInternet {
            genreViewModel.addObservers()
            genreViewModel.fetchTracks()
            loadActivityIndicator()
        }
        
        setupDelegates()
        setupNib()
        setupNavigationControllerTitle()
        setupNavigationItems(tableView: genreTableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Connectivity.isConnectedToInternet {
            showAlertWithActions(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
        }
    }
    
    @IBAction private func backButtonTapped(_ sender: UIBarButtonItem) {
        Loaf.dismiss(sender: self, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: Functions
extension GenreMusicViewController {
    
    private func setupDelegates() {
        genreViewModel.delegate = self
        genreTableView.delegate = self
        genreTableView.dataSource = self
    }
    
    private func setupNib() {
        let nib = UINib(nibName: genreViewModel.cellNib, bundle: .main)
        genreTableView.register(nib, forCellReuseIdentifier: Constants.cellIdentifier)
    }
    
    private func setupNavigationControllerTitle() {
        self.title = genreViewModel.titleGenre
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        let dict: [String : Any] = [
            genreViewModel.trackText : genreViewModel.tracks[indexPath.row],
            Constants.indexPathText : indexPath,
            genreViewModel.isGenreText : true
        ]
        Loaf.dismiss(sender: self, animated: true)
        performSegue(withIdentifier: genreViewModel.toDetailsText, sender: dict)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? UINavigationController,
              let targetController = dest.topViewController as? DetailsMusicViewController,
              let data = sender as? Dictionary<String, Any> else {return}
        
        targetController.track = data[genreViewModel.trackText] as? Track
        targetController.indexPath = data[Constants.indexPathText] as? IndexPath
        targetController.isGenre = data[genreViewModel.isGenreText] as? Bool
    }
    
    private func showAlertWithActions(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: Constants.retryText, style: .cancel, handler: {[weak self] action in
            guard let self = self else {return}
            
            if !Connectivity.isConnectedToInternet {
                self.showAlertWithActions(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
             } else {
                self.genreViewModel.fetchTracks()
                self.loadActivityIndicator()
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
        return genreViewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        
        accessoryArrow(cell: cell)

        if let cell = cell as? LikedGenreTableViewCell {
            let track = genreViewModel.tracks[indexPath.row]
            
            cell.populate(track: track)
            cell.cellConstraints()
        }
        
        return cell
    }
}

extension GenreMusicViewController: GenreViewModelDelegate {
    func reloadTableViewData() {
        self.genreTableView.reloadData()
    }
    
    func reloadTableViewRows(indexPath: IndexPath) {
        self.genreTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func stopAnimation() {
        self.activityIndicatorView.stopAnimating()
    }
    
    func animateCells() {
        let cells = self.genreTableView.visibleCells
        UIView.animate(views: cells, animations: [self.animation])
    }
    
    func addLoafMessage(track: Track) {
        self.loafMessageAdded(track: track)
    }
    
    func removeLoafMessage(track: Track) {
        self.loafMessageRemoved(track: track)
    }
}
