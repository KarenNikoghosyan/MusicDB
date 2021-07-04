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

extension UIViewController {
    func showViewControllerAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
