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
    @AppStorage(StoreKey.language.rawValue) var language: String = LanguageTypes.english.rawValue
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
                        SettingsNavLink(title: "Appearance", current: appearance)
                    })
                    NavigationLink(destination: AnyView(
                        LanguageSettings()
                    ), label: {
                        SettingsNavLink(title: "App language", current: language)
                    })
                    NavigationLink(destination: AnyView(
                            NotificationSettings(
                                clearAllNotifications: clearAllNotifications,
                                scheduleNotificationsForAllCourses: scheduleNotificationsForAllCourses)
                    ), label: {
                        SettingsNavLink(title: "Notifications")
                    })
                }
                Section {
                    NavigationLink(destination: AnyView(SchoolSelectionSettings(onChangeSchool: onChangeSchool)), label: {
                        SettingsNavLink(title: "School", current: viewModel.universityName)
                    })
                    NavigationLink(destination: AnyView(
                        BookmarksSettings(
                            parentViewModel: viewModel,
                            updateBookmarks: updateBookmarks,
                            removeSchedule: removeSchedule
                        )), label: {
                            SettingsNavLink(title: "Bookmarks")
                    })
                }
                Section {
                    SettingsButton(onClick: {
                        UIApplication.shared.requestReview()
                    }, title: "App review", image: "square.and.arrow.up")
                    SettingsButton(onClick: {
                        UIApplication.shared.shareFeedback()
                    }, title: "Share feedback", image: "envelope")
                    NavigationLink(destination: AnyView(EmptyView()), label: {
                        SettingsNavLink(title: "How to use the app")
                    })
                }
            }
        }
        .navigationTitle("Settings")
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
                        title: "Scheduled notifications",
                        message: "Scheduled notifications for all available events"
                    )
                }
            case .failure:
                DispatchQueue.main.async {
                    AppController.shared.toast = Toast(
                        type: .error,
                        title: "Error",
                        message: "Failed to set notifications for all available events"
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
