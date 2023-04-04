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
    
    @Binding var universityImage: Image?
    let checkForNewSchedules: () -> Void
    
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
                        SearchResults(searchText: searchBarText, numberOfSearchResults: viewModel.programmeSearchResults.count, searchResults: viewModel.programmeSearchResults, onOpenProgramme: onOpenProgramme, universityImage: $universityImage)
                    case .error:
                        Info(title: viewModel.errorMessageSearch ?? NSLocalizedString("Something went wrong", comment: ""), image: nil)
                    case .empty:
                        Info(title: NSLocalizedString("Schedule is empty", comment: ""), image: nil)
                    }
                SearchBar(searchBarText: $searchBarText, onSearch: onSearch, onClearSearch: onClearSearch)
            }
            .background(Color.background)
            .sheet(isPresented: $viewModel.presentPreview) {
                SchedulePreview(
                    parentViewModel: viewModel,
                    courseColors: $viewModel.courseColors,
                    checkForNewSchedules: checkForNewSchedules
                )
            }
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
