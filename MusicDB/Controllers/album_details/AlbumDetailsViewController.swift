//
//  AlbumDetailsViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import UIKit

class AlbumDetailsViewController: UIViewController {
    var album: TopAlbums?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = album?.title
    
    }
}
