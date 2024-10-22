//
//  PreferenceSettings.swift
//  Tumble
//
//  Created by Adis Veletanlic on 10/22/24.
//

import SwiftUI
import Foundation

struct PreferenceSettings: View {
    let currentLocale = Bundle.main.preferredLocalizations.first
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsList {
            SettingsListGroup {
                SettingsNavigationButton(
                    title: NSLocalizedString("Appearance", comment: ""),
                    current: NSLocalizedString($viewModel.appearance.wrappedValue, comment: ""),
                    leadingIcon: "moon",
                    leadingIconBackgroundColor: .purple,
                    destination: AnyView(AppearanceSettings(appearance: $viewModel.appearance))
                )
                Divider()
                SettingsNavigationButton(
                    title: NSLocalizedString("Notification offset", comment: ""),
                    leadingIcon: "clock",
                    leadingIconBackgroundColor: .red,
                    destination: AnyView(NotificationOffsetSettings(
                        offset: $viewModel.notificationOffset,
                        rescheduleNotifications: rescheduleNotifications
                    ))
                )
            }
            SettingsListGroup {
                SettingsExternalButton(
                    title: NSLocalizedString("App language", comment: ""),
                    current: currentLocale != nil ? LanguageTypes.fromLocaleName(currentLocale!)?.displayName : nil,
                    leadingIcon: "globe",
                    leadingIconBackgroundColor: .blue,
                    action: {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                )
            }
        }
    }
    
    fileprivate func rescheduleNotifications(previousOffset: Int, newOffset: Int) {
        viewModel.rescheduleNotifications(previousOffset: previousOffset, newOffset: newOffset)
    }
}
