//
//  SearchButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-26.
//

import SwiftUI

struct NavigationbarSearch: View {
    
    @ObservedObject var viewModel: SearchViewModel
    let checkForNewSchedules: () -> Void
    @Binding var universityImage: Image?
    
    var body: some View {
        NavigationLink(destination:
            Search(
                viewModel: viewModel,
                universityImage: $universityImage,
                checkForNewSchedules: checkForNewSchedules
            )
            .navigationBarTitle(NSLocalizedString("Search", comment: ""))
           , label: {
            Image(systemName: "magnifyingglass")
                .actionIcon()
        })
    }
    
    private func resetSearchResults() -> Void {
        viewModel.resetSearchResults()
    }
    
}

