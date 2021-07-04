//
//  UITextField+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 04/07/2021.
//

import UIKit

extension UITextField {
    func isEmail() -> Bool {
        return self.text?.isEmail() ?? false
    }
}
