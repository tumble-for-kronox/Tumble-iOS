//
//  LanguageSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-30.
//

import SwiftUI

enum LanguageTypes: String, Identifiable {
    
    var id: UUID {
        return UUID()
    }
    
    case english = "English"
    case swedish = "Swedish"
    
    static var allCases = [english, swedish]
}

struct LanguageSettings: View {
    
    @AppStorage(StoreKey.language.rawValue) var selectedLanguage = LanguageTypes.english.rawValue
    
    var body: some View {
        List {
            Section {
                ForEach(LanguageTypes.allCases, id: \.self) { type in
                    SettingsRadioButton(
                        title: type.rawValue,
                        isSelected: Binding<Bool>(
                            get: { selectedLanguage == type.rawValue },
                            set: { selected in
                                if selected {
                                    selectedLanguage = type.rawValue
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
