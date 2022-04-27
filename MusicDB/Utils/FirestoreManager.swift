//
//  FirestoreManager.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 30/07/2021.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    let db = Firestore.firestore()
    static let shared = FirestoreManager()
    
    private init(){}
    
    func removeTrack(track: Track, userID: String) {
        db.collection("users").document(userID).updateData([
            "trackIDs" : FieldValue.arrayRemove([track.id as Any])
        ]) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .RemoveTrack, object: nil, userInfo: ["track" : track])
                }
            }
        }
    }
    
    func addTrack(track: Track, userID: String) {
        db.collection("users").document(userID).updateData([
            "trackIDs" : FieldValue.arrayUnion([track.id as Any])
        ]) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .AddTrack, object: nil, userInfo: ["track": track])
                }
            }
        }
    }
    
    func removeAlbum(album: TopAlbums, userID: String) {
        db.collection("users").document(userID).updateData([
            "albumIDs" : FieldValue.arrayRemove([album.id as Any])
        ]) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .RemoveAlbumID, object: nil, userInfo: ["album" : album])
                }
            }
        }
    }
    
    func addAlbum(album: TopAlbums, userID: String) {
        db.collection("users").document(userID).updateData([
            "albumIDs" : FieldValue.arrayUnion([album.id as Any])
        ]) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .AddAlbumID, object: nil, userInfo: ["album": album])
                }
            }
        }
    }
}
