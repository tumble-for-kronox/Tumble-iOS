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
    let currentLocale = Bundle.main.preferredLocalizations.first
    let removeSchedule: (String) -> Void
    let updateBookmarks: () -> Void
    let onChangeSchool: (School) -> Void
    
    var body: some View {
        VStack {
            CustomList {
                CustomListGroup {
                    ListRowNavigationItem(
                        title: NSLocalizedString("Appearance", comment: ""),
                        current: NSLocalizedString(appearance, comment: ""),
                        destination: AnyView(AppearanceSettings(appearance: $appearance)))
                    Divider()
                    ListRowActionItem(
                        title: NSLocalizedString("App language", comment: ""),
                        current: currentLocale != nil ? LanguageTypes.fromLocaleName(currentLocale!)?.displayName : nil,
                        action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        })
                    Divider()
                    ListRowNavigationItem(
                        title: NSLocalizedString("Notifications", comment: ""),
                        destination: AnyView(NotificationSettings(
                            clearAllNotifications: clearAllNotifications,
                            scheduleNotificationsForAllCourses: scheduleNotificationsForAllCourses,
                            rescheduleNotifications: rescheduleNotifications)))
                }
                CustomListGroup {
                    ListRowNavigationItem(
                        title: NSLocalizedString("School", comment: ""),
                        current: viewModel.universityName,
                        destination: AnyView(SchoolSelectionSettings(
                            onChangeSchool: onChangeSchool,
                            schools: viewModel.schools)))
                    Divider()
                    ListRowNavigationItem(
                        title: NSLocalizedString("Bookmarks", comment: ""),
                        destination: AnyView(BookmarksSettings(
                            parentViewModel: viewModel,
                            updateBookmarks: updateBookmarks,
                            removeSchedule: removeSchedule
                        )))
                }
                CustomListGroup {
                    ListRowActionItem(
                        title: NSLocalizedString("App review", comment: ""),
                        image: "square.and.arrow.up",
                        imageColor: .primary,
                        action: {
                            UIApplication.shared.requestReview()
                        })
                    Divider()
                    ListRowActionItem(
                        title: NSLocalizedString("Share feedback", comment: ""),
                        image: "envelope",
                        imageColor: .primary,
                        action: {
                            UIApplication.shared.shareFeedback()
                        })
                    Divider()
                    ListRowNavigationItem(
                        title: NSLocalizedString("How to use the app", comment: ""),
                        destination: AnyView(AppUsage()))
                }
                CustomListGroup {
                    LogInOutButton(parentViewModel: viewModel)
                }
            }
            .padding(.top, 20)
            
        }
        .background(Color.background)
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
