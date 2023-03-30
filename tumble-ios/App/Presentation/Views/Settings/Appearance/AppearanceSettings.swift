//
//  AppearanceSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

enum AppearanceType: String, Identifiable {
    var id: UUID {
       return UUID()
    }
    case system = "Automatic"
    case light = "Light"
    case dark = "Dark"
    
    static var allCases = [system, light, dark]
}

struct AppearanceSettings: View {
    
    @AppStorage(StoreKey.appearance.rawValue) var appearance: String = AppearanceType.system.rawValue
    
    var body: some View {
        List {
            Section {
                ForEach(AppearanceType.allCases) { type in
                    AppearanceOptionButton(
                        appearanceType: type,
                        onToggle: changeAppearance,
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
    
    fileprivate func changeAppearance(appearance: AppearanceType) -> Void {
        self.appearance = appearance.rawValue
    }
}

struct AppearanceSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettings()
    }
}
