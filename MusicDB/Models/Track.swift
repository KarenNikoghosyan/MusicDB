//
//  Track.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 18/06/2021.
//

import Foundation

struct TracksAPIResponse: Codable {
    let data: [Track]?
    let total: Int?
    let next: String?
}

struct Track: Codable {
    let id: Int
    let title: String
    let title_short: String
    let title_version: String?
    let link: String?
    let duration: Int
    let rank: Int
    let explicit_lyrics: Bool
    let explicit_content_lyrics: Int
    let explicit_content_cover: Int
    let preview: String
    let md5_image: String
    let position: Int?
    let artist: Artist
    let album: Album
    let type: String
}

struct Artist: Codable {
    let id: Int
    let name: String
    let link: String?
    let picture: String?
    let picture_small: String?
    let picture_medium: String?
    let picture_big: String?
    let picture_xl: String?
    let radio: Bool?
    let tracklist: String
    let type: String
}

struct Album: Codable {
    let id: Int
    let title: String
    let cover: String
    let cover_small: String?
    let cover_medium: String?
    let cover_big: String?
    let cover_xl: String?
    let md5_image: String
    let tracklist: String
    let type: String
}
