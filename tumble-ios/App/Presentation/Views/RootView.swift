//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

import SwiftUI


struct RootView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage(StoreKey.overrideSystem.rawValue) private var overrideSystem = false
    @AppStorage(StoreKey.theme.rawValue) private var isDarkMode = false
    @ObservedObject var viewModel: RootViewModel
    var body: some View {
        ZStack {
            Color.background
            
            if viewModel.userNotOnBoarded {
                OnBoardingView(viewModel: viewModel.onBoardingViewModel, updateUserOnBoarded: updateUserOnBoarded)
                    
            } else {
                MainAppView(viewModel: viewModel.appViewModel)
            }
        }
        //.environment(\.colorScheme, .dark)
        //.preferredColorScheme(.dark)
        .environment(\.colorScheme, isDarkMode && overrideSystem ? .dark : .light)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .ignoresSafeArea(.keyboard)
        .edgesIgnoringSafeArea(.all)
    }
    
    func updateUserOnBoarded() -> Void {
        withAnimation {
            self.viewModel.userNotOnBoarded.toggle()
        }
        self.viewModel.appViewModel.schoolIsChosen.toggle()
    }
}
