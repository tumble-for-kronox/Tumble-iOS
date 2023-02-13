//
//  User.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct User: View {
    
    let user: TumbleUser
    @Binding var autoSignup: Bool
    
    var body: some View {
        ZStack {
                    
            Color("PrimaryColor")
            
            VStack {
                HStack {
                    VStack {
                        UserAvatar(name: user.name)
                        Text("Edit")
                            .font(.system(size: 14, weight: .thin, design: .rounded))
                    }
                    VStack (alignment: .leading) {
                        Text(user.name)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                        Text(user.username)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                        Spacer()
                    }
                    .padding(10)
                    .padding(.top, 35)
                }
                .padding()
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3.5, alignment: .leading)
                .background(Color.background)
                .cornerRadius(15)
                .shadow(radius: 5)
            
                Spacer()
                VStack {
                    UserOptions {
                        Toggle(isOn: $autoSignup, label: {
                            Text("Automatic exam signup")
                                .font(.system(size: 18, design: .rounded))
                        })
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 1.85).cornerRadius(15)
                .background(Color.background)
                .cornerRadius(15, corners: [.topLeft, .topRight])
            }
            
        }
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}
