//
//  LoginHeader.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct LoginHeader: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text("Log in")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundColor(.onBackground)
            Text("Please log in to continue")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.onBackground.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 35)
        .padding(.bottom, 25)
    }
}

struct LoginHeader_Previews: PreviewProvider {
    static var previews: some View {
        LoginHeader()
    }
}
