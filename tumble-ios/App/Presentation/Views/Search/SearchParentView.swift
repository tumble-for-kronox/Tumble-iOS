//
//  SearchView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SearchParentView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    @State var searchBarText: String = ""
    
    let checkForNewSchedules: () -> Void
    
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
                        SearchResultsView(searchText: searchBarText, numberOfSearchResults: viewModel.numberOfSearchResults, searchResults: viewModel.programmeSearchResults, onOpenProgramme: onOpenProgramme)
                    case .error:
                        SearchErrorView()
                    case .empty:
                        InfoView(title: "Schedule is empty", image: nil)
                    }
                SearchBar(searchBarText: $searchBarText, onSearch: onSearch, onClearSearch: onClearSearch)
            }
            
        }
        .sheet(isPresented: $viewModel.presentPreview) {
            SchedulePreviewView(courseColors: $viewModel.courseColors, checkForNewSchedules: checkForNewSchedules)
                .environmentObject(viewModel)
        }
    }
    
    func onSearch(query: String) -> Void {
        viewModel.onSearchProgrammes(searchQuery: query)
    }
    
    func onClearSearch(endEditing: Bool) -> Void {
        viewModel.onClearSearch(endEditing: endEditing)
    }
    
    func onOpenProgramme(programmeId: String) -> Void {
        viewModel.onOpenProgrammeSchedule(programmeId: programmeId)
    }
    
}
