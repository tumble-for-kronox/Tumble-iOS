//
//  User.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserOverview: View {
    
    @ObservedObject var viewModel: AccountPageViewModel
        
    @State private var inputImage: UIImage?
    @State private var showImagePicker: Bool = false
    
    let schoolName: String
    let createToast: (ToastStyle, String, String) -> Void
    let updateUserImage: (UIImage) -> Void
        
    var body: some View {
        ZStack {
            Color.surface
            VStack {
                HStack {
                    Button(action: {
                        showImagePicker = true
                    }, label: {
                        UserAvatar(image: $viewModel.userController.profilePicture, name: viewModel.userController.user!.name)
                    })
                    VStack (alignment: .leading, spacing: 0) {
                        Text(viewModel.userController.user!.name)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                        Text(viewModel.userController.user!.username)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                        Text(schoolName)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .padding(.top, 10)
                        Spacer()
                    }
                    .padding(10)
                    .padding(.top, 20)
                }
                .padding()
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3.5, alignment: .leading)
                .background(Color.background)
                .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                Spacer()
                Resources(viewModel: viewModel)
            }
            
        }
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage, content: {
            ImagePicker(image: self.$inputImage)
        })
        .edgesIgnoringSafeArea([.top, .bottom])
    }
    
    func loadImage() -> Void {
        guard let inputImage = inputImage else { return }
        if inputImage.getSizeIn(.megabyte) <= 8 {
            updateUserImage(inputImage)
            createToast(.success, "New profile picture", "Successfully changed profile picture for your account")
        } else {
            createToast(.info, "Image too large", "Profile pictures are limited to 8MB")
        }
        
    }
    
}
