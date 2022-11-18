//
//  DrawerRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct DrawerItem: View {
    var onClick: () -> Void
    let title: String
    let image: String
    var body: some View {
        VStack {
            Button(action: onClick, label: {
                Image(systemName: image)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Color("PrimaryColor").opacity(0.9))
                    .clipShape(Circle())
            })
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color("BackgroundColor"))
        }
        .padding(.bottom, 25)
    }
}
