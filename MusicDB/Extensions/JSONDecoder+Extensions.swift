//
//  JSONDecoder+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 15/07/2021.
//

import Foundation
import CoreData

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[.context] = context
    }
}
