//
//  SearchView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Foundation

extension SearchView {
    @MainActor class SearchViewModel: ObservableObject {
        @Published var searchText: String = ""
    }
}
