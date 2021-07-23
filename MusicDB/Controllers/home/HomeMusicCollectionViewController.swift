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
import FirebaseAuth
import FirebaseFirestore
import CoreData

class HomeMusicCollectionViewController: UICollectionViewController {
        
    var topTracks: [Track] = []
    var hipHop: [Track] = []
    var dance: [Track] = []
    var jazz: [Track] = []
    var topArtists: [TopArtists] = []
    var pop: [Track] = []
    var classical: [Track] = []
    var topAlbums: [TopAlbums] = []
    var rock: [Track] = []
    
    let db = Firestore.firestore()
    let refreshControl = UIRefreshControl()

    let tracksDS = GenreAPIDataSource()
    let topArtistsDS = TopArtistsAPIDataSource()
    let topAlbumsDS = TopAlbumsAPIDataSource()
    var counter: Int = 0
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        Loaf.dismiss(sender: self, animated: true)
        showAlertAndSegue(title: "Sign out from MusicDB?", message: "You're about to sign out, do you want to proceed?")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if !Connectivity.isConnectedToInternet {
            showAlertAndReload(title: "No Internet Connection", message: "Failed to connect to the internet")
            HUD.flash(.error, delay: 0.5)
        } else {
            fetchTracks()
            loadRefreshControl()
            greetingMessage()
        }
        
        HUD.show(HUDContentType.progress, onView: self.view)
        
        NotificationCenter.default.addObserver(forName: .ToViewAll, object: nil, queue: .main) {[weak self] notification in
            
            if !Connectivity.isConnectedToInternet {
                self?.showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
                return
            }
            guard let self = self else {return}
            
            if let viewAll = notification.userInfo?["viewAll"] as? String,
               let genre = notification.userInfo?["genre"] as? String {
                Loaf.dismiss(sender: self, animated: true)
                self.performSegue(withIdentifier: "toGenre", sender: [viewAll, genre])
            }
        }
        
        collectionView.register(HomeTracksCollectionViewCell.self, forCellWithReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier)
        collectionView.register(TopArtistsCollectionViewCell.self, forCellWithReuseIdentifier: TopArtistsCollectionViewCell.reuseIdentifier)
        collectionView.register(TopAlbumsCollectionViewCell.self, forCellWithReuseIdentifier: TopAlbumsCollectionViewCell.reuseIdentifier)
        
        collectionView.register(TopChartCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "topChartHeader")
        collectionView.register(HipHopCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "hipHopHeader")
        collectionView.register(DanceCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "danceHeader")
        collectionView.register(JazzCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "jazzHeader")
        collectionView.register(TopArtistsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "topArtistsHeader")
        collectionView.register(PopCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "popHeader")
        collectionView.register(ClassicalCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "classicalHeader")
        collectionView.register(TopAlbumsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "topAlbumsHeader")
        collectionView.register(RockCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "rockHeader")
        
        collectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       
        setTabBarSwipe(enabled: true)
    }
    
    func greetingMessage() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        db.collection("users").document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self else {return}
            
            guard let name: String = snapshot?.get("name") as? String else {return}
            
            Loaf("Welcome Back, \(name)", state: .custom(.init(backgroundColor: .systemGreen, textColor: .white, tintColor: .white, icon: UIImage(systemName: "i.circle"), iconAlignment: .left)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(3.5))
        }
    }
    
    func registrationMessage() {
        Loaf("Account was successfully created", state: .custom(.init(backgroundColor: .systemGreen, textColor: .white, tintColor: .white, icon: UIImage(systemName: "i.circle"), iconAlignment: .left)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
    }
    
    func loadRefreshControl() {
        guard let font = UIFont.init(name: "Futura-Bold", size: 13) else {return}
        
        let attributes: [NSAttributedString.Key: AnyObject] = [.foregroundColor : UIColor.systemGreen, .font : font]
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Tracks...", attributes: attributes)
        refreshControl.tintColor = .systemGreen
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.backgroundView = refreshControl
        }
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            collectionView.refreshControl?.endRefreshing()
            return
        }
        fetchTracks()
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {

        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in

         switch sectionNumber {

         case 0: return self.chartLayoutSection()
         case 4: return self.topArtistsSection()
         case 7: return self.topAlbumsSection()
         default: return self.tracksLayoutSection()
        }
    }
}
    
    private func chartLayoutSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.bottom = 12

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(350), heightDimension: .absolute(350))

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
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(165))
        
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
    
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        return layoutSectionHeader
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return topTracks.count
        case 1:
            return hipHop.count
        case 2:
            return dance.count
        case 3:
            return jazz.count
        case 4:
            return topArtists.count
        case 5:
            return pop.count
        case 6:
            return classical.count
        case 7:
            return topAlbums.count
        default:
            return rock.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < topTracks.count {
                let track = topTracks[indexPath.item]
                cell.configure(track: track, with: "\(track.album.coverBig ?? "")")
            }
            return cell
            
        case 1:
            let cell = populateHomeTracksCell(indexPath: indexPath)

            if indexPath.item < hipHop.count {
                let track = hipHop[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
            
        case 2:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < dance.count {
                let track = dance[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
            
        case 3:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < jazz.count {
                let track = jazz[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopArtistsCollectionViewCell.reuseIdentifier, for: indexPath) as! TopArtistsCollectionViewCell
            
            if indexPath.item < topArtists.count {
                let artist = topArtists[indexPath.item]
                cell.configure(artist: artist)
            }
            return cell
            
        case 5:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < pop.count {
                let track = pop[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
            
        case 6:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < classical.count {
                let track = classical[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
            
        case 7:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopAlbumsCollectionViewCell.reuseIdentifier, for: indexPath) as! TopAlbumsCollectionViewCell
            
            if indexPath.item < topAlbums.count {
                let album = topAlbums[indexPath.item]
                cell.configure(album: album)
            }
            return cell
            
        default:
            let cell = populateHomeTracksCell(indexPath: indexPath)
            
            if indexPath.item < rock.count {
                let track = rock[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
        }
    }
    
    func populateHomeTracksCell(indexPath: IndexPath) -> HomeTracksCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeTracksCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch indexPath.section {
        case 0:
            return populateHeaders(headerID: "topChartHeader", kind: kind, indexPath: indexPath)
        case 1:
            return populateHeaders(headerID: "hipHopHeader", kind: kind, indexPath: indexPath)
        case 2:
            return populateHeaders(headerID: "danceHeader", kind: kind, indexPath: indexPath)
        case 3:
            return populateHeaders(headerID: "jazzHeader", kind: kind, indexPath: indexPath)
        case 4:
            return populateHeaders(headerID: "topArtistsHeader", kind: kind, indexPath: indexPath)
        case 5:
            return populateHeaders(headerID: "popHeader", kind: kind, indexPath: indexPath)
        case 6:
            return populateHeaders(headerID: "classicalHeader", kind: kind, indexPath: indexPath)
        case 7:
            return populateHeaders(headerID: "topAlbumsHeader", kind: kind, indexPath: indexPath)
        default:
            return populateHeaders(headerID: "rockHeader", kind: kind, indexPath: indexPath)
        }
    }
    
    func populateHeaders(headerID: String, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath)
        return reusableView
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            if let cell = collectionView.cellForItem(at: indexPath) as? HomeTracksCollectionViewCell {
                cell.imageView.transform = .init(scaleX: 0.90, y: 0.90)
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
        UIView.animate(withDuration: 0.3) {
            if let cell = collectionView.cellForItem(at: indexPath) as? HomeTracksCollectionViewCell {
                cell.imageView.transform = .identity
                cell.label.transform = .identity
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        
        case 0:
            toDetailsSegue(tracks: topTracks, indexPath: indexPath)
        case 1:
            toDetailsSegue(tracks: hipHop, indexPath: indexPath)
        case 2:
            toDetailsSegue(tracks: dance, indexPath: indexPath)
        case 3:
            toDetailsSegue(tracks: jazz, indexPath: indexPath)
        case 4:
            
            Loaf.dismiss(sender: self, animated: true)
            let topArtists = topArtists[indexPath.item]
            guard let url = URL(string: "\(topArtists.link)") else {return}

            let sfVC = SFSafariViewController(url: url)
            present(sfVC, animated: true)
            
        case 5:
            toDetailsSegue(tracks: pop, indexPath: indexPath)
        case 6:
            toDetailsSegue(tracks: classical, indexPath: indexPath)
        case 7:
            
            Loaf.dismiss(sender: self, animated: true)
            let topAlbums = topAlbums[indexPath.item]
            guard let url = URL(string: "\(topAlbums.link)") else {return}
            
            let sfVC = SFSafariViewController(url: url)
            present(sfVC, animated: true)
            
        default:
            toDetailsSegue(tracks: rock, indexPath: indexPath)
        }
    }
    
    func toDetailsSegue(tracks: [Track], indexPath: IndexPath) {
        Loaf.dismiss(sender: self, animated: true)
        
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        let track = tracks[indexPath.item]
        performSegue(withIdentifier: "toDetails", sender: track)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails" {
            guard let dest = segue.destination as? DetailsMusicViewController,
                  let track = sender as? Track else {return}

            dest.track = track
            
        } else if segue.identifier == "toGenre" {
            guard let dest = segue.destination as? UINavigationController,
                  let targetController = dest.topViewController as? GenreMusicViewController,
                  let data = sender as? [String] else {return}
            
            targetController.titleGenre = data[0]
            targetController.path = data[1]
        }
    }
    
    func fetchTracks() {
        tracksDS.fetchGenres(from: .chart, with: "/0/tracks", with: ["limit" : 35]) {[weak self] topTracks, error in
            if let topTracks = topTracks {
                self?.topTracks = topTracks

                self?.loadSectionAndAnimation(in: 0)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/116/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.hipHop = tracks

                self?.loadSectionAndAnimation(in: 1)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/113/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.dance = tracks

                self?.loadSectionAndAnimation(in: 2)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/129/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.jazz = tracks

                self?.loadSectionAndAnimation(in: 3)
            } else if let error = error {
                print(error)
            }
        }
        topArtistsDS.fetchTopArtists(from: .chart, with: "/0/artists", with: ["limit" : 8]) {[weak self] artists, error in
            if let artists = artists {
                self?.topArtists = artists

                self?.loadSectionAndAnimation(in: 4)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/132/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.pop = tracks

                self?.loadSectionAndAnimation(in: 5)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/98/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.classical = tracks

                self?.loadSectionAndAnimation(in: 6)
            } else if let error = error {
                print(error)
            }
        }
        topAlbumsDS.fetchTopAlbums(from: .chart, with: "/0/albums", with: ["limit" : 15]) {[weak self] albums, error in
            if let albums = albums {
                self?.topAlbums = albums

                self?.loadSectionAndAnimation(in: 7)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/152/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.rock = tracks

                self?.loadSectionAndAnimation(in: 8)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func loadSectionAndAnimation(in section: Int) {
        counter += 1
        collectionView.reloadSections([section])
        
        let animation = AnimationType.from(direction: .right, offset: 30.0)
        let cells = collectionView.visibleCells(in: section)
        UIView.animate(views: cells, animations: [animation])
        
        if counter == collectionView.numberOfSections {
            counter = 0
            HUD.flash(.success, delay: 0.5)
            refreshControl.endRefreshing()
        }
    }
}

extension Notification.Name {
    static let ToViewAll = Notification.Name("toViewAll")
}

extension HomeMusicCollectionViewController {
    func showAlertAndReload(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: "Retry", style: .cancel, handler: {[weak self] action in
            if !Connectivity.isConnectedToInternet {
                self?.showAlertAndReload(title: "No Internet Connection", message: "Failed to connect to the internet")
            } else {
                self?.fetchTracks()
                self?.greetingMessage()
                self?.loadRefreshControl()
            }
        }))
        present(vc, animated: true)
    }
}
