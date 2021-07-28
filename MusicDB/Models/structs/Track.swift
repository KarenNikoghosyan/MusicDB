//
//  Track.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 18/06/2021.
//

import Foundation

struct TracksAPIResponse {
    let data: [Track]
    let total: Int?
    let next: String?
    
    enum CodingKeys: String, CodingKey {
        case data, total, next
    }
}

extension TracksAPIResponse: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        data = try values.decode([Track].self, forKey: .data)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
        next = try values.decodeIfPresent(String.self, forKey: .next)
    }
}

struct Track {
    let id: Int
    let title: String
    let titleShort: String
    let titleVersion: String?
    let link: String?
    let duration: Int
    let rank: Int
    let explicitLyrics: Bool
    let explicitContentLyrics: Int
    let explicitContentCover: Int
    let preview: String
    let md5Image: String
    let position: Int?
    let artist: Artist
    let album: Album
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case titleShort = "title_short"
        case titleVersion = "title_version"
        case link, duration, rank
        case explicitLyrics = "explicit_lyrics"
        case explicitContentLyrics = "explicit_content_lyrics"
        case explicitContentCover = "explicit_content_cover"
        case preview
        case md5Image = "md5_image"
        case position, artist, album, type
    }
}

extension Track: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        titleShort = try values.decode(String.self, forKey: .titleShort)
        titleVersion = try values.decodeIfPresent(String.self, forKey: .titleVersion)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        duration = try values.decode(Int.self, forKey: .duration)
        rank = try values.decode(Int.self, forKey: .rank)
        explicitLyrics = try values.decode(Bool.self, forKey: .explicitLyrics)
        explicitContentLyrics = try values.decode(Int.self, forKey: .explicitContentLyrics)
        explicitContentCover = try values.decode(Int.self, forKey: .explicitContentCover)
        preview = try values.decode(String.self, forKey: .preview)
        md5Image = try values.decode(String.self, forKey: .md5Image)
        position = try values.decodeIfPresent(Int.self, forKey: .position)
        artist = try values.decode(Artist.self, forKey: .artist)
        album = try values.decode(Album.self, forKey: .album)
        type = try values.decode(String.self, forKey: .type)
    }
}

struct Artist {
    let id: Int
    let name: String
    let link: String?
    let picture: String?
    let pictureSmall: String?
    let pictureMedium: String?
    let pictureBig: String?
    let pictureXL: String?
    let radio: Bool?
    let tracklist: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, link, picture
        case pictureSmall = "picture_small"
        case pictureMedium = "picture_medium"
        case pictureBig = "picture_big"
        case pictureXL = "picture_xl"
        case radio, tracklist, type
    }
}

extension Artist: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        picture = try values.decodeIfPresent(String.self, forKey: .picture)
        pictureSmall = try values.decodeIfPresent(String.self, forKey: .pictureSmall)
        pictureMedium = try values.decodeIfPresent(String.self, forKey: .pictureMedium)
        pictureBig = try values.decodeIfPresent(String.self, forKey: .pictureBig)
        pictureXL = try values.decodeIfPresent(String.self, forKey: .pictureXL)
        radio = try values.decodeIfPresent(Bool.self, forKey: .radio)
        tracklist = try values.decode(String.self, forKey: .tracklist)
        type = try values.decode(String.self, forKey: .type)
    }
}

struct Album {
    let id: Int
    let title: String
    let cover: String?
    let coverSmall: String?
    let coverMedium: String?
    let coverBig: String?
    let coverXL: String?
    let md5Image: String
    let tracklist: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, cover
        case coverSmall = "cover_small"
        case coverMedium = "cover_medium"
        case coverBig = "cover_big"
        case coverXL = "cover_xl"
        case md5Image = "md5_image"
        case tracklist, type
    }
}

extension Album: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        cover = try values.decodeIfPresent(String.self, forKey: .cover)
        coverSmall = try values.decodeIfPresent(String.self, forKey: .coverSmall)
        coverMedium = try values.decodeIfPresent(String.self, forKey: .coverMedium)
        coverBig = try values.decodeIfPresent(String.self, forKey: .coverBig)
        coverXL = try values.decodeIfPresent(String.self, forKey: .coverXL)
        md5Image = try values.decode(String.self, forKey: .md5Image)
        tracklist = try values.decode(String.self, forKey: .tracklist)
        type = try values.decode(String.self, forKey: .type)
    }
}
