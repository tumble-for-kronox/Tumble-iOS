//
//  LoginButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct LoginButton: View {
    
    let login: () -> Void
    
    var body: some View {
        Button(action: login, label: {
            HStack {
                Text("Log in")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.onPrimary)
                    .padding(15)
            }
            .frame(maxWidth: .infinity)
        })
        .background(Color("PrimaryColor"))
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 25)
    }
}
