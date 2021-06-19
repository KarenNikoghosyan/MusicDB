//
//  SwipeableTabBarController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 17/06/2021.
//

import UIKit
import SwipeableTabBarController

class TabBarController: SwipeableTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeAnimatedTransitioning?.animationType = SwipeAnimationType.push
    }
}
