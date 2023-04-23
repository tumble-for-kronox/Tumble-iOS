//
//  LoginHeader.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct LoginHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(NSLocalizedString("Log in", comment: ""))
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.onBackground)
            Text(NSLocalizedString("Please log in to continue", comment: ""))
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.onBackground.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 25)
    }
}

struct LoginHeader_Previews: PreviewProvider {
    static var previews: some View {
        LoginHeader()
    }
}
