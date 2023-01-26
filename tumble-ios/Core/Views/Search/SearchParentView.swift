//
//  SearchView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SearchParentView: View {
    @StateObject var viewModel: SearchViewModel = SearchViewModel()
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                Spacer()
                switch viewModel.status {
                    case .initial:
                        SearchInitialView()
                    case .loading:
                        Spacer()
                        CustomProgressView()
                        Spacer()
                    case .loaded:
                        SearchResultsView(searchText: viewModel.searchResultText, numberOfSearchResults: viewModel.numberOfSearchResults, searchResults: viewModel.searchResults, onLoadSchedule: { programme in
                                viewModel.onLoadSchedule(programme: programme)
                            })
                    case .error:
                        SearchErrorView()
                    case .empty:
                        InfoView(title: "Schedule is empty", image: nil)
                    }
                SearchBar()
                    .environmentObject(viewModel)
                    .onSubmit {
                        if(!viewModel.searchBarText.trimmingCharacters(in: .whitespaces).isEmpty) {
                            viewModel.onSearchProgrammes(searchQuery: viewModel.searchBarText)
                        }
                    }
                    
            }
            
        }
        .sheet(isPresented: $viewModel.presentPreview) {
            SchedulePreviewView()
                .environmentObject(viewModel)
        }
    }
}
