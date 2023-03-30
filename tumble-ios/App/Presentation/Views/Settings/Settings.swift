//
//  Settings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/28/23.
//

import SwiftUI
import StoreKit

struct Settings: View {
    
    @AppStorage(StoreKey.appearance.rawValue) var appearance: String = AppearanceType.system.rawValue
    @AppStorage(StoreKey.locale.rawValue) var language: String = LanguageTypes.english.localeName
    @ObservedObject var viewModel: SettingsViewModel
    
    let removeSchedule: (String) -> Void
    let updateBookmarks: () -> Void
    let onChangeSchool: (School) -> Void
    
    var body: some View {
        VStack {
            List {
                Section {
                    NavigationLink(destination: AnyView(
                        AppearanceSettings()
                    ), label: {
                        SettingsNavLink(title: NSLocalizedString("Appearance", comment: ""), current: appearance)
                    })
                    NavigationLink(destination: AnyView(
                        LanguageSettings()
                    ), label: {
                        SettingsNavLink(title: NSLocalizedString("App language", comment: ""), current: LanguageTypes.fromLocaleName(language)?.displayName ?? "")
                    })
                    NavigationLink(destination: AnyView(
                            NotificationSettings(
                                clearAllNotifications: clearAllNotifications,
                                scheduleNotificationsForAllCourses: scheduleNotificationsForAllCourses)
                    ), label: {
                        SettingsNavLink(title: NSLocalizedString("Notifications", comment: ""))
                    })
                }
                Section {
                    NavigationLink(destination: AnyView(SchoolSelectionSettings(onChangeSchool: onChangeSchool)), label: {
                        SettingsNavLink(title: NSLocalizedString("School", comment: ""), current: viewModel.universityName)
                    })
                    NavigationLink(destination: AnyView(
                        BookmarksSettings(
                            parentViewModel: viewModel,
                            updateBookmarks: updateBookmarks,
                            removeSchedule: removeSchedule
                        )), label: {
                            SettingsNavLink(title: NSLocalizedString("Bookmarks", comment: ""))
                    })
                }
                Section {
                    SettingsButton(onClick: {
                        UIApplication.shared.requestReview()
                    }, title: NSLocalizedString("App review", comment: ""), image: "square.and.arrow.up")
                    SettingsButton(onClick: {
                        UIApplication.shared.shareFeedback()
                    }, title: NSLocalizedString("Share feedback", comment: ""), image: "envelope")
                    NavigationLink(destination: AnyView(EmptyView()), label: {
                        SettingsNavLink(title: NSLocalizedString("How to use the app", comment: ""))
                    })
                }
            }
        }
        .navigationTitle(NSLocalizedString("Settings", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    fileprivate func clearAllNotifications() -> Void {
        viewModel.clearAllNotifications()
        AppController.shared.toast = Toast(
            type: .success,
            title: "Cancelled notifications",
            message: "Cancelled all available notifications set for events"
        )
    }
    
    fileprivate func scheduleNotificationsForAllCourses() -> Void {
        viewModel.scheduleNotificationsForAllEvents(completion: { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    AppController.shared.toast = Toast(
                        type: .success,
                        title: NSLocalizedString("Scheduled notifications", comment: ""),
                        message: NSLocalizedString("Scheduled notifications for all available events", comment: "")
                    )
                }
            case .failure:
                DispatchQueue.main.async {
                    AppController.shared.toast = Toast(
                        type: .error,
                        title: NSLocalizedString("Error", comment: ""),
                        message: NSLocalizedString("Failed to set notifications for all available events", comment: "")
                    )
                }
            }
        })
        
    }
    
    fileprivate func deleteBookmark(id: String) -> Void {
        removeSchedule(id)
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(
            viewModel: ViewModelFactory.shared.makeViewModelSettings(),
            removeSchedule: {_ in},
            updateBookmarks: {},
            onChangeSchool: {_ in})
    }
}
