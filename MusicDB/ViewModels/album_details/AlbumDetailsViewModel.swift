//
//  AlbumDetailsViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 07/03/2022.
//

import Foundation

class AlbumDetailsViewModel {
    var albumTracks: [AlbumTrack] = []
    var album: TopAlbums?
    
    let albumTracksDS = AlbumTrackAPIDataSource()
    
    var isLiked: Bool = false
    
    var indexPath: IndexPath?
    var isHome: Bool? = false
}
