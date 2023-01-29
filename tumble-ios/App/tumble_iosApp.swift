//
//  tumble_iosApp.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

@main
struct tumble_iosApp: App {
    
    init() {
        // Cache the environment variable in app storage (user defaults).
        if let networkSettings = ProcessInfo.processInfo.environment["NETWORK_SETTINGS"] {
            UserDefaults.standard.set(networkSettings, forKey: StoreKey.networkSettings.rawValue)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(viewModel: ViewModelFactory().makeViewModelRoot()).onAppear()
        }
    }
}
