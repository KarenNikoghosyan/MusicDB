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
import LGButton

class LoginViewController: UIViewController {
    
    private let viewModel = LoginViewModel()
    
    @IBOutlet private weak var signInLabel: UILabel!
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var signUpLabel: UILabel!
    @IBOutlet private weak var bottomLabelConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topAnchorConstraint: NSLayoutConstraint!
    @IBOutlet private weak var loginEmailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private weak var loginPasswordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet private weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        setupTextFields()
        setupTapGestureRecognizer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIDevice.current.orientation.isLandscape {
            landscapeConstraints()
        } else {
            portraitConstraints()
        }
    }
    
    @IBAction private func loginTapped(_ sender: LGButton) {
        guard let email = loginEmailTextField.text, email.isEmail(),
              let password = loginPasswordTextField.text, password.count > 5 else {
                  showViewControllerAlert(title: viewModel.errorText, message: viewModel.errorTextWithFields)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] result, error in
            if error == nil {
                guard let self = self else { return }
                
                let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: Constants.mainStoryboardIdentifier)
                self.present(vc, animated: true)
            } else {
                guard let self = self else { return }
                
                self.showViewControllerAlert(title: self.viewModel.errorText, message: self.viewModel.errorTextWithSignIn)
            }
        }
    }
    
    @IBAction private func signUpTapped(_ sender: UIButton) {
        performSegue(withIdentifier: viewModel.toRegisterText, sender: nil)
    }
}

//MARK: - Functions
extension LoginViewController {
    
    private func setupTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    //Checks the current running device and loads the appropriate constraints based on the device.
    private func portraitConstraints() {
        switch UIDevice().type {
        case .iPod7:
            topAnchorConstraint.constant = 32
            loginLabel.font = UIFont.init(name: Constants.futuraBold, size: 23)
            signInLabel.font = UIFont.init(name: Constants.futura, size: 15)
            signUpLabel.font = UIFont.init(name: Constants.futura, size: 15)
            signUpButton.titleLabel?.font = UIFont(name: Constants.futuraBold, size: 15)
        case .iPhoneSE2:
            topAnchorConstraint.constant = 32
            loginLabel.font = UIFont.init(name: Constants.futuraBold, size: 32)
            signInLabel.font = UIFont.init(name: Constants.futura, size: 17)
            signUpLabel.font = UIFont.init(name: Constants.futura, size: 16)
            signUpButton.titleLabel?.font = UIFont(name: Constants.futuraBold, size: 16)
        case .iPhone8:
            topAnchorConstraint.constant = 64
            loginLabel.font = UIFont.init(name: Constants.futuraBold, size: 32)
            signInLabel.font = UIFont.init(name: Constants.futura, size: 17)
            signUpLabel.font = UIFont.init(name: Constants.futura, size: 16)
            signUpButton.titleLabel?.font = UIFont(name: Constants.futuraBold, size: 16)
        default:
            break
        }
    }
    
    private func landscapeConstraints() {
        switch UIDevice().type {
        default:
            topAnchorConstraint.constant = 28
        }
    }
    
    private func setupTextFields() {
        loginEmailTextField.placeholder = viewModel.emailText
        loginEmailTextField.title = viewModel.emailText
        loginEmailTextField.lineColor = .lightGray
        loginEmailTextField.selectedLineColor = .white
        loginEmailTextField.selectedTitleColor = .white
        loginEmailTextField.textColor = .white
        loginEmailTextField.keyboardType = .emailAddress
        loginEmailTextField.iconType = .image
        loginEmailTextField.iconColor = .lightGray
        loginEmailTextField.iconImage = UIImage(systemName: viewModel.envelopeImage)
        loginEmailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        
        loginPasswordTextField.placeholder = viewModel.passwordText
        loginPasswordTextField.title = viewModel.passwordText
        loginPasswordTextField.lineColor = .lightGray
        loginPasswordTextField.selectedLineColor = .white
        loginPasswordTextField.selectedTitleColor = .white
        loginPasswordTextField.textColor = .white
        loginPasswordTextField.enablePasswordToggle()
        loginPasswordTextField.iconType = .image
        loginPasswordTextField.iconColor = .lightGray
        loginPasswordTextField.iconImage = UIImage(systemName: viewModel.lockImage)
        loginPasswordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
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
                floatingLabelTextField.errorMessage = viewModel.passwordTooShortText
            } else {
                floatingLabelTextField.errorMessage = nil
            }
                
            if text.count == 0 {
                floatingLabelTextField.errorMessage = nil
            }
        }
    }
}
