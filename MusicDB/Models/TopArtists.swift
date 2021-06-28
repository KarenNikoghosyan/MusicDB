//
//  Artist.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 28/06/2021.
//

import Foundation

struct TopArtistsAPIResponse: Codable {
    let data: [TopArtists]
    let total: Int?
}

struct TopArtists: Codable {
    let id: Int
    let name: String
    let link: String
    let picture: String
    let picture_small: String
    let picture_medium: String
    let picture_big: String
    let picture_xl: String
    let radio: Bool
    let tracklist: String
    let position: Int
    let type: String
}
