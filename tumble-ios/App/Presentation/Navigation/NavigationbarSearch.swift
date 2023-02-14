//
//  SearchButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-26.
//

import SwiftUI

struct NavigationbarSearch: View {
    
    @StateObject var viewModel: SearchPage.SearchPageViewModel
    let backButtonTitle: String
    let checkForNewSchedules: () -> Void
    @Binding var universityImage: Image?
    
    var body: some View {
        NavigationLink(destination:
            SearchPage(viewModel: viewModel, universityImage: $universityImage, checkForNewSchedules: checkForNewSchedules)
            .customNavigationBackButton(previousPage: backButtonTitle, callback: checkForNewSchedules)
           , label: {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundColor(.onBackground)
        })
    }
    
    private func resetSearchResults() -> Void {
        viewModel.resetSearchResults()
    }
    
}

