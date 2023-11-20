//
//  ListRowActionItem.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-02.
//

import SwiftUI

struct SettingsDetails {
    let titleKey: String
    let name: String
    let details: String
}

struct SettingsExternalButton: View {
    let title: String
    let current: String?
    let action: () -> Void
    let trailingIcon: String
    let leadingIcon: String
    let leadingIconBackgroundColor: Color
    
    init(
        title: String,
        current: String? = nil,
        leadingIcon: String,
        trailingIcon: String = "arrow.up.right",
        leadingIconBackgroundColor: Color = Color.onSurface,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.current = current
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.leadingIconBackgroundColor = leadingIconBackgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            action()
        }, label: {
            HStack {
                Label(title, systemImage: leadingIcon)
                    .labelStyle(ColorfulIconLabelStyle(color: leadingIconBackgroundColor))
                Spacer()
                if let current = current {
                    Text(current)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.onSurface.opacity(0.4))
                        .padding(.trailing, 10)
                }
                Image(systemName: trailingIcon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.onSurface.opacity(0.4))
            }
        })
        .padding(10)
    }
}
