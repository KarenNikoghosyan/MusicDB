//
//  LoginViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 03/07/2021.
//

import UIKit
import SkyFloatingLabelTextField
import Loady
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var loginEmailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var loginPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBAction func signUpTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }
    @IBAction func loginTapped(_ sender: LoadyButton) {
        guard let email = loginEmailTextField.text, email.isEmail(),
              let password = loginPasswordTextField.text, password.count > 5 else {
            showViewControllerAlert(title: "Error", message: "Please check the fields")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] result, error in
            if error == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: "mainStoryboard")
                self?.present(vc, animated: true)
            } else {
                self?.showViewControllerAlert(title: "Error", message: "There's a problem with signing you in, please try again later")
            }
        }
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
        loginEmailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        
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
        loginPasswordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func emailTextFieldDidChange(_ textField: UITextField) {
            if let text = textField.text {
                if let floatingLabelTextField = textField as? SkyFloatingLabelTextFieldWithIcon {
                    if !text.isEmail() {
                        floatingLabelTextField.errorMessage = "Invalid email"
                    } else {
                        floatingLabelTextField.errorMessage = nil
                    }
                    
                    if text.count == 0 {
                        floatingLabelTextField.errorMessage = nil
                    }
                }
            }
        }
    
    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextFieldWithIcon {
                if text.count < 6 {
                    floatingLabelTextField.errorMessage = "Password is too short"
                } else {
                    floatingLabelTextField.errorMessage = nil
                }
                
                if text.count == 0 {
                    floatingLabelTextField.errorMessage = nil
                }
            }
        }
    }
}
