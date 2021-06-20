//
//  SwipeableTabBarController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 17/06/2021.
//

import UIKit
import SwipeableTabBarController
import RAMAnimatedTabBarController

class TabBarController: SwipeableTabBarController {
    
    @IBOutlet weak var tracksTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeAnimatedTransitioning?.animationType = SwipeAnimationType.push
        
    }
}

class CustomTabBarContoller: RAMAnimatedTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Test2")
    }
}
