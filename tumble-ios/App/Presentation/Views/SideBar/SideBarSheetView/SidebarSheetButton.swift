//
//  SidebarSheetButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-11.
//

import SwiftUI

struct SidebarSheetButton: View {

    let image: String
    let title: String
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                Image(systemName: image)
                    .font(.system(size: 20))
                    .frame(width: 30)
                    .padding(.trailing, 15)
                    .foregroundColor(.primary)
                Text(title)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.onSurface)
                Spacer()
            }
            .padding(15)
        }
        .buttonStyle(SidebarSheetButtonStyle())
        .padding([.leading, .trailing], 20)
        .padding([.bottom, .top], 10)
    }
}
