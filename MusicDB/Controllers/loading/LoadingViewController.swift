//
//  LoadingViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 02/07/2021.
//

import UIKit
import NVActivityIndicatorView

class LoadingViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    
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

        DispatchQueue.main.asyncAfter(deadline: .now()+3) {[weak self] in
            activityIndicatorView.stopAnimating()
            self?.performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
}
