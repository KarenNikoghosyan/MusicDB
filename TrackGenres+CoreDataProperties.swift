//
//  TrackGenres+CoreDataProperties.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 16/07/2021.
//
//

import Foundation
import CoreData


extension TrackGenres {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackGenres> {
        return NSFetchRequest<TrackGenres>(entityName: "TrackGenres")
    }

    @NSManaged public var classical: [Track]?
    @NSManaged public var dance: [Track]?
    @NSManaged public var hipHop: [Track]?
    @NSManaged public var jazz: [Track]?
    @NSManaged public var pop: [Track]?
    @NSManaged public var rock: [Track]?
    //@NSManaged public var topAlbums: [TopAlbums]?
    //@NSManaged public var topArtists: [TopArtists]?
    @NSManaged public var topTracks: [Track]?

}

extension TrackGenres : Identifiable {

}
