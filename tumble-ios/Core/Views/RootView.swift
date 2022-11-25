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
        .ignoresSafeArea(.keyboard)
        .JMAlert(showModal: $viewModel.userOnboarded, for: [.notification, .camera]).onSubmit {
            viewModel.onUserOnboarded()
        }
    }
}
