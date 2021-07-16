//
//  TopAlbumsArtist+CoreDataProperties.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData


extension TopAlbumsArtist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopAlbumsArtist> {
        return NSFetchRequest<TopAlbumsArtist>(entityName: "TopAlbumsArtist")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String
    @NSManaged public var link: String?
    @NSManaged public var picture: String?
    @NSManaged public var pictureSmall: String?
    @NSManaged public var pictureMedium: String?
    @NSManaged public var pictureBig: String?
    @NSManaged public var pictureXL: String?
    @NSManaged public var radio: Bool
    @NSManaged public var tracklist: String
    @NSManaged public var type: String

}

extension TopAlbumsArtist : Identifiable {

}
