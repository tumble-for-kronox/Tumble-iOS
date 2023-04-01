//
//  Settings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/28/23.
//

import SwiftUI
import StoreKit

struct Settings: View {
    
    @AppStorage(StoreKey.appearance.rawValue) var appearance: String = AppearanceTypes.system.rawValue
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
                        SettingsNavLink(title: NSLocalizedString("Appearance", comment: ""), current: AppearanceTypes.fromRawValue(appearance)?.displayName ?? "")
                    })
                    AppLanguageButton()
                    NavigationLink(destination: AnyView(
                            NotificationSettings(
                                clearAllNotifications: clearAllNotifications,
                                scheduleNotificationsForAllCourses: scheduleNotificationsForAllCourses,
                                rescheduleNotifications: rescheduleNotifications)
                    ), label: {
                        SettingsNavLink(title: NSLocalizedString("Notifications", comment: ""))
                    })
                }
                Section {
                    NavigationLink(destination: AnyView(
                        SchoolSelectionSettings(onChangeSchool: onChangeSchool, schools: viewModel.schools)), label: {
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
                    NavigationLink(destination: AnyView(AppUsage()), label: {
                        SettingsNavLink(title: NSLocalizedString("How to use the app", comment: ""))
                    })
                }
                LogInOutButton(parentViewModel: viewModel) // Might be a nicer way to do this
            }
        }
        .navigationTitle(NSLocalizedString("Settings", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    fileprivate func rescheduleNotifications(previousOffset: Int, newOffset: Int) -> Void {
        viewModel.rescheduleNotifications(previousOffset: previousOffset, newOffset: newOffset)
    }
    
    fileprivate func clearAllNotifications() -> Void {
        viewModel.clearAllNotifications()
        AppController.shared.toast = Toast(
            type: .success,
            title: NSLocalizedString("Cancelled notifications", comment: ""),
            message: NSLocalizedString("Cancelled all available notifications set for events", comment: "")
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
    
}
