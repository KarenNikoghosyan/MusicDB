//
//  TopArtistsAPIResponse+CoreDataProperties.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData


extension TopArtistsAPIResponse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopArtistsAPIResponse> {
        return NSFetchRequest<TopArtistsAPIResponse>(entityName: "TopArtistsAPIResponse")
    }

    @NSManaged public var data: [TopArtists]
    @NSManaged public var total: Int32

}

extension TopArtistsAPIResponse : Identifiable {

}
