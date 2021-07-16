//
//  Track+CoreDataProperties.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var album: Album
    @NSManaged public var artist: Artist
    @NSManaged public var duration: Int32
    @NSManaged public var explicitContentCover: Int32
    @NSManaged public var explicitContentLyrics: Int32
    @NSManaged public var explicitLyrics: Bool
    @NSManaged public var id: Int32
    @NSManaged public var link: String?
    @NSManaged public var md5Image: String
    @NSManaged public var position: Int32
    @NSManaged public var preview: String
    @NSManaged public var rank: Int32
    @NSManaged public var title: String
    @NSManaged public var titleShort: String
    @NSManaged public var titleVersion: String?
    @NSManaged public var type: String

}

extension Track : Identifiable {

}
