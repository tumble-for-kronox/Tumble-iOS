//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

import SwiftUI
import PermissionsSwiftUICamera
import PermissionsSwiftUINotification

struct RootView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage(UserDefaults.StoreKey.overrideSystem.rawValue) private var overrideSystem = false
    @AppStorage(UserDefaults.StoreKey.theme.rawValue) private var isDarkMode = false
    @StateObject private var viewModel = RootViewModel()
    var body: some View {
        ZStack {
            Color("BackgroundColor")
            TabSwitcherView()
                // Picker sheet will appear if school is not set
                .sheet(isPresented: $viewModel.missingSchool) {
                    SchoolSelectView(selectSchoolCallback: { school in
                        viewModel.onSelectSchool(school: school)
                    }).interactiveDismissDisabled(true)
            }
        }
        .environment(\.colorScheme, isDarkMode && overrideSystem ? .dark : .light)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .ignoresSafeArea(.keyboard)
        .JMAlert(showModal: $viewModel.userOnboarded, for: [.notification, .camera]).onSubmit {
            viewModel.onUserOnboarded()
        }
    }
}
