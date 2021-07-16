//
//  TracksAPIResponse+CoreDataClass.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData

@objc(TracksAPIResponse)
public class TracksAPIResponse: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case data, total, next
    }
    
    public required convenience init(from decoder: Decoder) throws {
        

        guard let entity = NSEntityDescription.entity(forEntityName: "TracksAPIResponse", in: Database.shared.context) else { fatalError() }

        self.init(entity: entity, insertInto: Database.shared.context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([Track].self, forKey: .data)
        total = try values.decodeIfPresent(Int32.self, forKey: .total) ?? 0
        next = try values.decodeIfPresent(String.self, forKey: .next)
    }
}
