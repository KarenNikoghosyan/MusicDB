//
//  LoginViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 03/07/2021.
//

import UIKit
import SkyFloatingLabelTextField

class LoginViewController: UIViewController {
    @IBOutlet weak var loginEmailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var loginPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBAction func signUpTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        loginEmailTextField.becomeFirstResponder()
        
        setUpTextFields()
        
        
    }
    
    func setupNavigationItems() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    func setUpTextFields() {
        loginEmailTextField.placeholder = "Email"
        loginEmailTextField.title = "Email"
        loginEmailTextField.lineColor = .lightGray
        loginEmailTextField.selectedLineColor = .white
        loginEmailTextField.selectedTitleColor = .white
        loginEmailTextField.textColor = .white
        loginEmailTextField.keyboardType = .emailAddress
        loginEmailTextField.iconType = .image
        loginEmailTextField.iconColor = .lightGray
        loginEmailTextField.iconImage = UIImage(systemName: "envelope")
        
        loginPasswordTextField.placeholder = "Password"
        loginPasswordTextField.title = "Password"
        loginPasswordTextField.lineColor = .lightGray
        loginPasswordTextField.selectedLineColor = .white
        loginPasswordTextField.selectedTitleColor = .white
        loginPasswordTextField.textColor = .white
        loginPasswordTextField.isSecureTextEntry = true
        loginPasswordTextField.iconType = .image
        loginPasswordTextField.iconColor = .lightGray
        loginPasswordTextField.iconImage = UIImage(systemName: "lock")
    }
}
