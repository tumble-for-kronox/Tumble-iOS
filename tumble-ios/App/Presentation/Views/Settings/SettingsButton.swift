//
//  SettingsButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/29/23.
//

import SwiftUI

struct SettingsButton: View {
    
    let image: String
    let title: String
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                Image(systemName: image)
                    .font(.system(size: 16))
                    .frame(width: 30)
                    .padding(.trailing, 15)
                    .foregroundColor(.primary)
                Text(title)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.onSurface)
                Spacer()
            }
            .padding(15)
        }
        .buttonStyle(SettingsButtonStyle())
        .padding([.leading, .trailing], 20)
        .padding([.bottom, .top], 10)
    }
}
