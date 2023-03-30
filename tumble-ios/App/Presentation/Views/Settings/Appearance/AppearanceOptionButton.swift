//
//  AppearanceOptionButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

struct AppearanceOptionButton: View {
    
    let appearanceType: AppearanceType
    let onToggle: (AppearanceType) -> Void
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected = true
            onToggle(appearanceType)
        }) {
            HStack {
                Text(appearanceType.rawValue)
                    .font(.system(size: 16))
                    .foregroundColor(.onSurface)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
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
