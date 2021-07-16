//
//  Album+CoreDataClass.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData

@objc(Album)
public class Album: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case id, title, cover
        case coverSmall = "cover_small"
        case coverMedium = "cover_medium"
        case coverBig = "cover_big"
        case coverXL = "cover_xl"
        case md5Image = "md5_image"
        case tracklist, type
    }
    
    public convenience required init(from decoder: Decoder) throws {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Album", in: Database.shared.context) else { fatalError() }

        self.init(entity: entity, insertInto: Database.shared.context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int32.self, forKey: .id)
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
