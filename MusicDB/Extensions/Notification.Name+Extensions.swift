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
    
    //Removing and adding tracks
    static let AddTrack = Notification.Name("addTrack")
    static let RemoveTrack = Notification.Name("removeTrack")
    
    //Send index to add or remove
    static let IndexAdd = Notification.Name("indexAdd")
    static let IndexRemove = Notification.Name("indexRemove")
    
    //Sends an index
    static let SendIndexPath = Notification.Name("sendIndexPath")
    
    //Opens a link
    static let OpenLinkInSafari = Notification.Name("openLinkInSafari")
}
