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
    let leadingIcon: String?
    let leadingCustomImage: String?
    let leadingIconBackgroundColor: Color?
    
    init(
        title: String,
        current: String? = nil,
        leadingIcon: String? = nil,
        leadingCustomImage: String? = nil,
        trailingIcon: String = "arrow.up.right",
        leadingIconBackgroundColor: Color = Color.onSurface,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.current = current
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.leadingCustomImage = leadingCustomImage
        self.leadingIconBackgroundColor = leadingIconBackgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            action()
        }, label: {
            HStack {
                if let leadingCustomImage = leadingCustomImage {
                    Image(leadingCustomImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding(8)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .frame(width: 35, height: 35)
                                .foregroundColor(leadingIconBackgroundColor)
                        )
                } else if let leadingIcon = leadingIcon, let leadingIconBackgroundColor = leadingIconBackgroundColor {
                    Label(title, systemImage: leadingIcon)
                        .labelStyle(ColorfulIconLabelStyle(color: leadingIconBackgroundColor))
                }
                
                if let _ = leadingCustomImage {
                    Text(title)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.onSurface)
                        .padding(.leading, Spacing.extraSmall)
                }
                
                Spacer()
                
                if let current = current {
                    Text(current)
                        .font(.system(size: 14))
                        .foregroundColor(.onSurface.opacity(0.4))
                }
                Image(systemName: trailingIcon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.onSurface.opacity(0.4))
            }
        })
        .padding(Spacing.settingsButton)
    }
}

