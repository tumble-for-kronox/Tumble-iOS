//
//  SearchView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SearchPage: View {
    
    @ObservedObject var viewModel: SearchPageViewModel
    @State var searchBarText: String = ""
    
    @Binding var universityImage: Image?
    let checkForNewSchedules: () -> Void
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                switch viewModel.status {
                    case .initial:
                        SearchInfo()
                    case .loading:
                        CustomProgressIndicator()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    case .loaded:
                    SearchResults(searchText: searchBarText, numberOfSearchResults: viewModel.programmeSearchResults.count, searchResults: viewModel.programmeSearchResults, onOpenProgramme: onOpenProgramme, universityImage: $universityImage)
                    case .error:
                        SearchError()
                    case .empty:
                        Info(title: "Schedule is empty", image: nil)
                    }
                SearchBar(searchBarText: $searchBarText, onSearch: onSearch, onClearSearch: onClearSearch)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .sheet(isPresented: $viewModel.presentPreview) {
            SchedulePreview(courseColors: $viewModel.courseColors, checkForNewSchedules: checkForNewSchedules)
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
