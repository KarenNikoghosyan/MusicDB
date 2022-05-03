//
//  SettingsView.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 04/08/2021.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var settingsViewModel = SettingsViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    @State private var image: Image? = Image("icon_user")
    @State private var inputImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack() {
                Text(settingsViewModel.settingsTitle)
                    .font(.largeTitle)
                    .padding(.leading, 25.0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {
                    settingsViewModel.showingImagePicker.toggle()
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
                Link(destination: URL(string: settingsViewModel.facebookURL)!, label: {
                    HStack {
                        Image(settingsViewModel.facebookImage)
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(settingsViewModel.followUsString)
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 20.0)
                })
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.init(UIColor.init(red: 233.0 / 255, green: 233.0 / 255, blue: 233.0 / 255, alpha: 1)))
                .cornerRadius(15.0)
                
                Link(destination: URL(string: settingsViewModel.twitterURL)!, label: {
                    HStack {
                        Image(settingsViewModel.twitterImage)
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(settingsViewModel.followUsString)
                            .font(.title3)
                            .foregroundColor(.black)
                        
                    }
                    .padding(.leading, 20.0)
                })
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.init(UIColor(red: 233.0 / 255, green: 233.0 / 255, blue: 233.0 / 255, alpha: 1)))
                .cornerRadius(15.0)
                
                Link(destination: URL(string: settingsViewModel.emailURL)!, label: {
                    HStack {
                        Image(settingsViewModel.emailImage)
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(settingsViewModel.contactUsString)
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
                        Image(settingsViewModel.logoutImage)
                            .resizable()
                            .frame(width: 30.0, height: 30.0)
                        Text(settingsViewModel.logoutString)
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                    .padding(.leading, 20.0)
                })
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.init(UIColor.init(red: 233.0 / 255, green: 233.0 / 255, blue: 233.0 / 255, alpha: 1)))
                .cornerRadius(15.0)
                .sheet(isPresented: $settingsViewModel.showingImagePicker, onDismiss: loadImage, content: {
                    ImagePicker(image: self.$inputImage)
                })
                .onAppear(perform: {
                    guard let data = settingsViewModel.getImageFromUserDefaults(),
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
        settingsViewModel.setImageToUserDefaults(imageData: data)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
