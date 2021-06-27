//
//  Chart.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/06/2021.
//

import Foundation

struct ChartAPIResponse: Codable {
    let tracks: ChartData
    let total: Int?
}

struct ChartData: Codable {
    let data: [ChartTrack]?
    let total: Int?
    let next: String?
}

struct ChartTrack: Codable {
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
    let artist: ChartArtist
    let album: ChartAlbum
    let type: String
}

struct ChartArtist: Codable {
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

struct ChartAlbum: Codable {
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
