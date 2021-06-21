//
//  SwipeableTabBarController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 17/06/2021.
//

import UIKit
import SwipeableTabBarController

class TabBarController: SwipeableTabBarController {
    
    private var bounceAnimation: CAKeyframeAnimation = {
            let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            bounceAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
            bounceAnimation.duration = TimeInterval(0.3)
            bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
            return bounceAnimation
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewControllers = viewControllers {
            selectedViewController = viewControllers[1]
        }
        
        swipeAnimatedTransitioning?.animationType = SwipeAnimationType.push

        tabBar.tintColor = .yellow
        tabBar.barTintColor = UIColor(red: 80.0/255, green: 80.0/255, blue: 80.0/255, alpha: 1)
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item),
              tabBar.subviews.count > index + 1,
              let imageView = tabBar.subviews[index + 1].subviews.first as? UIImageView else {
            return
        }
        imageView.layer.add(bounceAnimation, forKey: nil)
    }
}
