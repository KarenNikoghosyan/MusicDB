//
//  TopAlbumsAPIResponse+CoreDataProperties.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData


extension TopAlbumsAPIResponse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopAlbumsAPIResponse> {
        return NSFetchRequest<TopAlbumsAPIResponse>(entityName: "TopAlbumsAPIResponse")
    }

    @NSManaged public var data: [TopAlbums]
    @NSManaged public var total: Int32

}

extension TopAlbumsAPIResponse : Identifiable {

}
