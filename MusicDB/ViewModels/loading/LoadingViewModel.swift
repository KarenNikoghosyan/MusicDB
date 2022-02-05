//
//  LoadingViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 05/02/2022.
//

import Foundation
import FirebaseAuth

class LoadingViewModel {
    
    var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
