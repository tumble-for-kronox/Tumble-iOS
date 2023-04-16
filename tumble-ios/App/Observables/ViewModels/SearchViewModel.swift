//
//  SearchView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Foundation
import SwiftUI
import Combine

final class SearchViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var preferenceService: PreferenceService
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var schoolManager: SchoolManager
    
    @Published var status: SearchStatus = .initial
    @Published var programmeSearchResults: [Response.Programme] = []
    @Published var courseColors: CourseAndColorDict? = nil
    @Published var schoolId: Int = -1
    @Published var errorMessageSearch: String? = nil
    @Published var searchPreviewModel: SearchPreviewModel? = nil
    @Published var universityImage: Image?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        initialisePipelines()
        universityImage = self.schoolManager.getSchools().first(where: { $0.id == schoolId })?.logo
    }
    
    func initialisePipelines() {
        preferenceService.$schoolId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] schoolId in
                guard let self = self else { return }
                self.schoolId = schoolId
                self.universityImage = self.schoolManager.getSchools().first(where: { $0.id == schoolId })?.logo
                self.resetSearchResults()
            }
            .store(in: &cancellables)
    }
    
    func createSearchPreviewViewModel(scheduleId: String) -> SearchPreviewViewModel {
        viewModelFactory.makeViewModelSearchPreview(scheduleId: scheduleId)
    }
    
    func onSearchProgrammes(searchQuery: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            status = .loading
            let endpoint = Endpoint.searchProgramme(searchQuery: searchQuery, schoolId: String(schoolId))
            let _ = kronoxManager.get(endpoint, then: handleSearchResult)
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
    
    func resetSearchResults() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.programmeSearchResults = []
            self.status = .initial
        }
    }
    
    func parseSearchResults(_ results: Response.Search) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.programmeSearchResults = results.items.map { $0 }
            self.status = .loaded
        }
    }
    
    func clearSearchResults(endEditing: Bool) {
        if endEditing {
            resetSearchResults()
        }
    }
}
