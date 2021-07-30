//
//  RegisterViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 03/07/2021.
//

import UIKit
import SkyFloatingLabelTextField
import Loady
import FirebaseAuth
import LGButton

class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var registerNameTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var registerEmailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var registerPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var registerConfirmedPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBAction func signInTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func registerTapped(_ sender: LGButton) {

        guard let name = registerNameTextField.text, name.count > 1, let email = registerEmailTextField.text, email.isEmail(), let password = registerPasswordTextField.text, password.count > 5, let confirmedPassword = registerConfirmedPasswordTextField.text, confirmedPassword == password else {
            showViewControllerAlert(title: "Error", message: "Please check the fields")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] result, error in
            if error == nil {
                guard let userID = Auth.auth().currentUser?.uid else {return}
                
                FirestoreManager.shared.db.collection("users").document(userID).setData([
                    "name" : name,
                    "trackIDs" : [],
                    "albumIDs" : []
                ]) {[weak self] error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: .main)
                        let vc = storyboard.instantiateViewController(withIdentifier: "mainStoryboard")
                        self?.present(vc, animated: true)
                    }
                }
            } else {
                self?.showViewControllerAlert(title: "Error", message: "Account is already exists")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNameTextField.becomeFirstResponder()
            
        setUpTextFields()
    }
    
    func setUpTextFields() {
        //Name:
        registerNameTextField.placeholder = "Name"
        registerNameTextField.title = "Name"
        registerNameTextField.lineColor = .lightGray
        registerNameTextField.selectedLineColor = .white
        registerNameTextField.selectedTitleColor = .white
        registerNameTextField.textColor = .white
        registerNameTextField.iconType = .image
        registerNameTextField.iconColor = .lightGray
        registerNameTextField.iconImage = UIImage(systemName: "person.circle")
        registerNameTextField.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
        
        //Email:
        registerEmailTextField.placeholder = "Email"
        registerEmailTextField.title = "Email"
        registerEmailTextField.lineColor = .lightGray
        registerEmailTextField.selectedLineColor = .white
        registerEmailTextField.selectedTitleColor = .white
        registerEmailTextField.textColor = .white
        registerEmailTextField.keyboardType = .emailAddress
        registerEmailTextField.iconType = .image
        registerEmailTextField.iconColor = .lightGray
        registerEmailTextField.iconImage = UIImage(systemName: "envelope")
        registerEmailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        
        //Password:
        registerPasswordTextField.placeholder = "Password"
        registerPasswordTextField.title = "Password"
        registerPasswordTextField.lineColor = .lightGray
        registerPasswordTextField.selectedLineColor = .white
        registerPasswordTextField.selectedTitleColor = .white
        registerPasswordTextField.textColor = .white
        registerPasswordTextField.enablePasswordToggle()
        registerPasswordTextField.iconType = .image
        registerPasswordTextField.iconColor = .lightGray
        registerPasswordTextField.iconImage = UIImage(systemName: "lock")
        registerPasswordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)

        //Confirm Password:
        registerConfirmedPasswordTextField.placeholder = "Confirm Password"
        registerConfirmedPasswordTextField.title = "Confirm Password"
        registerConfirmedPasswordTextField.lineColor = .lightGray
        registerConfirmedPasswordTextField.selectedLineColor = .white
        registerConfirmedPasswordTextField.selectedTitleColor = .white
        registerConfirmedPasswordTextField.textColor = .white
        registerConfirmedPasswordTextField.enablePasswordToggle()
        registerConfirmedPasswordTextField.iconType = .image
        registerConfirmedPasswordTextField.iconColor = .lightGray
        registerConfirmedPasswordTextField.iconImage = UIImage(systemName: "lock")
        registerConfirmedPasswordTextField.addTarget(self, action: #selector(confirmedPasswordTextFieldDidChange(_:)), for: .editingChanged)

    }
    
    @objc func nameTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextFieldWithIcon {
                if text.count < 2 {
                    floatingLabelTextField.errorMessage = "Name is too short"
                } else {
                    floatingLabelTextField.errorMessage = nil
                }
                
                if text.count == 0 {
                    floatingLabelTextField.errorMessage = nil
                }
            }
        }
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
    
    @objc func confirmedPasswordTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextFieldWithIcon {
                if text != registerPasswordTextField.text {
                    floatingLabelTextField.errorMessage = "Passwords don't match"
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
