//
//  UserDefaults+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 21/07/2021.
//

import UIKit
import SwiftUI

extension UserDefaults {
    func setIntro(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isIntro.rawValue)
    }
    
    func isIntro()-> Bool {
        return bool(forKey: UserDefaultsKeys.isIntro.rawValue)
    }
    func setProfileImage(imageData: Data) {
        set(imageData, forKey: UserDefaultsKeys.profileImage.rawValue)
    }
    func getProfileImage() -> Data? {
        return data(forKey: UserDefaultsKeys.profileImage.rawValue)
    }
}

enum UserDefaultsKeys: String {
    case isIntro, profileImage
}
