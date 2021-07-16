//
//  TopArtistsAPIResponse+CoreDataClass.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData

@objc(TopArtistsAPIResponse)
public class TopArtistsAPIResponse: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case data, total
    }
    
    public convenience required init(from decoder: Decoder) throws {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "TopArtistsAPIResponse", in: Database.shared.context) else { fatalError() }

        self.init(entity: entity, insertInto: Database.shared.context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decode([TopArtists].self, forKey: .data)
        total = try values.decodeIfPresent(Int32.self, forKey: .total) ?? 0
    }
}
