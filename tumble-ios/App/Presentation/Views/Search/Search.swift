//
//  SearchView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct Search: View {
    
    @ObservedObject var viewModel: SearchViewModel
    @State var searchBarText: String = ""
        
    var body: some View {
        GeometryReader { _ in
            VStack (spacing: 0) {
                switch viewModel.status {
                    case .initial:
                        SearchInfo()
                    case .loading:
                        CustomProgressIndicator()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    case .loaded:
                    SearchResults(searchText: searchBarText, numberOfSearchResults: viewModel.programmeSearchResults.count, searchResults: viewModel.programmeSearchResults, onOpenProgramme: onOpenProgramme, universityImage: viewModel.universityImage)
                    case .error:
                        Info(title: viewModel.errorMessageSearch ?? NSLocalizedString("Something went wrong", comment: ""), image: nil)
                    case .empty:
                        Info(title: NSLocalizedString("Schedule is empty", comment: ""), image: nil)
                    }
                SearchBar(searchBarText: $searchBarText, onSearch: onSearch, onClearSearch: onClearSearch)
            }
            .background(Color.background)
            .sheet(item: $viewModel.searchPreviewModel) { model in
                SearchPreview(
                    viewModel: viewModel.createSearchPreviewViewModel(scheduleId: model.id)
                )
                .background(Color.background)
            }
        }
    }
    
    func onSearch(query: String) -> Void {
        viewModel.onSearchProgrammes(searchQuery: query)
    }
    
    func onClearSearch(endEditing: Bool) -> Void {
        viewModel.clearSearchResults(endEditing: endEditing)
    }
    
    func onOpenProgramme(programmeId: String) -> Void {
        viewModel.searchPreviewModel = SearchPreviewModel(id: programmeId)
    }
    
}
