//
//  Track+CoreDataClass.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData

@objc(Track)
public class Track: NSManagedObject, Decodable {

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

    public required convenience init(from decoder: Decoder) throws {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Track", in: Database.shared.context) else { fatalError() }

        self.init(entity: entity, insertInto: Database.shared.context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int32.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        titleShort = try values.decode(String.self, forKey: .titleShort)
        titleVersion = try values.decodeIfPresent(String.self, forKey: .titleVersion)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        duration = try values.decode(Int32.self, forKey: .duration)
        rank = try values.decode(Int32.self, forKey: .rank)
        explicitLyrics = try values.decode(Bool.self, forKey: .explicitLyrics)
        explicitContentLyrics = try values.decode(Int32.self, forKey: .explicitContentLyrics)
        explicitContentCover = try values.decode(Int32.self, forKey: .explicitContentCover)
        preview = try values.decode(String.self, forKey: .preview)
        md5Image = try values.decode(String.self, forKey: .md5Image)
        position = try values.decodeIfPresent(Int32.self, forKey: .position) ?? 0
        artist = try values.decode(Artist.self, forKey: .artist)
        album = try values.decode(Album.self, forKey: .album)
        type = try values.decode(String.self, forKey: .type)
    }
}
