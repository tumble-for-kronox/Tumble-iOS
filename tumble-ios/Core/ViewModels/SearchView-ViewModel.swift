//
//  SearchView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Foundation
import SwiftUI

enum SearchStatus {
    case initial
    case loading
    case loaded
    case error
    case empty
}

enum PreviewDelegateStatus {
    case loaded
    case loading
    case error
    case empty
}

extension SearchParentView {
    @MainActor class SearchViewModel: ObservableObject {
        @Published var searchBarText: String = ""
        @Published var searchResultText: String = ""
        @Published var isEditing: Bool = false
        @Published var status: SearchStatus = .initial
        @Published var numberOfSearchResults: Int = 0
        @Published var searchResults: [API.Types.Response.Programme] = []
        @Published var scheduleForPreview: API.Types.Response.Schedule? = nil
        @Published var presentPreview: Bool = false
        @Published var previewDelegateStatus: PreviewDelegateStatus = .loading
        @Published var school: School = UserDefaults.standard.getDefaultSchool()
        private var client: API.Client = API.Client.shared
        
        func onSearchProgrammes(searchQuery: String) -> Void {
            self.status = .loading
            self.searchResultText = self.searchBarText
            client.get(.searchProgramme(searchQuery: searchQuery, schoolId: String(school.id))) { (result: Result<API.Types.Response.Search, API.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        self.status = SearchStatus.loading
                        self.parseSearchResults(success)
                    case .failure( _):
                        self.status = SearchStatus.error
                        print("error")
                    }
                }
            }
        }
        
        func onClearSearch(endEditing: Bool) -> Void {
            if (endEditing) {
                self.isEditing = false
                self.searchResults = []
                self.status = .initial
            }
            self.searchBarText = ""
        }
        
        func onLoadSchedule(programme: API.Types.Response.Programme) -> Void {
            self.presentPreview = true
            client.get(.schedule(scheduleId: programme.id, schoolId: String(school.id))) { (result: Result<API.Types.Response.Schedule, API.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let schedule):
                        self.scheduleForPreview = schedule
                        self.presentPreview = true
                        self.previewDelegateStatus = .loaded
                    case .failure(_):
                        self.previewDelegateStatus = .error
                    }
                }
            }
        }
        
        
        // Private functions
        private func parseSearchResults(_ results: API.Types.Response.Search) -> Void {
            var localResults = [API.Types.Response.Programme]()
            self.numberOfSearchResults = results.count
            for result in results.items {
                localResults.append(result)
            }
            self.searchResults = localResults
            self.status = .loaded
        }
    }
}
