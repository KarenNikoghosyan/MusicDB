//
//  TopAlbums+CoreDataProperties.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData


extension TopAlbums {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopAlbums> {
        return NSFetchRequest<TopAlbums>(entityName: "TopAlbums")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String
    @NSManaged public var link: String
    @NSManaged public var cover: String?
    @NSManaged public var coverSmall: String?
    @NSManaged public var coverMedium: String?
    @NSManaged public var coverBig: String?
    @NSManaged public var coverXL: String?
    @NSManaged public var md5Image: String
    @NSManaged public var recordType: String
    @NSManaged public var tracklist: String
    @NSManaged public var explicitLyrics: Bool
    @NSManaged public var position: Int32
    @NSManaged public var artist: TopAlbumsArtist
    @NSManaged public var type: String

}

extension TopAlbums : Identifiable {

}
