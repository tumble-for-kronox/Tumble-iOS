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
    
    var body: some View {
        VStack {
            CustomList {
                CustomListGroup {
                    ListRowNavigationItem(
                        title: NSLocalizedString("Appearance", comment: ""),
                        current: NSLocalizedString($appearance.wrappedValue, comment: ""),
                        destination: AnyView(AppearanceSettings(appearance: $appearance)))
                    Divider()
                    ListRowActionItem(
                        title: NSLocalizedString("App language", comment: ""),
                        current: currentLocale != nil ? LanguageTypes.fromLocaleName(currentLocale!)?.displayName : nil,
                        action: {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
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
                        current: viewModel.schoolName,
                        destination: AnyView(SchoolSelectionSettings(
                            changeSchool: changeSchool,
                            schools: viewModel.schools)))
                    .id(viewModel.schoolId)
                    Divider()
                    ListRowNavigationItem(
                        title: NSLocalizedString("Bookmarks", comment: ""),
                        destination: AnyView(BookmarksSettings(
                            parentViewModel: viewModel
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
                }
                CustomListGroup {
                    LogInOutButton(parentViewModel: viewModel)
                }
            }
            .padding(.top, 20)
            .background(Color.background)
        }
        .background(Color.background)
        .navigationTitle(NSLocalizedString("Settings", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    fileprivate func changeSchool(schoolId: Int) -> Void {
        viewModel.changeSchool(schoolId: schoolId)
    }
    
    fileprivate func rescheduleNotifications(previousOffset: Int, newOffset: Int) -> Void {
        viewModel.rescheduleNotifications(previousOffset: previousOffset, newOffset: newOffset)
    }
    
    fileprivate func clearAllNotifications() -> Void {
        viewModel.clearAllNotifications()
    }
    
    fileprivate func scheduleNotificationsForAllCourses() -> Void {
        viewModel.scheduleNotificationsForAllEvents()
    }
    
}
