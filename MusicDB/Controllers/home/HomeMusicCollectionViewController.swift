//
//  HomeMusicCollectionViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 17/06/2021.
//

import UIKit
import ViewAnimator
import SafariServices

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
    
    let tracksDS = GenreAPIDataSource()
    let topArtistsDS = TopArtistsAPIDataSource()
    let topAlbumsDS = TopAlbumsAPIDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchTracks()
        
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
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150))
        
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

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .fractionalWidth(0.55))
        
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeTracksCollectionViewCell
            
            if indexPath.item < topTracks.count {
                let track = topTracks[indexPath.item]
                cell.configure(track: track, with: "\(track.album.coverBig ?? "")")
            }
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeTracksCollectionViewCell
            
            if indexPath.item < hipHop.count {
                
                let track = hipHop[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeTracksCollectionViewCell
            
            if indexPath.item < dance.count {
                
                let track = dance[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeTracksCollectionViewCell
            
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeTracksCollectionViewCell
            
            if indexPath.item < pop.count {
                let track = pop[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
            
        case 6:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeTracksCollectionViewCell
            
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifier, for: indexPath) as! HomeTracksCollectionViewCell
            
            if indexPath.item < rock.count {
                let track = rock[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover ?? "No Image Found")")
            }
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch indexPath.section {
        case 0:
            let topChartheader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "topChartHeader", for: indexPath)
            return topChartheader
        case 1:
            let hipHopHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "hipHopHeader", for: indexPath)
            return hipHopHeader
        case 2:
            let danceHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "danceHeader", for: indexPath)
            return danceHeader
        case 3:
            let jazzHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "jazzHeader", for: indexPath)
            return jazzHeader
        case 4:
            let topArtistsHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "topArtistsHeader", for: indexPath)
            return topArtistsHeader
        case 5:
            let popHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "popHeader", for: indexPath)
            return popHeader
        case 6:
            let classicalHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "classicalHeader", for: indexPath)
            return classicalHeader
        case 7:
            let topAlbumsHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "topAlbumsHeader", for: indexPath)
            return topAlbumsHeader
        default:
            let rockHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "rockHeader", for: indexPath)
            return rockHeader
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) {
            if let cell = collectionView.cellForItem(at: indexPath) as? HomeTracksCollectionViewCell {
                cell.topChartImageView.transform = .init(scaleX: 0.90, y: 0.90)
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TopArtistsCollectionViewCell {
                cell.imageView.transform = .init(scaleX: 0.90, y: 0.90)
                cell.name.transform = .init(scaleX: 0.90, y: 0.90)
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TopAlbumsCollectionViewCell {
                cell.imageView.transform = .init(scaleX: 0.95, y: 0.95)
                cell.subtitle.transform = .init(scaleX: 0.95, y: 0.95)
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) {
            if let cell = collectionView.cellForItem(at: indexPath) as? HomeTracksCollectionViewCell {
                cell.topChartImageView.transform = .identity
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
            let topTracks = topTracks[indexPath.item]
            performSegue(withIdentifier: "toDetails", sender: topTracks)
        case 1:
            let hipHipTracks = hipHop[indexPath.item]
            performSegue(withIdentifier: "toDetails", sender: hipHipTracks)
        case 2:
            let danceTracks = dance[indexPath.item]
            performSegue(withIdentifier: "toDetails", sender: danceTracks)
        case 3:
            let jazzTracks = jazz[indexPath.item]
            performSegue(withIdentifier: "toDetails", sender: jazzTracks)
        case 4:
            let topArtists = topArtists[indexPath.item]
            guard let url = URL(string: "\(topArtists.link)") else {return}
            
            let sfVC = SFSafariViewController(url: url)
            present(sfVC, animated: true)
        case 5:
            let popTracks = pop[indexPath.item]
            performSegue(withIdentifier: "toDetails", sender: popTracks)
        case 6:
            let classicalTracks = classical[indexPath.item]
            performSegue(withIdentifier: "toDetails", sender: classicalTracks)
        case 7:
            let topAlbums = topAlbums[indexPath.item]
            guard let url = URL(string: "\(topAlbums.link)") else {return}
            
            let sfVC = SFSafariViewController(url: url)
            present(sfVC, animated: true)
        default:
            let rockTracks = rock[indexPath.item]
            performSegue(withIdentifier: "toDetails", sender: rockTracks)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? DetailsMusicViewController,
              let track = sender as? Track else {return}
        
        dest.track = track
    }
    
    func fetchTracks() {
        tracksDS.fetchGenres(from: .chart, with: "/0/tracks", with: ["limit" : 35]) {[weak self] topTracks, error in
            if let topTracks = topTracks {
                self?.topTracks = topTracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/116/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.hipHop = tracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/113/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.dance = tracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/129/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.jazz = tracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        topArtistsDS.fetchTopArtists(from: .chart, with: "/0/artists", with: ["limit" : 7]) {[weak self] artists, error in
            if let artists = artists {
                self?.topArtists = artists
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/132/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.pop = tracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/98/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.classical = tracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        topAlbumsDS.fetchTopAlbums(from: .chart, with: "/0/albums", with: ["limit" : 15]) {[weak self] albums, error in
            if let albums = albums {
                self?.topAlbums = albums
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/152/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.rock = tracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func loadAnimation() {
        let animation = AnimationType.from(direction: .right, offset: 30.0)
        self.collectionView.animate(animations: [animation])
    }
}
