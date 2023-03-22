//
//  User.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserOverview: View {
    
    @ObservedObject var viewModel: AccountViewModel
        
    @State private var inputImage: UIImage?
    @State private var showImagePicker: Bool = false
    
    let schoolName: String
    let createToast: (ToastStyle, String, String) -> Void
        
    var body: some View {
        ZStack {
            Color.surface
            VStack {
                HStack {
                    if let name = viewModel.userController.user?.name,
                       let username = viewModel.userController.user?.username {
                        UserAvatar(name: name)
                        VStack (alignment: .leading, spacing: 0) {
                            Text(name)
                                .font(.system(size: 22, weight: .semibold))
                            Text(username)
                                .font(.system(size: 16, weight: .regular))
                            Text(schoolName)
                                .font(.system(size: 16, weight: .regular))
                                .padding(.top, 10)
                        }
                        .padding(10)
                        .padding(.top, 20)
                    }
                }
                .padding()
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3.5, alignment: .leading)
                .background(Color.background)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                Spacer()
                Resources(parentViewModel: viewModel)
            }
            
        }
        .edgesIgnoringSafeArea([.top, .bottom])
        .background(Color.background)
    }
    
}
