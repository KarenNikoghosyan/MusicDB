//
//  HomeViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 11/02/2022.
//

import Foundation
import FirebaseAuth

protocol HomeViewModelDelegate: AnyObject {
    func loadSectionAndAnimation(in section: Int)
    func loadLoafMessage(name: String)
    func showAlert()
    func dismissLoaf()
    func perfSegue(viewAll: String, genre: String)
    func logOutTapped()
}

class HomeViewModel {
    
    weak var delegate: HomeViewModelDelegate?
    
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
    
    let topChartHeader = "topChartHeader"
    let hipHopHeader = "hipHopHeader"
    let danceHeader = "danceHeader"
    let jazzHeader = "jazzHeader"
    let topArtistsHeader = "topArtistsHeader"
    let popHeader = "popHeader"
    let classicalHeader = "classicalHeader"
    let topAlbumsHeader = "topAlbumsHeader"
    let rockHeader = "rockHeader"
    
    //Segue destinations
    let toSettingsText = "toSettings"
    let toDetailsText = "toDetails"
    let toGenreText = "toGenre"
    let toAlbumDetailsText = "toAlbumDetails"
    
    //Dictionary
    let albumText = "album"
    let isHomeText = "isHome"
    
    //Firebase
    let users = "users"
    let name = "name"
    
    //NotificationCenter
    let viewAll = "viewAll"
    let genre = "genre"
    
    let noImageFoundText = "No Image Found"
    let fetchingTracksText = "Fetching Tracks..."
    
    var counter: Int = 0
}

//MARK: - Functions
extension HomeViewModel {
    
    func setupObservers() {
        //Gets the button action from the corresponding cell
        NotificationCenter.default.addObserver(forName: .ToViewAll, object: nil, queue: .main) {[weak self] notification in
            guard let self = self else {return}
            
            if !Connectivity.isConnectedToInternet {
                self.delegate?.showAlert()
                return
            }
            
            if let viewAll = notification.userInfo?[self.viewAll] as? String,
               let genre = notification.userInfo?[self.genre] as? String {
                
                self.delegate?.dismissLoaf()
                self.delegate?.perfSegue(viewAll: viewAll, genre: genre)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .MoveToLogin, object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {return}
            
            self.delegate?.logOutTapped()
        }
    }
    
    //Fetches all the genres
    func fetchTracks() {
        tracksDS.fetchGenres(from: .chart, with: "/0/tracks", with: ["limit" : 35]) {[weak self] topTracks, error in
            guard let self = self else {return}
            
            if let topTracks = topTracks {
                self.topTracks = topTracks
                self.delegate?.loadSectionAndAnimation(in: 0)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/116/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            guard let self = self else {return}
            
            if let tracks = tracks {
                self.hipHop = tracks
                self.delegate?.loadSectionAndAnimation(in: 1)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/113/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            guard let self = self else {return}
            
            if let tracks = tracks {
                self.dance = tracks
                self.delegate?.loadSectionAndAnimation(in: 2)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/129/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            guard let self = self else {return}
            
            if let tracks = tracks {
                self.jazz = tracks
                self.delegate?.loadSectionAndAnimation(in: 3)
            } else if let error = error {
                print(error)
            }
        }
        topArtistsDS.fetchTopArtists(from: .chart, with: "/0/artists", with: ["limit" : 8]) {[weak self] artists, error in
            guard let self = self else {return}
            
            if let artists = artists {
                self.topArtists = artists
                self.delegate?.loadSectionAndAnimation(in: 4)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/132/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            guard let self = self else {return}
            
            if let tracks = tracks {
                self.pop = tracks
                self.delegate?.loadSectionAndAnimation(in: 5)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/98/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            guard let self = self else {return}
            
            if let tracks = tracks {
                self.classical = tracks
                self.delegate?.loadSectionAndAnimation(in: 6)
            } else if let error = error {
                print(error)
            }
        }
        topAlbumsDS.fetchTopAlbums(from: .chart, with: "/0/albums", with: ["limit" : 15]) {[weak self] albums, error in
            guard let self = self else {return}
            
            if let albums = albums {
                self.topAlbums = albums
                self.delegate?.loadSectionAndAnimation(in: 7)
            } else if let error = error {
                print(error)
            }
        }
        tracksDS.fetchGenres(from: .chart, with: "/152/tracks", with: ["limit" : 35]) {[weak self] tracks, error in
            guard let self = self else {return}
            
            if let tracks = tracks {
                self.rock = tracks
                self.delegate?.loadSectionAndAnimation(in: 8)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func showGreetingMessage() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirestoreManager.shared.db.collection(users).document(userID).getDocument {[weak self] snapshot, error in
            guard let self = self,
                  let name: String = snapshot?.get(self.name) as? String else {return}
            
            self.delegate?.loadLoafMessage(name: name)
        }
    }
}
