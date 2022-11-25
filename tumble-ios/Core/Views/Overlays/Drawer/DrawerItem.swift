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
                    .font(.system(size: 17))
                    .frame(width: 17, height: 17)
                    .foregroundColor(Color("OnPrimary"))
                    .padding(15)
                    .background(Color("PrimaryColor").opacity(95))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
            })
            Text(title)
                .padding(.top, 5)
                .font(.subheadline)
                .foregroundColor(Color("OnSurface"))
                
        }
        .padding(.bottom, 30)
    }
}
