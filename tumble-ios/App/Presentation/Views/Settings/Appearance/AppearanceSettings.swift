//
//  AppearanceSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

enum AppearanceTypes: String, Identifiable {
    var id: UUID {
       return UUID()
    }
    case system = "Automatic"
    case light = "Light"
    case dark = "Dark"
    
    var displayName: String {
        switch self {
        case .system:
            return NSLocalizedString("Automatic", comment: "")
        case .light:
            return NSLocalizedString("Light", comment: "")
        case .dark:
            return NSLocalizedString("Dark", comment: "")
        }
    }
    
    static func fromRawValue(_ rawValue: String) -> AppearanceTypes? {
        return allCases.first(where: { $0.rawValue == rawValue })
    }
    
    static var allCases = [system, light, dark]
}

struct AppearanceSettings: View {
    
    @AppStorage(StoreKey.appearance.rawValue) var appearance: String = AppearanceTypes.system.rawValue
    
    var body: some View {
        CustomList {
            CustomListGroup {
                ForEach(AppearanceTypes.allCases) { type in
                    SettingsRadioButton(
                        title: type.displayName,
                        isSelected: Binding<Bool>(
                            get: { appearance == type.rawValue },
                            set: { selected in
                                if selected {
                                    appearance = type.rawValue
                                }
                            }
                        )
                    )
                }
            }
        }
    }
    
}

struct AppearanceSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettings()
    }
}
