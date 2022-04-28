//
//  SettingsView.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 04/08/2021.
//

import SwiftUI
import UIKit
import FirebaseAuth

struct SettingsView: View {
    
    @State private var image: Image? = Image("icon_user")
    @Environment(\.presentationMode) var presentationMode
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack() {
                Text("Settings")
                    .font(.largeTitle)
                    .padding(.leading, 25.0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {
                    showingImagePicker.toggle()
                }, label: {
                    ZStack {
                        if image != nil {
                            image?
                                .resizable()
                                .frame(width: 160, height: 160)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 25.0)
                })
                Link(destination: URL(string: "https://www.facebook.com/karen.nikoghosyan.1/")!, label: {
                    HStack {
                        Image("facebook")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Follow us")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 20.0)
                })
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.init(UIColor.init(red: 233.0 / 255, green: 233.0 / 255, blue: 233.0 / 255, alpha: 1)))
                .cornerRadius(15.0)
                
                Link(destination: URL(string: "https://twitter.com/nikoghosyan11")!, label: {
                    HStack {
                        Image("twitter")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Follow us")
                            .font(.title3)
                            .foregroundColor(.black)
                        
                    }
                    .padding(.leading, 20.0)
                })
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.init(UIColor(red: 233.0 / 255, green: 233.0 / 255, blue: 233.0 / 255, alpha: 1)))
                .cornerRadius(15.0)
                
                Link(destination: URL(string: "mailto:karen1111996@gmail.com")!, label: {
                    HStack {
                        Image("email")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Contact us")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 20.0)
                })
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.init(UIColor(red: 233.0 / 255, green: 233.0 / 255, blue: 233.0 / 255, alpha: 1)))
                .cornerRadius(15.0)
                
                Spacer()
                    .frame(height: 70)
                
                Button(action: {
                    
                    self.presentationMode.wrappedValue.dismiss()
                    NotificationCenter.default.post(name: .MoveToLogin, object: nil, userInfo: nil)
                }, label: {
                    HStack {
                        Image("logout")
                            .resizable()
                            .frame(width: 30.0, height: 30.0)
                        Text("Log Out")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                    .padding(.leading, 20.0)
                })
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.init(UIColor.init(red: 233.0 / 255, green: 233.0 / 255, blue: 233.0 / 255, alpha: 1)))
                .cornerRadius(15.0)
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage, content: {
                    ImagePicker(image: self.$inputImage)
                })
                .onAppear(perform: {
                    guard let data = UserDefaults.standard.getProfileImage(),
                          let imageTemp = UIImage(data: data) else {return}
                    image = Image(uiImage: imageTemp)
                })
                
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
        image = Image(uiImage: inputImage)
        
        guard let data = inputImage.jpegData(compressionQuality: 1) else {return}
        UserDefaults.standard.setProfileImage(imageData: data)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
