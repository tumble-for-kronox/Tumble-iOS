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

struct ListRowExternalButton: View {
    let title: String
    let current: String?
    let action: () -> Void
    let trailingIcon: String
    let leadingIcon: String
    let leadingIconBackgorundColor: Color
    
    init(
        title: String,
        current: String? = nil,
        leadingIcon: String,
        trailingIcon: String = "arrow.up.right",
        leadingIconBackgorundColor: Color = Color.onSurface,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.current = current
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.leadingIconBackgorundColor = leadingIconBackgorundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            action()
        }, label: {
            HStack(spacing: 0) {
                Label(title, systemImage: leadingIcon)
                    .labelStyle(ColorfulIconLabelStyle(color: leadingIconBackgorundColor))
                Spacer()
                if let current = current {
                    Text(current)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.onSurface.opacity(0.4))
                        .padding(.trailing, 10)
                }
                Image(systemName: trailingIcon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.onSurface.opacity(0.4))
            }
            .padding(10)
        })
    }
}
