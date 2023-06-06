//
//  Settings.swift
//  Tumble
//
//  Created by Adis Veletanlic on 3/28/23.
//

import RealmSwift
import SwiftUI

struct Settings: View {
    @AppStorage(StoreKey.appearance.rawValue) var appearance: String = AppearanceTypes.system.rawValue
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedResults(Schedule.self, configuration: realmConfig) var schedules
    let currentLocale = Bundle.main.preferredLocalizations.first
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        VStack {
            CustomList {
                CustomListGroup {
                    ListRowNavigationItem(
                        title: NSLocalizedString("Appearance", comment: ""),
                        current: NSLocalizedString($appearance.wrappedValue, comment: ""),
                        leadingIcon: "moon",
                        leadingIconBackgroundColor: .blue,
                        destination: AnyView(AppearanceSettings(appearance: $appearance))
                    )
                    Divider()
                    ListRowExternalButton(
                        title: NSLocalizedString("App language", comment: ""),
                        current: currentLocale != nil ? LanguageTypes.fromLocaleName(currentLocale!)?.displayName : nil,
                        leadingIcon: "globe",
                        leadingIconBackgorundColor: .blue,
                        action: {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
                        }
                    )
                }
                CustomListGroup {
                    ListRowNavigationItem(
                        title: NSLocalizedString("Notifications", comment: ""),
                        leadingIcon: "bell.badge",
                        leadingIconBackgroundColor: .primary,
                        destination: AnyView(NotificationSettings(
                            clearAllNotifications: clearAllNotifications,
                            scheduleNotificationsForAllCourses: scheduleNotificationsForAllCourses,
                            rescheduleNotifications: rescheduleNotifications
                        ))
                    )
                    Divider()
                    ListRowNavigationItem(
                        title: NSLocalizedString("Bookmarks", comment: ""),
                        leadingIcon: "bookmark",
                        leadingIconBackgroundColor: .primary,
                        destination: AnyView(BookmarksSettings(
                            parentViewModel: viewModel
                        ))
                    )
                }
                CustomListGroup {
                    ListRowExternalButton(
                        title: NSLocalizedString("Review the app", comment: ""),
                        leadingIcon: "star.leadinghalf.filled",
                        leadingIconBackgorundColor: .pink,
                        action: {
                            UIApplication.shared.openAppStoreForReview()
                        }
                    )
                    Divider()
                    ListRowExternalButton(
                        title: NSLocalizedString("Share feedback", comment: ""),
                        leadingIcon: "envelope",
                        leadingIconBackgorundColor: .pink,
                        action: {
                            UIApplication.shared.shareFeedback()
                        }
                    )
                    Divider()
                    ListRowExternalButton(
                        title: NSLocalizedString("Tumble on GitHub", comment: ""),
                        leadingIcon: "chevron.left.forwardslash.chevron.right",
                        leadingIconBackgorundColor: .pink,
                        action: {
                            if let url = URL(string: "https://github.com/adisve/Tumble-iOS") {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                }
                CustomListGroup {
                    LogInOutButton(parentViewModel: viewModel)
                }
                if let appVersion = appVersion {
                    Spacer()
                    Text("Tumble, iOS v.\(appVersion)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.onBackground.opacity(0.7))
                        .padding(25)
                }
            }
            .padding(.top, 20)
            .background(Color.background)
        }
        .background(Color.background)
        .navigationTitle(NSLocalizedString("Settings", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    fileprivate func rescheduleNotifications(previousOffset: Int, newOffset: Int) {
        viewModel.rescheduleNotifications(previousOffset: previousOffset, newOffset: newOffset)
    }
    
    fileprivate func clearAllNotifications() {
        if schedulesAvailable {
            viewModel.clearAllNotifications()
        } else {
            AppController.shared.toast = ToastFactory.shared.noAvailableBookmarks()
        }
    }
    
    fileprivate func scheduleNotificationsForAllCourses() {
        if schedulesAvailable {
            let allEvents = Array(schedules)
                .filter { $0.toggled }
                .flatMap { $0.days }
                .flatMap { $0.events }
                .filter { !($0.dateComponents!.hasDatePassed()) }
            Task {
                await viewModel.scheduleNotificationsForAllEvents(allEvents: allEvents)
            }
        } else {
            AppController.shared.toast = ToastFactory.shared.noAvailableBookmarks()
        }
    }
    
    var schedulesAvailable: Bool {
        !schedules.isEmpty || !schedules.filter({ $0.toggled }).isEmpty
    }
}
