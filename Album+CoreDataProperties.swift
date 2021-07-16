//
//  Album+CoreDataProperties.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var cover: String?
    @NSManaged public var coverBig: String?
    @NSManaged public var coverMedium: String?
    @NSManaged public var coverSmall: String?
    @NSManaged public var coverXL: String?
    @NSManaged public var id: Int32
    @NSManaged public var md5Image: String
    @NSManaged public var title: String
    @NSManaged public var tracklist: String
    @NSManaged public var type: String

}

extension Album : Identifiable {

}
