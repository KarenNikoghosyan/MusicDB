//
//  HomeMusicCollectionViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 17/06/2021.
//

import UIKit
import ViewAnimator
import SafariServices
import PKHUD
import Loaf
import SwiftUI

class HomeMusicCollectionViewController: UICollectionViewController {
    
    private let homeViewModel = HomeViewModel()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeViewModel.delegate = self

        checkConnection()
        setupObservers()
        setupCells()
        setupHeaders()
        
        collectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setTabBarSwipe(enabled: true)
        
        if tabBarController?.tabBar.isHidden == true {
            tabBarController?.tabBar.setIsHidden(false, animated: true)
        }
        if navigationController?.navigationBar.barTintColor == .white {
            navigationController?.navigationBar.barTintColor = UIColor(red: 33.0 / 255, green: 33.0 / 255, blue: 33.0 / 255, alpha: 1)
        }
    }
    
    @IBAction private func settingsTapped(_ sender: UIBarButtonItem) {
        Loaf.dismiss(sender: self, animated: true)
        
        navigationController?.navigationBar.barTintColor = .white
        tabBarController?.tabBar.setIsHidden(true, animated: true)
        setTabBarSwipe(enabled: false)
        performSegue(withIdentifier: homeViewModel.toSettingsText, sender: nil)
    }
    
    //Sign out button
    @IBAction private func signOut(_ sender: UIBarButtonItem) {
        logOutTappedAndSegue()
    }
    
    @IBSegueAction private func addSettingsView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: SettingsView())
    }
}

//MARK: - Compositional Layout(CollectionView) Functions
extension HomeMusicCollectionViewController {
    
