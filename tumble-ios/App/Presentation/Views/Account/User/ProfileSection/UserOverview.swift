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
        
    var body: some View {
        ZStack {
            Color.surface
            VStack {
                HStack {
                    UserAvatar(name: viewModel.userController.user!.name)
                    VStack (alignment: .leading, spacing: 0) {
                        Text(viewModel.userController.user!.name)
                            .font(.system(size: 22, weight: .semibold))
                        Text(viewModel.userController.user!.username)
                            .font(.system(size: 16, weight: .regular))
                        Text(schoolName)
<<<<<<< HEAD
                            .font(.system(size: 16, weight: .regular))
=======
                            .font(.system(size: 18))
>>>>>>> 4b1a201579474cc888fa7caa1cf05fb269f6e142
                            .padding(.top, 10)
                    }
                    .padding(10)
                    .padding(.top, 20)
                }
                .padding()
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3.5, alignment: .leading)
                .background(Color.background)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                Spacer()
                Resources(viewModel: viewModel)
            }
            
        }
        .edgesIgnoringSafeArea([.top, .bottom])
    }
    
}
