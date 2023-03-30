//
//  NotificationSettingsButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

struct NotificationSettingsButton: View {
    
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
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 25, height: 25)
                    .foregroundColor(.onPrimary)
                    .background(Color.primary)
                    .clipShape(Circle())
            }
        })
    }
}
