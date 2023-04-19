//
//  AppearanceSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

struct AppearanceSettings: View {
    
    @Binding var appearance: String
    
    var body: some View {
        CustomList {
            CustomListGroup {
                ForEach(AppearanceTypes.allCases) { type in
                    SettingsRadioButton(
                        title: NSLocalizedString(type.displayName, comment: ""),
                        isSelected: Binding<Bool>(
                            get: { appearance == type.rawValue },
                            set: { selected in
                                if selected {
                                    appearance = type.rawValue
                                }
                            }
                        )
                    )
                    if !(AppearanceTypes.allCases.last?.rawValue == type.rawValue) {
                        Divider()
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}
