//
//  SearchMusicViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 13/02/2022.
//

import Foundation

protocol SearchMusicViewModelDelegate: AnyObject {
    func searchInitiated(tracks: [Track])
    func stopAnimation()
}

class SearchMusicViewModel {
    
    let ds = TrackAPIDataSource()
    var searchTracks: [Track] = []
    
    let searchCellIdentifier = "cell"
    let toDetailsIdentifier = "toDetails"
    
    let searchForArtistsText = "Search for artists, songs and more."
    let noTracksFoundText = "No Tracks Found"
    
    weak var searchDelegate: SearchMusicViewModelDelegate?
}

//MARK: - Functions
extension SearchMusicViewModel {
    
    func fetchTracks(text: String) {
        ds.fetchTracks(from: .search, id: nil, path: nil, with: ["q":text]) {[weak self] tracks, error in
            guard let self = self else {return}
            
            if let tracks = tracks {
                
                self.searchTracks = tracks
                self.searchDelegate?.searchInitiated(tracks: tracks)
                
            } else if let error = error {
                print(error)
                self.searchDelegate?.stopAnimation()
            }
        }
    }
}
