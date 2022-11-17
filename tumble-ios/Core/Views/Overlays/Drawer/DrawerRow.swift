//
//  DrawerRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct DrawerRow: View {
    var onClick: () -> Void
    let title: String
    let image: String
    var body: some View {
        HStack {
            Button(action: onClick, label: {
                Text(title)
                    .font(.system(size: 22))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: image)
                    .font(.system(size: 23))
                    .foregroundColor(.black)
                    .padding(.trailing, 5)
            })
            
            
        }
        .padding(.bottom, 25)
        .contentShape(Rectangle())
    }
}
