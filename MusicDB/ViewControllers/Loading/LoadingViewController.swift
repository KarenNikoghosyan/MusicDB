//
//  LoadingViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 02/07/2021.
//

import UIKit
import NVActivityIndicatorView

class LoadingViewController: UIViewController {
    
    private let viewModel = LoadingViewModel()
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var topAnchorConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Loading indicator for the loading screen
        setupActivityIndicator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        isDeviceOrientation()
    }
}

//MARK: - Functions
extension LoadingViewController {
    
    private func isDeviceOrientation() {
        if UIDevice.current.orientation.isLandscape {
            setupLandscapeConstraints()
        } else {
            setupPortraitConstraints()
        }
    }
    
    //Checks the current running device and loads the appropriate constraints based on the device.
    //potrait orientation
    private func setupPortraitConstraints() {
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
    
    //landscape orientation
    private func setupLandscapeConstraints() {
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
    
    private func setupActivityIndicator() {
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
            
            //if user connected will load him staright into the home screen
            self.checkIfUserConnected()
        }
    }
    
    private func checkIfUserConnected() {
        if self.viewModel.isUserLoggedIn {
            let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: .main)
            let vc = storyboard.instantiateViewController(withIdentifier: Constants.mainStoryboardIdentifier)
            self.present(vc, animated: true)
        } else {
            //if user launches the app for the first time, a tutorial screen will be shown
            if !UserDefaults.standard.isIntro() {
                let storyboard = UIStoryboard(name: Constants.introStoryboard, bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: Constants.introStoryboardIdentifier)
                self.present(vc, animated: true)
            } else {
                //if the user isn't connected will load him straight into the login screen
                let storyboard = UIStoryboard(name: Constants.loginStoryboard, bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: Constants.loginStoryboardIdentifier)
                self.present(vc, animated: true)
            }
        }
    }
}
