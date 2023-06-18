//
//  SearchView-ViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Combine
import Foundation
import SwiftUI

/// ViewModel handling interaction with KronoxManager
/// for finding schedules for specific schools
/// and displaying search results.
final class SearchViewModel: ObservableObject {
    let viewModelFactory: ViewModelFactory = .shared
    
    @Inject var preferenceService: PreferenceService
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var schoolManager: SchoolManager
    
    @Published var status: SearchStatus = .initial
    @Published var programmeSearchResults: [Response.Programme] = []
    @Published var errorMessageSearch: String? = nil
    @Published var searchPreviewModel: SearchPreviewModel? = nil
    @Published var schoolNotSelected: Bool = true
    @Published var selectedSchool: School? = nil
    @Published var universityImage: Image? = nil
    @Published var searching: Bool = false
    @Published var searchBarText: String = ""
    
    lazy var schools: [School] = schoolManager.getSchools()
    lazy var searchPreviewViewModel: SearchPreviewViewModel = viewModelFactory.makeViewModelSearchPreview()
    
    /// Searches for the input given by the user and attempts
    /// to find matching university programmes and schedules
    func search(for query: String, selectedSchoolId: Int) {
        self.status = .loading
        let endpoint = Endpoint.searchProgramme(searchQuery: query, schoolId: String(selectedSchoolId))
        Task {
            do {
                let searchResult: Response.Search = try await self.kronoxManager.get(endpoint)
                await self.parseSearchResults(searchResult)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.errorMessageSearch = error.localizedDescription
                    self.status = SearchStatus.error
                }
            }
        }
        
    }
    
    /// Resets any fields and data in the `Search` and
    /// `SearchResults` views
    @MainActor func resetSearchResults() {
        programmeSearchResults = []
        status = .initial
    }
    
    /// Maps data given in `Response.Search` to
    /// `[Response.Programme]` and updates view state
    @MainActor func parseSearchResults(_ results: Response.Search) {
        programmeSearchResults = results.items.map { $0 }
        status = .loaded
    }
}
