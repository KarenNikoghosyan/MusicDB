//
//  Artist.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 28/06/2021.
//

import Foundation

struct TopArtistsAPIResponse {
    let data: [TopArtists]
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case data, total
    }
}

extension TopArtistsAPIResponse: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        data = try values.decode([TopArtists].self, forKey: .data)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
    }
}

struct TopArtists {
    let id: Int
    let name: String
    let link: String
    let picture: String?
    let pictureSmall: String?
    let pictureMedium: String?
    let pictureBig: String?
    let pictureXL: String?
    let radio: Bool?
    let tracklist: String
    let position: Int
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, link, picture
        case pictureSmall = "picture_small"
        case pictureMedium = "picture_medium"
        case pictureBig = "picture_big"
        case pictureXL = "picture_xl"
        case radio, tracklist, position, type
    }
}

extension TopArtists: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        link = try values.decode(String.self, forKey: .link)
        picture = try values.decodeIfPresent(String.self, forKey: .picture)
        pictureSmall = try values.decodeIfPresent(String.self, forKey: .pictureSmall)
        pictureMedium = try values.decodeIfPresent(String.self, forKey: .pictureMedium)
        pictureBig = try values.decodeIfPresent(String.self, forKey: .pictureBig)
        pictureXL = try values.decodeIfPresent(String.self, forKey: .pictureXL)
        radio = try values.decodeIfPresent(Bool.self, forKey: .radio)
        tracklist = try values.decode(String.self, forKey: .tracklist)
        position = try values.decode(Int.self, forKey: .position)
        type = try values.decode(String.self, forKey: .type)
    }
}
