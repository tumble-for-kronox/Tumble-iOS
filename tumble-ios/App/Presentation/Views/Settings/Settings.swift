//
//  Settings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/28/23.
//

import SwiftUI
import RealmSwift

struct Settings: View {
    
    @AppStorage(StoreKey.appearance.rawValue) var appearance: String = AppearanceTypes.system.rawValue
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedResults(Schedule.self) var schedules
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
                }
                CustomListGroup {
                    ListRowNavigationItem(
                        title: NSLocalizedString("Notifications", comment: ""),
                        destination: AnyView(NotificationSettings(
                            clearAllNotifications: clearAllNotifications,
                            scheduleNotificationsForAllCourses: scheduleNotificationsForAllCourses,
                            rescheduleNotifications: rescheduleNotifications)))
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
                    Divider()
                    ListRowActionItem(
                        title: NSLocalizedString("Tumble on GitHub", comment: ""),
                        image: "chevron.left.forwardslash.chevron.right",
                        imageColor: .primary,
                        action: {
                        if let url = URL(string: "https://github.com/adisve/tumble-ios") {
                            UIApplication.shared.open(url)
                        }
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
        if schedulesAvailable() {
            viewModel.clearAllNotifications()
        }
    }
    
    fileprivate func scheduleNotificationsForAllCourses() -> Void {
        if schedulesAvailable() {
            let allEvents = Array(schedules)
                .filter { $0.toggled }
                .flatMap { $0.days }
                .flatMap { $0.events }
                .filter { !($0.dateComponents!.hasDatePassed()) }
            viewModel.scheduleNotificationsForAllEvents(allEvents: allEvents)
        }
    }
    
    func schedulesAvailable() -> Bool {
        if schedules.isEmpty || schedules.filter({ $0.toggled }).isEmpty {
            viewModel.makeToast(
                type: .info,
                title: NSLocalizedString("No available bookmarks", comment: ""),
                message: NSLocalizedString("It looks like there's no available bookmarks", comment: ""))
            return false
        } else { return true }
    }
    
}
