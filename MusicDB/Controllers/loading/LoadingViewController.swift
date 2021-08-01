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
    @IBOutlet weak var topAnchorConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    private var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    func portraitConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewHeightConstraint.constant = 130
            topAnchorConstraint.constant = 48
        case .iPhoneSE2:
            imageViewHeightConstraint.constant = 150
            topAnchorConstraint.constant = 48
        case .iPhone12ProMax:
            imageViewHeightConstraint.constant = 200
            topAnchorConstraint.constant = 128
        default:
            topAnchorConstraint.constant = 95
        }
    }
    
    func landscapeConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewHeightConstraint.constant = 100
            topAnchorConstraint.constant = 32
        case .iPhoneSE2:
            imageViewHeightConstraint.constant = 100
            topAnchorConstraint.constant = 32
        case .iPhone12ProMax:
            imageViewHeightConstraint.constant = 185
            topAnchorConstraint.constant = 32
        default:
            topAnchorConstraint.constant = 32
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if UIDevice.current.orientation.isLandscape {
            landscapeConstraints()
        } else {
            portraitConstraints()
        }
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
                if !UserDefaults.standard.isIntro() {
                    let storyboard = UIStoryboard(name: "Intro", bundle: .main)
                    let vc = storyboard.instantiateViewController(withIdentifier: "introStoryboard")
                    self.present(vc, animated: true)
                } else {
                    let storyboard = UIStoryboard(name: "Login", bundle: .main)
                    let vc = storyboard.instantiateViewController(withIdentifier: "loginStoryboard")
                    self.present(vc, animated: true)
                }
            }
        }
    }
}
