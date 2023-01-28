//
//  SupportOption.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct SupportOption: View {
    let title: String
    let image: String
    var body: some View {
        HStack (spacing: 1) {
            Text(title)
            Spacer()
            Image(systemName: image)
                .foregroundColor(Color("PrimaryColor"))
        }
    }
}

