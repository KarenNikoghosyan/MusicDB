//
//  Database.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 13/07/2021.
//

import Foundation
import CoreData

class Database {
    public static let shared = Database()
    
    private init(){}
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MusicDB")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
//    func add(track: TrackDatabase) {
//        saveContext()
//    }
//
//    func update() {
//        saveContext()
//    }
//
//    func delete(tracks: [GenreArrays]) {
//        for (index, _) in tracks.enumerated() {
//            context.delete(tracks[index])
//        }
//        saveContext()
//    }
//    
//    func fetchTracks()->[GenreArrays] {
//        let request: NSFetchRequest<GenreArrays> = GenreArrays.fetchRequest()
//
//        let tracks = try? context.fetch(request)
//        return tracks ?? []
//    }
    
}
