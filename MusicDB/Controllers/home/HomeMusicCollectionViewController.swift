//
//  HomeMusicCollectionViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 17/06/2021.
//

import UIKit

class HomeMusicCollectionViewController: UICollectionViewController {
    
    let sections: [Int] = [1, 2, 3, 4]
    
    var topTracks: [Track] = []
    var hipHop: [Track] = []
    var dance: [Track] = []
    var jazz: [Track] = []
    
    var tracksDS = GenreAPIDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchTracks()
        
        collectionView.register(HomeTracksCollectionViewCell.self, forCellWithReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifer)
        
        collectionView.register(TopChartCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "topChartHeader")
        collectionView.register(HipHopCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "hipHopHeader")
        collectionView.register(DanceCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "danceHeader")
        collectionView.register(JazzCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "jazzHeader")
        
        collectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {

        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in

         switch sectionNumber {

            case 0: return self.chartLayoutSection()
            default: return self.tracksLayoutSection()
         }
       }
    }
    
    private func chartLayoutSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.bottom = 15

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(350), heightDimension: .absolute(350))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 2)

        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets.leading = 8
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]

        return section
    }
    
    private func tracksLayoutSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.bottom = 15
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 2)
       
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets.leading = 8
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
        
        return section
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
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
        default:
            return 10
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTracksCollectionViewCell.reuseIdentifer, for: indexPath) as! HomeTracksCollectionViewCell
        
        switch indexPath.section {
        case 0:
            if indexPath.item < topTracks.count {
                let track = topTracks[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover_big ?? "")")
            }
        case 1:
            if indexPath.item < hipHop.count {
                let track = hipHop[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover)")
            }
        case 2:
            if indexPath.item < dance.count {
                let track = dance[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover)")
            }
        case 3:
            if indexPath.item < jazz.count {
                let track = jazz[indexPath.item]
                cell.configure(track: track, with: "\(track.album.cover)")
            }
        default: break
            
        }
        return cell
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
        default: break
        
        }
        return UICollectionReusableView()
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
        default: break
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? DetailsMusicViewController,
              let track = sender as? Track else {return}
        
        dest.track = track
    }
    
    func fetchTracks() {
        tracksDS.fetchGenres(from: .chart, with: "/0/tracks", with: ["limit" : 50]) {[weak self] topTracks, error in
            if let topTracks = topTracks {
                self?.topTracks = topTracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/116/tracks", with: ["limit" : 50]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.hipHop = tracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/113/tracks", with: ["limit" : 50]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.dance = tracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/129/tracks", with: ["limit" : 100]) {[weak self] tracks, error in
            if let tracks = tracks {
                self?.jazz = tracks
                self?.collectionView.reloadData()
            } else if let error = error {
                print(error)
            }
        }
    }
}
