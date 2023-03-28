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
        List {
            Section {
                NavigationLink(destination: AnyView(EmptyView()), label: {
                    HStack {
                        Text("Appearance")
                            .font(.system(size: 16))
                            .foregroundColor(.onSurface)
                    }
                })
                NavigationLink(destination: AnyView(EmptyView()), label: {
                    HStack {
                        Text("App language")
                            .font(.system(size: 16))
                            .foregroundColor(.onSurface)
                    }
                })
                NavigationLink(destination: AnyView(EmptyView()), label: {
                    Text("Notifications")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
            }
            Section {
                NavigationLink(destination: AnyView(EmptyView()), label: {
                    HStack {
                        Text("School")
                            .font(.system(size: 16))
                            .foregroundColor(.onSurface)
                        Spacer()
                        Text(viewModel.universityName ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(.onSurface.opacity(0.7))
                    }
                })
                NavigationLink(destination: AnyView(EmptyView()), label: {
                    Text("Bookmarks")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
            }
            Section {
                NavigationLink(destination: AnyView(EmptyView()), label: {
                    HStack {
                        Text("App review")
                            .font(.system(size: 16))
                            .foregroundColor(.onSurface)
                    }
                })
                NavigationLink(destination: AnyView(EmptyView()), label: {
                    Text("Share feedback")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                NavigationLink(destination: AnyView(EmptyView()), label: {
                    Text("How to use the app")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
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
