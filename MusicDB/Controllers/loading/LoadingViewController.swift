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
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 36),
            activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        activityIndicatorView.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now()+3) {[weak self] in
            activityIndicatorView.stopAnimating()
            self?.performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
}
