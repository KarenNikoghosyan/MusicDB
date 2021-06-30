//
//  SearchMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/06/2021.
//

import UIKit
import ViewAnimator

class SearchMusicViewController: BaseViewController {
   
    let searchLabel = UILabel()
    let noTracksLabel = UILabel()
    
    @IBOutlet weak var trackSearchBar: UISearchBar!
    @IBOutlet weak var searchTracksCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTapped()
        
        trackSearchBar.delegate = self
        searchTracksCollectionView.delegate = self
        searchTracksCollectionView.dataSource = self
        
        let nib = UINib(nibName: "DetailsMusicCollectionViewCell", bundle: .main)
        searchTracksCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
        setupNavigationItems()
        
        loadSearchLabel()
        loadNoTracksLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackSearchBar.becomeFirstResponder()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        searchTracksCollectionView?.reloadData()
    }
    
    func setupNavigationItems() {
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
            
        label.text = "Search"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = .white
        
        label.textAlignment = .left
            
        navigationItem.titleView = label
            
        if let navigationBar = navigationController?.navigationBar {
            label.widthAnchor.constraint(equalTo: navigationBar.widthAnchor, constant: -40).isActive = true
        }
    }
    
    func loadSearchLabel() {
        trackSearchBar.searchTextField.textColor = .white
        trackSearchBar.searchTextField.leftView?.tintColor = .white
        
        searchLabel.text = "Search for artists, songs and more."
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
            noTracksLabel.topAnchor.constraint(equalTo: searchTracksCollectionView.topAnchor, constant: 24),
            noTracksLabel.leadingAnchor.constraint(equalTo: searchTracksCollectionView.leadingAnchor, constant: 0),
            noTracksLabel.trailingAnchor.constraint(equalTo: searchTracksCollectionView.trailingAnchor, constant: 0)
        ])
        noTracksLabel.isHidden = true
    }
}

extension SearchMusicViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
            perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.5)
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        loadActivityIndicator()
        self.searchLabel.isHidden = true
        
        tracks.removeAll()
        searchTracksCollectionView.reloadData()
        
        guard let text = searchBar.text else {return}
        
        if text.count <= 0 {
            activityIndicatorView.stopAnimating()
            searchLabel.isHidden = false
            noTracksLabel.isHidden = true
            return
        }
        
        let animation = AnimationType.from(direction: .top, offset: 30.0)
        
        ds.fetchTrucks(from: .search, id: nil, path: nil, with: ["q":text]) {[weak self] tracks, error in
                if let tracks = tracks {
                    guard let self = self else {return}
                    
                    self.tracks = tracks
                    self.searchTracksCollectionView.reloadData()
                    
                    self.searchTracksCollectionView.animate(animations: [animation])
                    self.activityIndicatorView.stopAnimating()
                    
                    if tracks.count <= 0 {
                        self.noTracksLabel.isHidden = false
                    } else {
                        self.noTracksLabel.isHidden = true
                    }
                    
                } else if let error = error {
                    //TODO: Popup message
                    print(error)
                    self?.activityIndicatorView.stopAnimating()
                }
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let track = tracks[indexPath.item]
        performSegue(withIdentifier: "toDetails", sender: track)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? DetailsMusicViewController,
              let track = sender as? Track else {return}
        
        dest.track = track
    }
}
