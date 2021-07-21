//
//  UserDefaults+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 21/07/2021.
//

import Foundation

extension UserDefaults {
    func setIntro(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isIntro.rawValue)
    }
    
    func isIntro()-> Bool {
        return bool(forKey: UserDefaultsKeys.isIntro.rawValue)
    }
}

enum UserDefaultsKeys: String {
    case isIntro
}
