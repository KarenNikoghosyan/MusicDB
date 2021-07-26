//
//  OAuthViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 25/07/2021.
//

import UIKit
import LGButton
import OAuthSwift
import WebKit
import Loaf

class OAuthViewController: UIViewController {
    
    let oauthswift = OAuth1Swift(
        consumerKey: SoundCloudOAuth.consumerKey.rawValue,
        consumerSecret: SoundCloudOAuth.consumerSecret.rawValue,
        requestTokenUrl: "https://api.audiomack.com/v1/request_token",
        authorizeUrl: "https://api.audiomack.com/v1/authorize",
        accessTokenUrl: "https://api.audiomack.com/v1/acccess_token")
    
    @IBAction func authenticateToSoundCloud(_ sender: LGButton) {
        Loaf.dismiss(sender: self, animated: true)
        let _ = oauthswift.authorize(
            withCallbackURL: "oauth-swift://oauth-callback/audiomack") { result in
            switch result {
            case .success(let (credential, _, parameters)):
                print(credential.oauthToken)
                print(credential.oauthTokenSecret)
                print(parameters["user_id"] as Any)
            // Do your request
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

enum SoundCloudOAuth: String {
    case consumerKey = "[consumerkey]"
    case consumerSecret = "[consumersecret]"
}
