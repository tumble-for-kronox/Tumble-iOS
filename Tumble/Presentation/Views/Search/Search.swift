//
//  SearchView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct Search: View {
    @ObservedObject var viewModel: SearchViewModel
        
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.status {
            case .initial:
                SearchInfo(schools: viewModel.schools, selectedSchool: $viewModel.selectedSchool)
            case .loading:
                CustomProgressIndicator()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .loaded:
                SearchResults(
                    searchText: viewModel.searchBarText,
                    numberOfSearchResults: viewModel.programmeSearchResults.count,
                    searchResults: viewModel.programmeSearchResults,
                    onOpenProgramme: openProgramme, universityImage: viewModel.universityImage
                )
            case .error:
                Info(title: viewModel.errorMessageSearch ?? NSLocalizedString("Something went wrong", comment: ""), image: nil)
            case .empty:
                Info(title: NSLocalizedString("Schedule is empty", comment: ""), image: nil)
            }
            SearchField(
                search: search,
                clearSearch: clearSearch,
                title: "Search schedules",
                searchBarText: $viewModel.searchBarText,
                searching: $viewModel.searching,
                disabled: $viewModel.schoolNotSelected
            )
            .blur(radius: viewModel.schoolNotSelected ? 2.5 : 0)
            .padding(.bottom, 15)
        }
        .background(Color.background)
        .onChange(of: viewModel.selectedSchool) { school in
            if school == nil {
                viewModel.schoolNotSelected = true
            } else {
                viewModel.schoolNotSelected = false
            }
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
        return !viewModel.searchBarText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func search() {
        if let selectedSchool = viewModel.selectedSchool, searchBoxNotEmpty() {
            viewModel.universityImage = selectedSchool.logo
            viewModel.onSearchProgrammes(
                searchQuery: viewModel.searchBarText,
                selectedSchoolId: selectedSchool.id
            )
        }
    }
    
    func clearSearch() {
        viewModel.resetSearchResults()
    }
    
    func openProgramme(programmeId: String) {
        if let selectedSchoolId = viewModel.selectedSchool?.id {
            viewModel.searchPreviewModel = SearchPreviewModel(
                scheduleId: programmeId, schoolId: String(selectedSchoolId)
            )
        }
    }
}
