//
//  Notification.Name+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 24/07/2021.
//

import Foundation

extension Notification.Name {
    //Home screen to View All
    static let ToViewAll = Notification.Name("toViewAll")
    
    //Removing/adding tracks
    static let AddTrack = Notification.Name("addTrack")
    static let RemoveTrack = Notification.Name("removeTrack")
    
    //Removing/adding albums IDs
    static let AddAlbumID = Notification.Name("addAlbumID")
    static let RemoveAlbumID = Notification.Name("removeAlbumID")
    
    //Send index to add/remove
    static let IndexAdd = Notification.Name("indexAdd")
    static let IndexRemove = Notification.Name("indexRemove")
    
    //Sends an index
    static let SendIndexPath = Notification.Name("sendIndexPath")
    static let SendIndexPathAlbum = Notification.Name("sendIndexPathAlbum")
    static let ReloadFromHome = Notification.Name("ReloadFromHome")
}
