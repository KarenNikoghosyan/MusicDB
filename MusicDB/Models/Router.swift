//
//  Router.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 05/07/2021.
//

import UIKit
import FirebaseAuth

class Router {
    weak var window: UIWindow? {
        didSet {
            loadingRootViewController()
        }
    }
    
    static let shared = Router()
    private init(){}
    
    func loadingRootViewController() {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {[weak self] in
                self?.loadingRootViewController()
            }
            return
        }
        
        let sb = UIStoryboard(name: "Loading", bundle: .main)
        window?.rootViewController = sb.instantiateInitialViewController()
    }
}
