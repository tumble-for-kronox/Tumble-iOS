//
//  LanguageSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-30.
//

import SwiftUI

enum LanguageTypes: Identifiable {
    
    var id: UUID {
        return UUID()
    }
    
    case english
    case swedish
    
    static var allCases = [english, swedish]
    
    var localeName: String {
        switch self {
        case .english:
            return "en"
        case .swedish:
            return "se"
        }
    }
    
    var displayName: String {
        switch self {
        case .english:
            return NSLocalizedString("English", comment: "")
        case .swedish:
            return NSLocalizedString("Swedish", comment: "")
        }
    }
    
    static func fromLocaleName(_ localeName: String) -> LanguageTypes? {
        return allCases.first(where: { $0.localeName == localeName })
    }
    
}

struct LanguageSettings: View {
    
    @AppStorage(StoreKey.locale.rawValue) var locale = LanguageTypes.english.localeName
    
    var body: some View {
        List {
            Section {
                ForEach(LanguageTypes.allCases, id: \.self) { type in
                    SettingsRadioButton(
                        title: type.displayName,
                        isSelected: Binding<Bool>(
                            get: { locale == type.localeName },
                            set: { selected in
                                if selected {
                                    locale = type.localeName
                                    print("CHANGED LOCALE TO \(locale)")
                                }
                            }
                        )
                    )
                }
            }
        }
    }
}

struct LanguageSettings_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSettings()
    }
}
