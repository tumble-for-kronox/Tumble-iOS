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
                    .font(.system(size: 23))
                    .frame(width: 23, height: 23)
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Color("PrimaryColor").opacity(95))
                    .clipShape(Circle())
                
            })
            Text(title)
                .font(.mediumFont)
                .bold()
                .foregroundColor(.white)
        }
        .padding(.bottom, 20)
    }
}
