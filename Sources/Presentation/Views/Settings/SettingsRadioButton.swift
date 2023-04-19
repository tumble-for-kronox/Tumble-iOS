//
//  AppearanceOptionButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

struct SettingsRadioButton: View {
    
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected = true
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.onSurface)
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
        }
    }
}
