//
//  TopAlbums+CoreDataClass.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData

@objc(TopAlbums)
public class TopAlbums: NSManagedObject, Decodable {

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
    
    public convenience required init(from decoder: Decoder) throws {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "TopAlbums", in: Database.shared.context) else { fatalError() }

        self.init(entity: entity, insertInto: Database.shared.context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int32.self, forKey: .id)
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
        position = try values.decodeIfPresent(Int32.self, forKey: .position) ?? 0
        artist = try values.decode(TopAlbumsArtist.self, forKey: .artist)
        type = try values.decode(String.self, forKey: .type)
    }
}
