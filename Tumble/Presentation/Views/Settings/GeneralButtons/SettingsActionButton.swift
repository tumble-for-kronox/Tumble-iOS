//
//  SettingsActionButton.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-06-06.
//

import SwiftUI

struct SettingsActionButton: View {
    
    @State private var isConfirming: Bool = false
    
    let settingsDetails: SettingsDetails?
    let title: String
    let color: Color
    let action: () -> Void
    
    init(
        settingsDetails: SettingsDetails?,
        title: String,
        color: Color = .primary,
        action: @escaping () -> Void)
    {
        self.settingsDetails = settingsDetails
        self.title = title
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            isConfirming = true
        }, label: {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                Spacer()
            }
            .padding(7)
        })
        .confirmationDialog(
            settingsDetails!.titleKey,
            isPresented: $isConfirming, presenting: settingsDetails
        ) { _ in
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
