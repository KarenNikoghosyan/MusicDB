//
//  UIViewController+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 22/06/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Loaf

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

extension UIViewController {
    func loafMessageAdded(track: Track) {
        Loaf("\(track.titleShort) was added to your liked page", state: .custom(.init(backgroundColor: .systemGreen, textColor: .white, tintColor: .white, icon: UIImage(systemName: "i.circle"), iconAlignment: .left)), location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5))
    }
    
    func loafMessageRemoved(track: Track) {
        Loaf("\(track.titleShort) was removed from your liked page", state: .custom(.init(backgroundColor: .systemGreen, textColor: .white, tintColor: .white, icon: UIImage(systemName: "i.circle"), iconAlignment: .left)), location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(1.5))
    }
    
    func loafMessageWelcome(name: String) {
        Loaf("Welcome Back, \(name)", state: .custom(.init(backgroundColor: .systemGreen, textColor: .white, tintColor: .white, icon: UIImage(systemName: "i.circle"), iconAlignment: .left)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(3.5))
    }
    
    func loafMessageRegistration() {
        Loaf("Account was successfully created", state: .custom(.init(backgroundColor: .systemGreen, textColor: .white, tintColor: .white, icon: UIImage(systemName: "i.circle"), iconAlignment: .left)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
    }
}

extension UIViewController {
    static let db = Firestore.firestore()
    
    func removeTrack(track: Track, userID: String) {
        UIViewController.db.collection("users").document(userID).updateData([
            "trackIDs" : FieldValue.arrayRemove([track.id as Any])
        ]) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .RemoveTrack, object: nil, userInfo: ["track" : track])
                }
            }
        }
    }
    
    func addTrack(track: Track, userID: String) {
        UIViewController.db.collection("users").document(userID).updateData([
            "trackIDs" : FieldValue.arrayUnion([track.id as Any])
        ]) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .AddTrack, object: nil, userInfo: ["track": track])
                }
            }
        }
    }
}

extension UIViewController {
    func logOutTappedAndSegue() {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: "No Internet Connection", message: "Failed to connect to the internet")
            return
        }
        Loaf.dismiss(sender: self, animated: true)
        showAlertAndSegue(title: "Sign out from MusicDB?", message: "You're about to sign out, do you want to proceed?")
    }
}

extension UIViewController {
    func setupNavigationItems(tableView: UITableView? = nil) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        
        guard let tableView = tableView else {return}
        tableView.separatorColor = UIColor.darkGray
    }
}
