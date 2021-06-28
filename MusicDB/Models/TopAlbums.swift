//
//  TopAlbums.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 28/06/2021.
//

import Foundation

struct TopAlbumsAPIResponse {
    let data: [TopAlbums]
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case data, total
    }
}

extension TopAlbumsAPIResponse: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        data = try values.decode([TopAlbums].self, forKey: .data)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
    }
}

struct TopAlbums {
    let id: Int
    let title: String
    let link: String
    let cover: String?
    let coverSmall: String?
    let coverMedium: String?
    let coverBig: String?
    let coverXL: String?
    let md5Image: String
    let recordType: String
    let tracklist: String
    let explicitLyrics: Bool
    let position: Int?
    let artist: TopAlbumsArtist
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, link, cover
        case coverSmall = "cover_small"
        case coverMedium = "cover_medium"
        case coverBig = "cover_big"
        case coverXL = "cover_xl"
        case md5Image = "md5_image"
        case recordType = "record_type"
        case tracklist
        case explicitLyrics = "explicit_lyrics"
        case position, artist, type
    }
}

extension TopAlbums: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        link = try values.decode(String.self, forKey: .link)
        cover = try values.decodeIfPresent(String.self, forKey: .cover)
        coverSmall = try values.decodeIfPresent(String.self, forKey: .coverSmall)
        coverMedium = try values.decodeIfPresent(String.self, forKey: .coverMedium)
        coverBig = try values.decodeIfPresent(String.self, forKey: .coverBig)
        coverXL = try values.decodeIfPresent(String.self, forKey: .coverXL)
        md5Image = try values.decode(String.self, forKey: .md5Image)
        recordType = try values.decode(String.self, forKey: .recordType)
        tracklist = try values.decode(String.self, forKey: .tracklist)
        explicitLyrics = try values.decode(Bool.self, forKey: .explicitLyrics)
        position = try values.decodeIfPresent(Int.self, forKey: .position)
        artist = try values.decode(TopAlbumsArtist.self, forKey: .artist)
        type = try values.decode(String.self, forKey: .type)
    }
}

struct TopAlbumsArtist {
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

extension TopAlbumsArtist: Decodable {
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
