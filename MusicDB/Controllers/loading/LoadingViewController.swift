//
//  LoadingViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 02/07/2021.
//

import UIKit
import NVActivityIndicatorView
import FirebaseAuth

class LoadingViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    
    private var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .lineScalePulseOut, color: .white, padding: 0)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        activityIndicatorView.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {[weak self] in
            
            guard let self = self else {return}
            activityIndicatorView.stopAnimating()
            
            if self.isUserLoggedIn {
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: "mainStoryboard")
                self.present(vc, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Login", bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginStoryboard")
                self.present(vc, animated: true)
            }
        }
    }
}
