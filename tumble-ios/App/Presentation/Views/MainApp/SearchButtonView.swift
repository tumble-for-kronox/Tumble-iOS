//
//  SearchButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-26.
//

import SwiftUI

typealias CheckForNewSchedules = () -> Void

struct SearchButtonView: View {
    let checkForNewSchedules: CheckForNewSchedules
    var body: some View {
        NavigationLink(destination:
                        SearchParentView(viewModel: ViewModelFactory().makeViewModelSearch(), checkForNewSchedules: checkForNewSchedules)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton()), label: {
            Image(systemName: "magnifyingglass")
                    .font(.system(size: 17))
                .foregroundColor(Color("OnBackground"))
        })
    }
}

