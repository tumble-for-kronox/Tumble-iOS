//
//  ListRowActionItem.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-02.
//

import SwiftUI

struct SettingsDetails {
    let titleKey: String
    let name: String
    let details: String
}

struct ListRowActionItem: View {
    
    @State private var isConfirming: Bool = false
    
    let settingsDetails: SettingsDetails?
    let title: String
    let current: String?
    let action: () -> Void
    let image: String
    let imageColor: Color
    
    init(
        settingsDetails: SettingsDetails? = nil,
        title: String,
        current: String? = nil,
        image: String = "chevron.right",
        imageColor: Color = Color.onSurface,
        action: @escaping () -> Void
    ) {
        self.settingsDetails = settingsDetails
        self.title = title
        self.current = current
        self.image = image
        self.imageColor = imageColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            if settingsDetails != nil {
                isConfirming = true
            } else {
                action()
            }
        }, label: {
            HStack (spacing: 0) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.onSurface)
                Spacer()
                if let current = current {
                    Text(current)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.onSurface.opacity(0.7))
                        .padding(.trailing, 10)
                }
                Image(systemName: image)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(imageColor.opacity(0.5))
            }
            .padding(2.5)
        })
        .if(settingsDetails != nil) { view in
            view.confirmationDialog(
                settingsDetails!.titleKey,
                isPresented: $isConfirming, presenting: settingsDetails
            ) { detail in
                Button {
                    action()
                } label: {
                    Text(NSLocalizedString(settingsDetails!.name, comment: ""))
                        .foregroundColor(.red)
                }
                Button("Cancel", role: .cancel) {
                    isConfirming = false
                }
            }
        }
    }
}

