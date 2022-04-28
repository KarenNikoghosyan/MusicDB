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
import SwiftUI

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    private let viewModel = RegisterViewModel()
    
    @IBOutlet private weak var registerAccountLabel: UILabel!
    @IBOutlet private weak var signInLabel: UILabel!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var registerNameTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private weak var registerEmailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private weak var registerPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private weak var registerConfirmedPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        setUpTextFields()
        setupTapGestureRecognizer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        portraitConstraints()
    }
    
    @IBAction private func signInTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func registerTapped(_ sender: LGButton) {

        guard let name = registerNameTextField.text, name.count > 1, let email = registerEmailTextField.text, email.isEmail(), let password = registerPasswordTextField.text, password.count > 5, let confirmedPassword = registerConfirmedPasswordTextField.text, confirmedPassword == password else {
            showViewControllerAlert(title: viewModel.errorText, message: viewModel.checkTheFieldsText)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] result, error in
            
            if error == nil {
                guard let self = self,
                      let userID = Auth.auth().currentUser?.uid else {return}
                
                FirestoreManager.shared.db.collection(self.viewModel.usersText).document(userID).setData([
                    self.viewModel.nameFirebase : name,
                    self.viewModel.trackIDsFirebase : [],
                    self.viewModel.albumIDsFirebase : []
                ]) { error in
                   
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: .main)
                        let vc = storyboard.instantiateViewController(withIdentifier: Constants.mainStoryboardIdentifier)
                        self.present(vc, animated: true)
                    }
                }
            } else {
                guard let self = self else {return}
                
                self.showViewControllerAlert(title: self.viewModel.errorText, message: self.viewModel.accountExistsText)
            }
        }
    }
}

//MARK: - Functions
extension RegisterViewController {
    
    private func setupTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    //Checks the current running device and loads the appropriate constraints based on the device.
    func portraitConstraints() {
        switch UIDevice().type {
        case .iPod7:
            registerAccountLabel.font = UIFont.init(name: Constants.futuraBold, size: 23)
            signInLabel.font = UIFont.init(name: Constants.futura, size: 15)
            signInButton.titleLabel?.font = UIFont(name: Constants.futuraBold, size: 15)
        case .iPhoneSE2:
            registerAccountLabel.font = UIFont.init(name: Constants.futuraBold, size: 25)
            signInLabel.font = UIFont.init(name: Constants.futura, size: 16)
            signInButton.titleLabel?.font = UIFont(name: Constants.futuraBold, size: 16)
        case .iPhone8:
            registerAccountLabel.font = UIFont.init(name: Constants.futuraBold, size: 25)
            signInLabel.font = UIFont.init(name: Constants.futura, size: 16)
            signInButton.titleLabel?.font = UIFont(name: Constants.futuraBold, size: 16)
        default:
            break
        }
    }
    
    func setUpTextFields() {
        //Name:
        registerNameTextField.placeholder = viewModel.nameText
        registerNameTextField.title = viewModel.nameText
        registerNameTextField.lineColor = .lightGray
        registerNameTextField.selectedLineColor = .white
        registerNameTextField.selectedTitleColor = .white
        registerNameTextField.textColor = .white
        registerNameTextField.iconType = .image
        registerNameTextField.iconColor = .lightGray
        registerNameTextField.iconImage = UIImage(systemName: viewModel.personCircleImage)
        registerNameTextField.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
        
        //Email:
        registerEmailTextField.placeholder = viewModel.emailText
        registerEmailTextField.title = viewModel.emailText
        registerEmailTextField.lineColor = .lightGray
        registerEmailTextField.selectedLineColor = .white
        registerEmailTextField.selectedTitleColor = .white
        registerEmailTextField.textColor = .white
        registerEmailTextField.keyboardType = .emailAddress
        registerEmailTextField.iconType = .image
        registerEmailTextField.iconColor = .lightGray
        registerEmailTextField.iconImage = UIImage(systemName: viewModel.envelopeImage)
        registerEmailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        
        //Password:
        registerPasswordTextField.placeholder = viewModel.passwordText
        registerPasswordTextField.title = viewModel.passwordText
        registerPasswordTextField.lineColor = .lightGray
        registerPasswordTextField.selectedLineColor = .white
        registerPasswordTextField.selectedTitleColor = .white
        registerPasswordTextField.textColor = .white
        registerPasswordTextField.enablePasswordToggle()
        registerPasswordTextField.iconType = .image
        registerPasswordTextField.iconColor = .lightGray
        registerPasswordTextField.iconImage = UIImage(systemName: viewModel.lockImage)
        registerPasswordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)

        //Confirm Password:
        registerConfirmedPasswordTextField.placeholder = viewModel.confirmPasswordText
        registerConfirmedPasswordTextField.title = viewModel.confirmPasswordText
        registerConfirmedPasswordTextField.lineColor = .lightGray
        registerConfirmedPasswordTextField.selectedLineColor = .white
        registerConfirmedPasswordTextField.selectedTitleColor = .white
        registerConfirmedPasswordTextField.textColor = .white
        registerConfirmedPasswordTextField.enablePasswordToggle()
        registerConfirmedPasswordTextField.iconType = .image
        registerConfirmedPasswordTextField.iconColor = .lightGray
        registerConfirmedPasswordTextField.iconImage = UIImage(systemName: viewModel.lockImage)
        registerConfirmedPasswordTextField.addTarget(self, action: #selector(confirmedPasswordTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func nameTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text,
           let floatingLabelTextField = textField as? SkyFloatingLabelTextFieldWithIcon {
            
            if text.count < 2 {
                floatingLabelTextField.errorMessage = viewModel.nameTooShortText
            } else {
                floatingLabelTextField.errorMessage = nil
            }
                
            if text.count == 0 {
                floatingLabelTextField.errorMessage = nil
            }
        }
    }
    
    @objc func emailTextFieldDidChange(_ textField: UITextField) {
            if let text = textField.text,
               let floatingLabelTextField = textField as? SkyFloatingLabelTextFieldWithIcon {
                
                if !text.isEmail() {
                    floatingLabelTextField.errorMessage = viewModel.invalidEmailText
                } else {
                    floatingLabelTextField.errorMessage = nil
                    floatingLabelTextField.text = floatingLabelTextField.text
                }
                    
                if text.count == 0 {
                    floatingLabelTextField.errorMessage = nil
                }
            }
        }
    
    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text,
           let floatingLabelTextField = textField as? SkyFloatingLabelTextFieldWithIcon {
                        
            if text.count < 6 {
                floatingLabelTextField.errorMessage = viewModel.passwordShortText
            } else {
                if text != registerConfirmedPasswordTextField.text {
                    floatingLabelTextField.errorMessage = viewModel.passwordDontMatchText
                } else {
                    registerConfirmedPasswordTextField.errorMessage = nil
                    floatingLabelTextField.errorMessage = nil
                }
            }
            
            if text.count == 0 {
                floatingLabelTextField.errorMessage = nil
            }
        }
    }
    
    @objc func confirmedPasswordTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text,
           let floatingLabelTextField = textField as? SkyFloatingLabelTextFieldWithIcon {
            
            if text.count < 6 {
                floatingLabelTextField.errorMessage = viewModel.passwordShortText
            } else {
                if text != registerPasswordTextField.text {
                    floatingLabelTextField.errorMessage = viewModel.passwordDontMatchText
                } else {
                    registerPasswordTextField.errorMessage = nil
                    floatingLabelTextField.errorMessage = nil
                }
            }
            
            if text.count == 0 {
                floatingLabelTextField.errorMessage = nil
            }
        }
    }
}

