//
//  SearchView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel = SearchViewModel()
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                Spacer()
                self.onBuild()
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
    
    private func onBuild() -> AnyView {
        switch viewModel.status {
            case .initial:
                return AnyView(SearchInitialView())
            case .loading:
                return AnyView(CustomProgressView())
            case .loaded:
            return AnyView(SearchResultsView(searchText: viewModel.searchResultText, numberOfSearchResults: viewModel.numberOfSearchResults, searchResults: viewModel.searchResults, onLoadSchedule: { programme in
                    viewModel.onLoadSchedule(programme: programme)
                }))
            case .error:
                return AnyView(Text("Error"))
            case .empty:
                return AnyView(Text("Schedule is empty"))
            }
    }
}
