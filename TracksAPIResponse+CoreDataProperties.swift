//
//  TracksAPIResponse+CoreDataProperties.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData


extension TracksAPIResponse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TracksAPIResponse> {
        return NSFetchRequest<TracksAPIResponse>(entityName: "TracksAPIResponse")
    }

    @NSManaged public var data: [Track]?
    @NSManaged public var next: String?
    @NSManaged public var total: Int32

}

extension TracksAPIResponse : Identifiable {

}
