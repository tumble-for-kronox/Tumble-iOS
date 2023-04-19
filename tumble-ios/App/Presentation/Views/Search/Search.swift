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
    @State private var searching: Bool = false
        
    var body: some View {
        VStack (spacing: 0) {
            switch viewModel.status {
                case .initial:
                SearchInfo(schools: viewModel.schools, selectedSchool: $viewModel.selectedSchool)
                case .loading:
                    CustomProgressIndicator()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case .loaded:
                SearchResults(
                    searchText: searchBarText,
                    numberOfSearchResults: viewModel.programmeSearchResults.count,
                    searchResults: viewModel.programmeSearchResults,
                    onOpenProgramme: openProgramme, universityImage: viewModel.universityImage)
                case .error:
                    Info(title: viewModel.errorMessageSearch ?? NSLocalizedString("Something went wrong", comment: ""), image: nil)
                case .empty:
                    Info(title: NSLocalizedString("Schedule is empty", comment: ""), image: nil)
                }
            SearchField(
                search: search,
                clearSearch: clearSearch,
                title: "Search schedules",
                searchBarText: $searchBarText,
                searching: $searching,
                disabled: $viewModel.schoolNotSelected
            )
            .padding(.bottom, 15)
        }
        .background(Color.background)
        .onChange(of: viewModel.selectedSchool) { _ in
            viewModel.schoolNotSelected.toggle()
        }
        .sheet(item: $viewModel.searchPreviewModel) { model in
            SearchPreview(
                viewModel: viewModel.createSearchPreviewViewModel(),
                programmeId: model.scheduleId,
                schoolId: model.schoolId
            )
            .background(Color.background)
        }
    }

    fileprivate func searchBoxNotEmpty() -> Bool {
        return !searchBarText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func search() -> Void {
        if let selectedSchool = viewModel.selectedSchool, searchBoxNotEmpty() {
            viewModel.universityImage = selectedSchool.logo
            viewModel.onSearchProgrammes(searchQuery: searchBarText, selectedSchoolId: selectedSchool.id)
        }
    }
    
    func clearSearch() -> Void {
        viewModel.resetSearchResults()
    }
    
    func openProgramme(programmeId: String) -> Void {
        if let selectedSchoolId = viewModel.selectedSchool?.id {
            viewModel.searchPreviewModel = SearchPreviewModel(
                scheduleId: programmeId, schoolId: String(selectedSchoolId))
        }
    }
    
}
