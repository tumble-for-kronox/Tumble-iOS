//
//  AppearanceSettings.swift
//  Tumble
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

struct AppearanceSettings: View {
    @Binding var appearance: String
    let updateAppearance: (String) -> Void
    
    var body: some View {
        SettingsList {
            SettingsListGroup {
                ForEach(AppearanceTypes.allCases) { type in
                    SettingsRadioButton(
                        title: NSLocalizedString(type.displayName, comment: ""),
                        isSelected: Binding<Bool>(
                            get: { appearance == type.rawValue },
                            set: { selected in
                                if selected {
                                    appearance = type.rawValue
                                    updateAppearance(appearance)
                                }
                            }
                        )
                    )
                    if !(AppearanceTypes.allCases.last?.rawValue == type.rawValue) {
                        Divider()
                    }
                }
            }
        }
    }
}
