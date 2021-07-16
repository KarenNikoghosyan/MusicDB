//
//  TopArtists+CoreDataClass.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData

@objc(TopArtists)
public class TopArtists: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id, name, link, picture
        case pictureSmall = "picture_small"
        case pictureMedium = "picture_medium"
        case pictureBig = "picture_big"
        case pictureXL = "picture_xl"
        case radio, tracklist, position, type
    }
    
    public convenience required init(from decoder: Decoder) throws {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "TopArtists", in: Database.shared.context) else { fatalError() }

        self.init(entity: entity, insertInto: Database.shared.context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int32.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        link = try values.decode(String.self, forKey: .link)
        picture = try values.decodeIfPresent(String.self, forKey: .picture)
        pictureSmall = try values.decodeIfPresent(String.self, forKey: .pictureSmall)
        pictureMedium = try values.decodeIfPresent(String.self, forKey: .pictureMedium)
        pictureBig = try values.decodeIfPresent(String.self, forKey: .pictureBig)
        pictureXL = try values.decodeIfPresent(String.self, forKey: .pictureXL)
        radio = try values.decodeIfPresent(Bool.self, forKey: .radio) ?? true
        tracklist = try values.decode(String.self, forKey: .tracklist)
        position = try values.decode(Int32.self, forKey: .position)
        type = try values.decode(String.self, forKey: .type)
    }
}
