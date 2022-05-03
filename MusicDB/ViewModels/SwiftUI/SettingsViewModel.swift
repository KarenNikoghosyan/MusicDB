//
//  SettingsViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 03/05/2022.
//

import Foundation
import Combine

class SettingsViewModel: NSObject, ObservableObject {
    
    @Published var showingImagePicker = false
    
    let facebookURL = "https://www.facebook.com/karen.nikoghosyan.1/"
    let twitterURL = "https://twitter.com/nikoghosyan11"
    let emailURL = "mailto:karen1111996@gmail.com"
    
    let facebookImage = "facebook"
    let twitterImage = "twitter"
    let emailImage = "email"
    let logoutImage = "logout"
    
    let settingsTitle = "Settings"
    let followUsString = "Follow us"
    let contactUsString = "Contact us"
    let logoutString = "Log Out"
}

//MARK: - Functions
extension SettingsViewModel {
    
    func setImageToUserDefaults(imageData: Data) {
        UserDefaults.standard.setProfileImage(imageData: imageData)
    }
    
    func getImageFromUserDefaults() -> Data? {
        return UserDefaults.standard.getProfileImage()
    }
}
