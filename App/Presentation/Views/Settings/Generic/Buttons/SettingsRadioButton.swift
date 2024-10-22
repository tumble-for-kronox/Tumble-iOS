//
//  AppearanceOptionButton.swift
//  Tumble
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

struct SettingsRadioButton: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            isSelected = true
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.onSurface)
                    .padding(.leading, Spacing.extraSmall)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 25, height: 25)
                        .foregroundColor(.onPrimary)
                        .background(Color.primary)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .inset(by: 2)
                        .stroke(Color.onSurface.opacity(0.2), lineWidth: 2)
                        .frame(width: 25, height: 25)
                }
            }
            .padding([.top, .bottom, .trailing], Spacing.medium)
        }
    }
}
