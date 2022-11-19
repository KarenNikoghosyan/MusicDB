//
//  UIView+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 05/08/2021.
//

import UIKit

extension UIView {
    func setIsHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            if self.isHidden && !hidden {
                self.alpha = 0.0
                self.isHidden = false
            }
            UIView.animate(withDuration: 0.20, animations: {
                self.alpha = hidden ? 0.0 : 1.0
            }) { (complete) in
                self.isHidden = hidden
            }
        } else {
            self.isHidden = hidden
        }
    }
}

extension UIView {
    func startShimmeringEffect() {
        let light = UIColor.white.cgColor
        let alpha = UIColor(red: 206 / 255, green: 10 / 255, blue: 10 / 255, alpha: 0.7)
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: -self.bounds.size.width, y: 0, width: 3 * self.bounds.size.width, height: self.bounds.size.height)
        gradient.colors = [light, alpha, light]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
        gradient.locations = [0.35, 0.50, 0.65]
        self.layer.mask = gradient
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.5
        animation.repeatCount = HUGE
        gradient.add(animation, forKey: "shimmer")
    }
    
    func stopShimmeringEffect() {
        self.layer.mask = nil
    }
}
