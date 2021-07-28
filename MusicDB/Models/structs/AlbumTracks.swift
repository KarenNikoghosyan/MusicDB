//
//  AlbumTracks.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import Foundation

struct AlbumTracksAPIResponse {
    let data: [AlbumTrack]
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case data, total
    }
}

extension AlbumTracksAPIResponse: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        data = try values.decode([AlbumTrack].self, forKey: .data)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
    }
}

struct AlbumTrack {
    let id: Int
    let readable: Bool
    let title: String
    let titleShort: String
    let titleVersion: String?
    let isrc: String
    let link: String?
    let duration: Int
    let track_position: Int
    let disk_number: Int
    let rank: Int
    let explicitLyrics: Bool
    let explicitContentLyrics: Int
    let explicitContentCover: Int
    let preview: String
    let md5Image: String
    let artist: Artist
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, readable
        case titleShort = "title_short"
        case titleVersion = "title_version"
        case isrc, link, duration
        case trackPosition = "track_position"
        case diskNumber = "disk_number"
        case rank
        case explicitLyrics = "explicit_lyrics"
        case explicitContentLyrics = "explicit_content_lyrics"
        case explicitContentCover = "explicit_content_cover"
        case preview
        case md5Image = "md5_image"
        case artist, type
    }
}

extension AlbumTrack: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        readable = try values.decode(Bool.self, forKey: .readable)
        titleShort = try values.decode(String.self, forKey: .titleShort)
        titleVersion = try values.decodeIfPresent(String.self, forKey: .titleVersion)
        isrc = try values.decode(String.self, forKey: .isrc)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        duration = try values.decode(Int.self, forKey: .duration)
        track_position = try values.decode(Int.self, forKey: .trackPosition)
        disk_number = try values.decode(Int.self, forKey: .diskNumber)
        rank = try values.decode(Int.self, forKey: .rank)
        explicitLyrics = try values.decode(Bool.self, forKey: .explicitLyrics)
        explicitContentLyrics = try values.decode(Int.self, forKey: .explicitContentLyrics)
        explicitContentCover = try values.decode(Int.self, forKey: .explicitContentCover)
        preview = try values.decode(String.self, forKey: .preview)
        md5Image = try values.decode(String.self, forKey: .md5Image)
        artist = try values.decode(Artist.self, forKey: .artist)
        type = try values.decode(String.self, forKey: .type)
    }
}

struct AlbumArtist {
    let id: Int
    let name: String
    let tracklist: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case tracklist, type
    }
}

extension AlbumArtist: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        tracklist = try values.decode(String.self, forKey: .tracklist)
        type = try values.decode(String.self, forKey: .type)
    }
}
