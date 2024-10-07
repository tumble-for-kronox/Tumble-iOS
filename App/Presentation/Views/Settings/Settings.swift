//
//  Settings.swift
//  Tumble
//
//  Created by Adis Veletanlic on 3/28/23.
//

import RealmSwift
import SwiftUI
import MijickPopupView

struct Settings: View {
    
    @AppStorage(StoreKey.appearance.rawValue) var appearance: String = AppearanceTypes.system.rawValue
    @AppStorage(StoreKey.notificationOffset.rawValue) var offset: Int = 60
    @ObservedObject var viewModel: SettingsViewModel
    
    @ObservedResults(Schedule.self, configuration: realmConfig) var schedules
    
    let currentLocale = Bundle.main.preferredLocalizations.first
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @State private var showShareSheet: Bool = false
    
    var body: some View {
        SettingsList {
            SettingsListGroup {
                SettingsNavigationButton(
                    title: NSLocalizedString("Appearance", comment: ""),
                    current: NSLocalizedString($appearance.wrappedValue, comment: ""),
                    leadingIcon: "moon",
                    leadingIconBackgroundColor: .purple,
                    destination: AnyView(AppearanceSettings(appearance: $appearance))
                )
                Divider()
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
            SettingsListGroup {
                SettingsNavigationButton(
                    title: NSLocalizedString("Notification offset", comment: ""),
                    leadingIcon: "clock",
                    leadingIconBackgroundColor: .red,
                    destination: AnyView(NotificationOffsetSettings(
                        offset: $offset,
                        rescheduleNotifications: rescheduleNotifications
                    ))
                )
                Divider()
                SettingsNavigationButton(
                    title: NSLocalizedString("Bookmarks", comment: ""),
                    leadingIcon: "bookmark",
                    leadingIconBackgroundColor: .primary,
                    destination: AnyView(BookmarksSettings(
                        parentViewModel: viewModel
                    ))
                )
            }
            SettingsListGroup {
                SettingsExternalButton(
                    title: NSLocalizedString("Review the app", comment: ""),
                    leadingIcon: "star.leadinghalf.filled",
                    leadingIconBackgroundColor: .yellow,
                    action: UIApplication.shared.openAppStoreForReview
                )
                Divider()
                SettingsExternalButton(
                    title: NSLocalizedString("Share feedback", comment: ""),
                    leadingIcon: "envelope",
                    leadingIconBackgroundColor: .blue,
                    action: UIApplication.shared.shareFeedback
                )
                Divider()
                SettingsExternalButton(
                    title: NSLocalizedString("Share the app", comment: ""),
                    leadingIcon: "square.and.arrow.up",
                    leadingIconBackgroundColor: .green,
                    action: {
                        showShareSheet = true
                    }
                )
            }
            SettingsListGroup {
                SettingsExternalButton(
                    title: NSLocalizedString("Tumble on GitHub", comment: ""),
                    leadingCustomImage: "github-logo",
                    leadingIconBackgroundColor: .white,
                    action: UIApplication.shared.openGitHub
                )
                SettingsExternalButton(
                    title: NSLocalizedString("Tumble on Discord", comment: ""),
                    leadingCustomImage: "discord-logo",
                    leadingIconBackgroundColor: .blue,
                    action: UIApplication.shared.openDiscord
                )
            }
            if let appVersion = appVersion {
                Text("Tumble, iOS v.\(appVersion)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.onBackground.opacity(0.7))
                    .padding(35)
            }
        }
        .sheet(isPresented: $showShareSheet, content: {
            ShareSheet()
        })
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
            PopupToast(popup: PopupFactory.shared.noAvailableBookmarks()).showAndStack()
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
            PopupToast(popup: PopupFactory.shared.noAvailableBookmarks()).showAndStack()
        }
    }
    
    var schedulesAvailable: Bool {
        !schedules.isEmpty || !schedules.filter({ $0.toggled }).isEmpty
    }
}