    //Creates the compositional layout depending on the section's index
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout {[weak self] (sectionNumber, env) -> NSCollectionLayoutSection? in

            switch sectionNumber {
                
                case 0: return self?.chartLayoutSection()
                case 4: return self?.topArtistsSection()
                case 7: return self?.topAlbumsSection()
                default: return self?.tracksLayoutSection()
                
            }
        }
    }
    
    //Compositional layout styles
    private func chartLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.bottom = 12

        //Resizing the cells based on a device
        var size: CGFloat = 350
        switch UIDevice().type {
        case .iPod7:
            size = 250
        case .iPhoneSE2:
            size = 250
        case .iPhone8:
            size = 250
        case .iPhone12ProMax:
            size = 350
        default:
            size = 320
        }
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(size), heightDimension: .absolute(size))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 2)

        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets.leading = 8
        
        let layoutSectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [layoutSectionHeader]

        return section
    }
    
    private func tracksLayoutSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.bottom = 12
        
        //Resizing the cells based on a device
        var sizeWidth: CGFloat = 150
        var sizeHeight: CGFloat = 165
        switch UIDevice().type {
        case .iPod7:
            sizeWidth = 100
            sizeHeight = 115
        case .iPhoneSE2:
            sizeWidth = 100
            sizeHeight = 115
        case .iPhone8:
            sizeWidth = 100
            sizeHeight = 115
        case .iPhone12ProMax:
            sizeWidth = 150
            sizeHeight = 165
        default:
            sizeWidth = 150
            sizeHeight = 165
        }
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(sizeWidth), heightDimension: .absolute(sizeHeight))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 2)
       
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets.leading = 8
        
        let layoutSectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [layoutSectionHeader]
        
        return section
    }
    
    private func topArtistsSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.33))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(200))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets.leading = 8
        
        let layoutSectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [layoutSectionHeader]

        return section
    }
    
    private func topAlbumsSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.33))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .absolute(230))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets.leading = 8

        let layoutSectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [layoutSectionHeader]

        return section
    }
    
    //Creates the header for eash section
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        return layoutSectionHeader
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
    }

    //Section number of cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return homeViewModel.topTracks.count
        case 1:
            return homeViewModel.hipHop.count
        case 2:
            return homeViewModel.dance.count
        case 3:
            return homeViewModel.jazz.count
        case 4:
            return homeViewModel.topArtists.count
        case 5:
            return homeViewModel.pop.count
        case 6:
            return homeViewModel.classical.count
        case 7:
            return homeViewModel.topAlbums.count
        default:
            return homeViewModel.rock.count
        }
    }

    //Populates the cells
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < homeViewModel.topTracks.count {
                let track = homeViewModel.topTracks[indexPath.item]
                cell.configure(track: track, with: "\(track.album?.coverBig ?? "")")
            }
            return cell
            
        case 1:
            let cell = populateHomeTracksCell(indexPath: indexPath)

            if indexPath.item < homeViewModel.hipHop.count {
                let track = homeViewModel.hipHop[indexPath.item]
                cell.configure(track: track, with: "\(track.album?.cover ?? homeViewModel.noImageFoundText)")
            }
            return cell
            
        case 2:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < homeViewModel.dance.count {
                let track = homeViewModel.dance[indexPath.item]
                cell.configure(track: track, with: "\(track.album?.cover ?? homeViewModel.noImageFoundText)")
            }
            return cell
            
        case 3:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < homeViewModel.jazz.count {
                let track = homeViewModel.jazz[indexPath.item]
                cell.configure(track: track, with: "\(track.album?.cover ?? homeViewModel.noImageFoundText)")
            }
            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopArtistsCollectionViewCell.reuseIdentifier, for: indexPath) as! TopArtistsCollectionViewCell
            
            if indexPath.item < homeViewModel.topArtists.count {
                let artist = homeViewModel.topArtists[indexPath.item]
                cell.configure(artist: artist)
            }
            return cell
            
        case 5:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < homeViewModel.pop.count {
                let track = homeViewModel.pop[indexPath.item]
                cell.configure(track: track, with: "\(track.album?.cover ?? homeViewModel.noImageFoundText)")
            }
            return cell
            
        case 6:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < homeViewModel.classical.count {
                let track = homeViewModel.classical[indexPath.item]
                cell.configure(track: track, with: "\(track.album?.cover ?? homeViewModel.noImageFoundText)")
            }
            return cell
            
        case 7:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopAlbumsCollectionViewCell.reuseIdentifier, for: indexPath) as! TopAlbumsCollectionViewCell
            
            if indexPath.item < homeViewModel.topAlbums.count {
                let album = homeViewModel.topAlbums[indexPath.item]
                cell.configure(album: album)
            }
            return cell
            
        default:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < homeViewModel.rock.count {
                let track = homeViewModel.rock[indexPath.item]
                cell.configure(track: track, with: "\(track.album?.cover ?? homeViewModel.noImageFoundText)")
            }
            return cell
        }
    }
    
    private func populateHomeTracksCell(indexPath: IndexPath) -> HomeTracksCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeTracksCollectionViewCell
        return cell
    }
    
    //Populates the headers
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch indexPath.section {
        case 0:
            return populateHeaders(headerID: homeViewModel.topChartHeader, kind: kind, indexPath: indexPath)
        case 1:
            return populateHeaders(headerID: homeViewModel.hipHopHeader, kind: kind, indexPath: indexPath)
        case 2:
            return populateHeaders(headerID: homeViewModel.danceHeader, kind: kind, indexPath: indexPath)
        case 3:
            return populateHeaders(headerID: homeViewModel.jazzHeader, kind: kind, indexPath: indexPath)
        case 4:
            return populateHeaders(headerID: homeViewModel.topArtistsHeader, kind: kind, indexPath: indexPath)
        case 5:
            return populateHeaders(headerID: homeViewModel.popHeader, kind: kind, indexPath: indexPath)
        case 6:
            return populateHeaders(headerID: homeViewModel.classicalHeader, kind: kind, indexPath: indexPath)
        case 7:
            return populateHeaders(headerID: homeViewModel.topAlbumsHeader, kind: kind, indexPath: indexPath)
        default:
            return populateHeaders(headerID: homeViewModel.rockHeader, kind: kind, indexPath: indexPath)
        }
    }
    
    private func populateHeaders(headerID: String, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath)
        return reusableView
    }
    
    //Tap animation effect
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            if let cell = collectionView.cellForItem(at: indexPath) as? HomeTracksCollectionViewCell {
                cell.imageView.transform = .init(scaleX: 0.97, y: 0.97)
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TopArtistsCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TopAlbumsCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            if let cell = collectionView.cellForItem(at: indexPath) as? HomeTracksCollectionViewCell {
                cell.imageView.transform = .identity
                cell.contentView.backgroundColor = .clear
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TopArtistsCollectionViewCell {
                cell.imageView.transform = .identity
                cell.name.transform = .identity
                cell.contentView.backgroundColor = .clear
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TopAlbumsCollectionViewCell {
                cell.imageView.transform = .identity
                cell.subtitle.transform = .identity
                cell.contentView.backgroundColor = .clear
            }
        }
    }
    
    //Segue to another screen depending on the section
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        
        case 0:
            toDetailsSegue(tracks: homeViewModel.topTracks, indexPath: indexPath)
        case 1:
            toDetailsSegue(tracks: homeViewModel.hipHop, indexPath: indexPath)
        case 2:
            toDetailsSegue(tracks: homeViewModel.dance, indexPath: indexPath)
        case 3:
            toDetailsSegue(tracks: homeViewModel.jazz, indexPath: indexPath)
        case 4:
            Loaf.dismiss(sender: self, animated: true)
            let topArtists = homeViewModel.topArtists[indexPath.item]
            
            guard let url = URL(string: "\(topArtists.link)") else {return}
            let sfVC = SFSafariViewController(url: url)
            present(sfVC, animated: true)
            
        case 5:
            toDetailsSegue(tracks: homeViewModel.pop, indexPath: indexPath)
        case 6:
            toDetailsSegue(tracks: homeViewModel.classical, indexPath: indexPath)
        case 7:
            Loaf.dismiss(sender: self, animated: true)
            
            var indexPath = indexPath
            indexPath[0] = 0
            let dict: [String: Any] = [
                homeViewModel.albumText : homeViewModel.topAlbums[indexPath.row],
                Constants.indexPathText : indexPath,
                homeViewModel.isHomeText : true
            ]
            performSegue(withIdentifier: homeViewModel.toAlbumDetailsText, sender: dict)
        default:
            toDetailsSegue(tracks: homeViewModel.rock, indexPath: indexPath)
        }
    }
}

