//
//  LoginHeader.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct LoginHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(NSLocalizedString("Log in", comment: ""))
                .infoHeaderMedium()
                .padding(.leading, Spacing.medium)
            Text(NSLocalizedString("Please log in to continue", comment: ""))
                .infoBodyMedium(opacity: 0.75)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, Spacing.medium)
    }
}

struct LoginHeader_Previews: PreviewProvider {
    static var previews: some View {
        LoginHeader()
    }
}
