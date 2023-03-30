//
//  NotificationSettingsButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

struct SettingsButton: View {
    
    let onClick: () -> Void
    let title: String
    let image: String
    
    var body: some View {
        Button(action: onClick, label: {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.onSurface)
                Spacer()
                Image(systemName: image)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.primary)
            }
        })
    }
}
