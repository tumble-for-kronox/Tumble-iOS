//
//  AppLanguageButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-31.
//

import SwiftUI

struct AppLanguageButton: View {
    var body: some View {
        Button(action: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }, label: {
            HStack {
                Text(NSLocalizedString("App language", comment: ""))
                    .font(.system(size: 17))
                    .foregroundColor(.onBackground)
                Spacer()
                if let currentLocale = Bundle.main.preferredLocalizations.first,
                    let displayName = LanguageTypes.fromLocaleName(currentLocale)?.displayName {
                    Text(displayName)
                        .font(.system(size: 17))
                        .foregroundColor(.onSurface.opacity(0.7))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray.opacity(0.5))
            }
        })
        .listRowBackground(Color.surface)
        .padding(.horizontal, 15)
    }
}

struct AppLanguageButton_Previews: PreviewProvider {
    static var previews: some View {
        AppLanguageButton()
    }
}
