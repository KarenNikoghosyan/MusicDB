//
//  UITextField+Extensions.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 04/07/2021.
//

import UIKit

extension UITextField {
    func isEmail() -> Bool {
        return self.text?.isEmail() ?? false
    }
}

extension UITextField {
fileprivate func setPasswordToggleImage(_ button: UIButton) {
    if(isSecureTextEntry){
        button.setImage(UIImage(systemName: "eye"), for: .normal)
    } else{
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    }
}

func enablePasswordToggle(){
    let button = UIButton(type: .custom)
    self.isSecureTextEntry = true
    setPasswordToggleImage(button)
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
    button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
    button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
    button.tintColor = .systemGreen
    self.rightView = button
    self.rightViewMode = .always
}
    
@IBAction func togglePasswordView(_ sender: Any) {
    self.isSecureTextEntry = !self.isSecureTextEntry
    setPasswordToggleImage(sender as! UIButton)
    }
}
