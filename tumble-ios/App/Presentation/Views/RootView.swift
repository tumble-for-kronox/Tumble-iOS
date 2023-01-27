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
    @AppStorage(StoreKey.overrideSystem.rawValue) private var overrideSystem = false
    @AppStorage(StoreKey.theme.rawValue) private var isDarkMode = false
    @ObservedObject var viewModel: RootViewModel
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)
            // Only show rest of the app if a school is chosen
            if !(viewModel.missingSchool) {
                AppView(viewModel: ViewModelFactory().makeViewModelApp())
            }
        }
        // Picker sheet will appear if school is not set
        .sheet(isPresented: $viewModel.missingSchool) {
            SchoolSelectView(selectSchoolCallback: { school in
                viewModel.onSelectSchool(school: school)
            }).interactiveDismissDisabled(true)
        }
        .environment(\.colorScheme, isDarkMode && overrideSystem ? .dark : .light)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .ignoresSafeArea(.keyboard)
        .JMAlert(showModal: $viewModel.userOnBoarded, for: [.notification, .camera]).onSubmit {
            viewModel.onUserOnboarded()
        }
    }
}
