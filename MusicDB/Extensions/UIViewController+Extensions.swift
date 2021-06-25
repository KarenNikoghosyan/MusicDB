//
//  UIViewController+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 22/06/2021.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTapped() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    class func storyboardInstance(storyboardID: String, restorationID: String)->UIViewController {
        let storyboard = UIStoryboard(name: storyboardID, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: restorationID)
    }
}
