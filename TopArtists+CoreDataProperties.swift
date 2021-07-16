//
//  TopArtists+CoreDataProperties.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData


extension TopArtists {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopArtists> {
        return NSFetchRequest<TopArtists>(entityName: "TopArtists")
    }

    @NSManaged public var id: Int32
    @NSManaged public var link: String
    @NSManaged public var name: String
    @NSManaged public var picture: String?
    @NSManaged public var pictureBig: String?
    @NSManaged public var pictureMedium: String?
    @NSManaged public var pictureSmall: String?
    @NSManaged public var pictureXL: String?
    @NSManaged public var position: Int32
    @NSManaged public var radio: Bool
    @NSManaged public var tracklist: String
    @NSManaged public var type: String

}

extension TopArtists : Identifiable {

}
