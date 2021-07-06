//
//  UIViewController+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 22/06/2021.
//

import UIKit
import FirebaseAuth

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
    
    func showAlertAndSegue(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(.init(title: "Ok", style: .default, handler: {[weak self] action in
            do {
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Login", bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginStoryboard")
                self?.present(vc, animated: true)
            } catch let error{
                print(error)
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
