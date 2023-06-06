//
//  SearchView-ViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Combine
import Foundation
import SwiftUI

/// Handles state and interaction with KronoxManager
/// for finding schedules for specific schools
/// and displaying search results
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
    
    func createSearchPreviewViewModel() -> SearchPreviewViewModel {
        viewModelFactory.makeViewModelSearchPreview()
    }
    
    func onSearchProgrammes(searchQuery: String, selectedSchoolId: Int) {
        self.status = .loading
        let endpoint = Endpoint.searchProgramme(searchQuery: searchQuery, schoolId: String(selectedSchoolId))
        Task {
            do {
                let searchResult: Response.Search = try await self.kronoxManager.get(endpoint)
                await self.parseSearchResults(searchResult)
            } catch (let error) {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.errorMessageSearch = error.localizedDescription
                    self.status = SearchStatus.error
                }
            }
        }
        
    }
    
    @MainActor
    func resetSearchResults() {
        programmeSearchResults = []
        status = .initial
    }
    
    @MainActor
    func parseSearchResults(_ results: Response.Search) {
        programmeSearchResults = results.items.map { $0 }
        status = .loaded
    }
}
