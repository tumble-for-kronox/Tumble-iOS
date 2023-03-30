//
//  Settings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/28/23.
//

import SwiftUI

struct Settings: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    let removeBookmark: (String) -> Void
    let updateBookmarks: () -> Void
    let onChangeSchool: (School) -> Void
    
    var body: some View {
        VStack {
            List {
                Section {
                    NavigationLink(destination: AnyView(
                        AppearanceSettings()
                    ), label: {
                        SettingsNavLink(title: "Appearance")
                    })
                    NavigationLink(destination: AnyView(EmptyView()), label: {
                        SettingsNavLink(title: "App language")
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
                            bookmarks: $viewModel.bookmarks,
                            toggleBookmark: toggleBookmark,
                            deleteBookmark: deleteBookmark
                        )), label: {
                            SettingsNavLink(title: "Bookmarks")
                    })
                }
                Section {
                    NavigationLink(destination: AnyView(EmptyView()), label: {
                        HStack {
                            SettingsNavLink(title: "App review")
                        }
                    })
                    NavigationLink(destination: AnyView(EmptyView()), label: {
                        SettingsNavLink(title: "Share feedback")
                    })
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
    }
    
    fileprivate func scheduleNotificationsForAllCourses() -> Void {
        viewModel.scheduleNotificationsForAllEvents()
    }
    
    fileprivate func toggleBookmark(id: String, value: Bool) -> Void {
        viewModel.toggleBookmarkVisibility(for: id, to: value)
        updateBookmarks()
    }
    
    fileprivate func deleteBookmark(id: String) -> Void {
        viewModel.deleteBookmark(id: id)
        removeBookmark(id)
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(
            viewModel: ViewModelFactory.shared.makeViewModelSettings(),
            removeBookmark: {_ in},
            updateBookmarks: {},
            onChangeSchool: {_ in})
    }
}
