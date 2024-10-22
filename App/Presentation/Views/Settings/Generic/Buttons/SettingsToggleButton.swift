//
//  SettingsToggleButton.swift
//  Tumble
//
//  Created by Adis Veletanlic on 10/22/24.
//

import SwiftUI
import Foundation

struct SettingsToggleButton: View {
    let title: String
    let leadingIcon: String
    let leadingIconBackgroundColor: Color
    var condition: Binding<Bool>
    var callback: (_: Bool) -> Void
    
    var body: some View {
        HStack {
            Toggle(isOn: condition) {
                Label(title, systemImage: leadingIcon)
                    .labelStyle(ColorfulIconLabelStyle(color: leadingIconBackgroundColor))
            }
            .toggleStyle(SwitchToggleStyle(tint: .primary))
        }
        .padding(Spacing.settingsButton)
    }
}
