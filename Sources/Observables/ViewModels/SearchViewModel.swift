//
//  SearchView-ViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Combine
import Foundation
import SwiftUI

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
    
    private var cancellables = Set<AnyCancellable>()
    lazy var schools: [School] = schoolManager.getSchools()
    
    func createSearchPreviewViewModel() -> SearchPreviewViewModel {
        viewModelFactory.makeViewModelSearchPreview()
    }
    
    func onSearchProgrammes(searchQuery: String, selectedSchoolId: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.status = .loading
            let endpoint = Endpoint.searchProgramme(searchQuery: searchQuery, schoolId: String(selectedSchoolId))
            let _ = self.kronoxManager.get(endpoint, then: self.handleSearchResult)
        }
    }
    
    func handleSearchResult(result: Result<Response.Search, Response.ErrorMessage>) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch result {
            case .success(let result):
                self.parseSearchResults(result)
            case .failure(let failure):
                switch failure.statusCode {
                case 204:
                    self.errorMessageSearch = NSLocalizedString("There are no schedules that match your search", comment: "")
                    self.status = SearchStatus.error
                default:
                    self.errorMessageSearch = NSLocalizedString("Something went wrong", comment: "")
                    self.status = SearchStatus.error
                }
                AppLogger.shared.debug("Encountered error when trying to search for programme: \(failure)")
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
