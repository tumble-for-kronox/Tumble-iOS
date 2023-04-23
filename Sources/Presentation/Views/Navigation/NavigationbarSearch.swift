//
//  SearchButtonView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-01-26.
//

import SwiftUI

struct NavigationbarSearch: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationLink(destination:
            Search(viewModel: viewModel)
                .navigationBarTitle(NSLocalizedString("Search", comment: "")),
            label: {
                Image(systemName: "magnifyingglass")
                    .actionIcon()
            })
    }
    
    private func resetSearchResults() {
        viewModel.resetSearchResults()
    }
}
