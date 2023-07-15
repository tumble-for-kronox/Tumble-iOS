//
//  SearchView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct Search: View {
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var appController: AppController = .shared
        
    var body: some View {
        NavigationView {
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
                    Info(
                        title: NSLocalizedString("Something went wrong", comment: ""), image: nil)
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
            .fullScreenCover(item: $viewModel.searchPreviewModel) { model in
                SearchPreviewSheet(
                    viewModel: viewModel.searchPreviewViewModel,
                    programmeId: model.scheduleId,
                    schoolId: model.schoolId,
                    closePreview: closePreview
                )
                .background(Color.background)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(NSLocalizedString("Search", comment: ""))
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .tabItem {
            TabItem(appTab: TabbarTabType.search, selectedAppTab: $appController.selectedAppTab)
        }
        .tag(TabbarTabType.search)
    }
    
    /// Clear the previous preview model and
    /// set the state to loading upon next opening
    func closePreview() {
        viewModel.searchPreviewModel = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.searchPreviewViewModel.status = .loading
        }
    }

    fileprivate func searchBoxNotEmpty() -> Bool {
        return !viewModel.searchBarText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func search() {
        if let selectedSchool = viewModel.selectedSchool, searchBoxNotEmpty() {
            viewModel.universityImage = selectedSchool.logo
            viewModel.search(
                for: viewModel.searchBarText,
                selectedSchoolId: selectedSchool.id
            )
        }
    }
    
    func clearSearch() {
        withAnimation(.spring()) {
            viewModel.resetSearchResults()
        }
    }
    
    func openProgramme(programmeId: String) {
        if let selectedSchoolId = viewModel.selectedSchool?.id {
            viewModel.searchPreviewModel = SearchPreviewModel(
                scheduleId: programmeId, schoolId: String(selectedSchoolId)
            )
        }
    }
}
