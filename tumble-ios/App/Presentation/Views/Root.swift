//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct Root: View {
    
    @ObservedObject var viewModel: RootViewModel
    @AppStorage(StoreKey.appearance.rawValue) private var appearance = AppearanceTypes.system.rawValue
    
    var body: some View {
        ZStack {
            switch viewModel.currentView {
            case .onboarding:
                if let onBoardingViewModel = viewModel.onBoardingViewModel {
                    OnBoarding(viewModel: onBoardingViewModel)
                }
            case .app:
                if let parentViewModel = viewModel.parentViewModel {
                    AppParent(viewModel: parentViewModel)
                }
            }
        }
        .preferredColorScheme(getThemeColorScheme(appearance: appearance))
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.keyboard)
    }
}