//MARK: - Functions
extension HomeMusicCollectionViewController {
    
    private func checkConnection() {
        //Checks the internet connection
        if !Connectivity.isConnectedToInternet {
            showAlertAndReload(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            HUD.flash(.error, delay: 0.5)
        } else {
            homeViewModel.fetchTracks()
            loadRefreshControl()
            homeViewModel.showGreetingMessage()
        }
        
        HUD.show(HUDContentType.progress, onView: self.view)
    }
    
    //Creates pull down to refresh
    private func loadRefreshControl() {
        guard let font = UIFont.init(name: Constants.futuraBold, size: 13) else {return}
        
        let attributes: [NSAttributedString.Key: AnyObject] = [.foregroundColor : UIColor.systemGreen, .font : font]
        refreshControl.attributedTitle = NSAttributedString(string: homeViewModel.fetchingTracksText, attributes: attributes)
        refreshControl.tintColor = .systemGreen
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.backgroundView = refreshControl
        }
    }
    
    //Refreshes the data
    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            collectionView.refreshControl?.endRefreshing()
            return
        }
        homeViewModel.fetchTracks()
    }
    
    private func setupObservers() {
        //Gets the button action from the corresponding cell
        NotificationCenter.default.addObserver(forName: .ToViewAll, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if !Connectivity.isConnectedToInternet {
                self.showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
                return
            }
            
            if let viewAll = notification.userInfo?[self.homeViewModel.viewAll] as? String,
               let genre = notification.userInfo?[self.homeViewModel.genre] as? String {
                
                Loaf.dismiss(sender: self, animated: true)
                self.performSegue(withIdentifier: self.homeViewModel.toGenreText, sender: [viewAll, genre])
            }
        }
        NotificationCenter.default.addObserver(forName: .MoveToLogin, object: nil, queue: .main) {[weak self] _ in
            self?.logOutTappedAndSegue()
        }
    }
    
    private func setupCells() {
        //Registers the cells
        collectionView.register(HomeTracksCollectionViewCell.self, forCellWithReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier)
        collectionView.register(TopArtistsCollectionViewCell.self, forCellWithReuseIdentifier: TopArtistsCollectionViewCell.reuseIdentifier)
        collectionView.register(TopAlbumsCollectionViewCell.self, forCellWithReuseIdentifier: TopAlbumsCollectionViewCell.reuseIdentifier)
    }
    
    private func setupHeaders() {
        //Register the headers
        collectionView.register(TopChartCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: homeViewModel.topChartHeader)
        collectionView.register(HipHopCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: homeViewModel.hipHopHeader)
        collectionView.register(DanceCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: homeViewModel.danceHeader)
        collectionView.register(JazzCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: homeViewModel.jazzHeader)
        collectionView.register(TopArtistsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: homeViewModel.topArtistsHeader)
        collectionView.register(PopCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: homeViewModel.popHeader)
        collectionView.register(ClassicalCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: homeViewModel.classicalHeader)
        collectionView.register(TopAlbumsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: homeViewModel.topAlbumsHeader)
        collectionView.register(RockCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: homeViewModel.rockHeader)
    }
        
    private func toDetailsSegue(tracks: [Track], indexPath: IndexPath) {
        Loaf.dismiss(sender: self, animated: true)
 
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        let track = tracks[indexPath.item]
        performSegue(withIdentifier: homeViewModel.toDetailsText, sender: track)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == homeViewModel.toDetailsText {
            guard let dest = segue.destination as? UINavigationController,
                  let targetController = dest.topViewController as? DetailsMusicViewController,
                  let track = sender as? Track else {return}

            targetController.track = track
     
        } else if segue.identifier == homeViewModel.toGenreText {
            guard let dest = segue.destination as? UINavigationController,
                  let targetController = dest.topViewController as? GenreMusicViewController,
                  let data = sender as? [String] else {return}
     
            targetController.genreViewModel.titleGenre = data[0]
            targetController.genreViewModel.path = data[1]
     
        } else if segue.identifier == homeViewModel.toAlbumDetailsText {
            guard let dest = segue.destination as? UINavigationController,
                  let targetController = dest.topViewController as? AlbumDetailsViewController,
                  let data = sender as? Dictionary<String, Any> else {return}
     
            targetController.albumDetailsViewModel.album = data[homeViewModel.albumText] as? TopAlbums
            targetController.albumDetailsViewModel.indexPath = data[Constants.indexPathText] as? IndexPath
            targetController.albumDetailsViewModel.isHome = data[homeViewModel.isHomeText] as? Bool
        }
    }
}

//MARK: - Alert
extension HomeMusicCollectionViewController {
    
    private func showAlertAndReload(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: Constants.retryText, style: .cancel, handler: {[weak self] action in
            guard let self = self else {return}
            
            if !Connectivity.isConnectedToInternet {
                self.showAlertAndReload(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            } else {
                self.homeViewModel.fetchTracks()
                self.homeViewModel.showGreetingMessage()
                self.loadRefreshControl()
            }
        }))
        present(vc, animated: true)
    }
}

extension HomeMusicCollectionViewController: HomeViewModelDelegate {
    
    //Animates the sections
    func loadSectionAndAnimation(in section: Int) {
        homeViewModel.counter += 1
        collectionView.reloadSections([section])
        
        let animation = AnimationType.from(direction: .right, offset: 30.0)
        let cells = collectionView.visibleCells(in: section)
        UIView.animate(views: cells, animations: [animation])
        
        if homeViewModel.counter == collectionView.numberOfSections {
            homeViewModel.counter = 0
            HUD.flash(.success, delay: 0.5)
            refreshControl.endRefreshing()
        }
    }
    
    func loadLoafMessage(name: String) {
        loafMessageWelcome(name: name)
    }
}
