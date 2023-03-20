//
//  LoginSubHeader.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct LoginSubHeader: View {
    
    let schoolName: String
    
    var body: some View {
        VStack (spacing: 15) {
            Text("Use your university credentials for \(schoolName) to sign into your KronoX account")
                .font(.system(size: 16))
                .foregroundColor(.onSurface.opacity(0.75))
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: {}) {
                Text("Need help?")
                    .font(.system(size: 14))
                    .underline()
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top, 35)
    }
}

