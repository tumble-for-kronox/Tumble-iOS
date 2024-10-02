//
//  LoginHeader.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct LoginHeader: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(NSLocalizedString("Log in", comment: ""))
                .infoHeaderMedium()
            Text(NSLocalizedString("Please log in to continue", comment: ""))
                .infoBodyMedium(opacity: 0.75)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 35)
    }
}

struct LoginHeader_Previews: PreviewProvider {
    static var previews: some View {
        LoginHeader()
    }
}
