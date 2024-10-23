//
//  HomeView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct Root: View {
    
    @AppStorage(SharedPreferenceKey.appearance.rawValue) private var appearance = AppearanceType.system.rawValue
    let viewModel: ParentViewModel = ViewModelFactory.shared.makeViewModelParent()
    
    var body: some View {
        ZStack {
            AppParent(viewModel: viewModel)
        }
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.keyboard)
        .onChange(of: appearance) { newValue in
            changeTheme(to: newValue)
        }
    }
    
    func changeTheme(to theme: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.overrideUserInterfaceStyle = getThemeColorScheme(appearance: appearance)
        }
    }
}
