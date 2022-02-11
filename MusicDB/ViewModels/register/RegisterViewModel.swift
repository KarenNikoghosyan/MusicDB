//
//  RegisterViewModel.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 11/02/2022.
//

import Foundation

class RegisterViewModel {
    
    //Firebase
    let usersText = "users"
    let nameFirebase = "name"
    let trackIDsFirebase = "trackIDs"
    let albumIDsFirebase = "albumIDs"
        
    let errorText = "Error"
    let nameText = "Name"
    let emailText = "Email"
    let passwordText = "Password"
    let confirmPasswordText = "Confirm Password"
    
    //TextFields
    let checkTheFieldsText = "Please check the fields"
    let accountExistsText = "Account is already exists"
    let personCircleImage = "person.circle"
    let envelopeImage = "envelope"
    let lockImage = "lock"
    let nameTooShortText = "Name is too short"
    let invalidEmailText = "Invalid email"
    let passwordShortText = "Password is too short"
    let passwordDontMatchText = "Passwords don't match"
    
}
