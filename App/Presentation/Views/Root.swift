//
//  HomeView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct Root: View {
    
    @AppStorage(SharedPreferenceKey.appearance.rawValue) private var appearance = AppearanceTypes.system.rawValue
    let viewModel: ParentViewModel = ViewModelFactory.shared.makeViewModelParent()
    
    var body: some View {
        ZStack {
            AppParent(viewModel: viewModel)
        }
        .preferredColorScheme(getThemeColorScheme(appearance: appearance))
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.keyboard)
    }
}
